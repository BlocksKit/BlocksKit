//
//  A2BlockInvocation.m
//  A2DynamicDelegate
//
//  Created by Zachary Waldowski on 10/3/12.
//  Copyright (c) 2012 Pandamonia LLC. All rights reserved.
//

#import "A2BlockInvocation.h"
#import <objc/runtime.h>

#if (TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE))
	#import <ffi/ffi.h>
#else
	#import <CoreGraphics/CoreGraphics.h>
	#import <ffi.h>
#endif

#pragma mark Block Internals

typedef NS_ENUM(int, BKBlockFlags) {
	BKBlockFlagsHasCopyDisposeHelpers	= (1 << 25),
	BKBlockFlagsHasConstructor			= (1 << 26),
	BKBlockFlagsIsGlobal				= (1 << 28),
	BKBlockFlagsReturnsStruct			= (1 << 29),
	BKBlockFlagsHasSignature			= (1 << 30)
};

typedef struct _BKBlock {
	void *isa;
	BKBlockFlags flags;
	int reserved;
	void (*invoke)(void);
	struct {
		unsigned long int reserved;
		unsigned long int size;
		// requires BKBlockFlagsHasCopyDisposeHelpers
		void (*copy)(void *dst, const void *src);
		void (*dispose)(const void *);
		// requires BKBlockFlagsHasSignature
		const char *signature;
		const char *layout;
	} *descriptor;
	// imported variables
} *BKBlockRef;

static NSMethodSignature *a2_blockGetSignature(id block) {
	BKBlockRef layout = (__bridge void *)block;

	if (!(layout->flags & BKBlockFlagsHasSignature))
		return nil;

	void *desc = layout->descriptor;
	desc += 2 * sizeof(unsigned long int);

	if (layout->flags & BKBlockFlagsHasCopyDisposeHelpers)
		desc += 2 * sizeof(void *);

	if (!desc)
		return nil;

	NSMutableString *signature = [NSMutableString stringWithCString:(*(const char **)desc) encoding:NSUTF8StringEncoding];
	[signature replaceOccurrencesOfString:@"\"[^\"]*\"" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, signature.length)];
	
	return [NSMethodSignature signatureWithObjCTypes:[signature UTF8String]];
}

static void (*a2_blockGetInvoke(void *block))(void) {
	BKBlockRef layout = block;
	return layout->invoke;
}

#pragma mark - Core Graphics FFI types

static const ffi_type *_ffi_type_elements_nsrange[] = { &ffi_type_ulong, &ffi_type_ulong, NULL };
static ffi_type ffi_type_nsrange = { sizeof(NSRange), __alignof(NSRange), FFI_TYPE_STRUCT, (ffi_type **)_ffi_type_elements_nsrange };

#if CGFLOAT_IS_DOUBLE
	static const ffi_type *_ffi_type_elements_cgpoint[] = { &ffi_type_double, &ffi_type_double, NULL };
	static const ffi_type *_ffi_type_elements_cgsize[] = { &ffi_type_double, &ffi_type_double, NULL };
#else
	static const ffi_type *_ffi_type_elements_cgpoint[] = { &ffi_type_float, &ffi_type_float, NULL };
	static const ffi_type *_ffi_type_elements_cgsize[] = { &ffi_type_float, &ffi_type_float, NULL };
#endif

static ffi_type ffi_type_cgpoint = { sizeof(CGPoint), __alignof(CGPoint), FFI_TYPE_STRUCT, (ffi_type **)_ffi_type_elements_cgpoint };
static ffi_type ffi_type_cgsize = { sizeof(CGSize), __alignof(CGSize), FFI_TYPE_STRUCT, (ffi_type **)_ffi_type_elements_cgsize };

static const ffi_type *_ffi_type_elements_cgrect[] = { &ffi_type_cgpoint, &ffi_type_cgsize, NULL };
static ffi_type ffi_type_cgrect = { sizeof(CGRect),  __alignof(CGRect), FFI_TYPE_STRUCT, (ffi_type **)_ffi_type_elements_cgrect };

static ffi_type ffi_type_selector = { sizeof(SEL), __alignof(SEL), FFI_TYPE_POINTER, NULL };
static ffi_type ffi_type_class = { sizeof(Class), __alignof(Class), FFI_TYPE_POINTER, NULL };
static ffi_type ffi_type_id = { sizeof(id), __alignof(id), FFI_TYPE_POINTER, NULL };
static ffi_type ffi_type_charptr = { sizeof(char *), __alignof(char *), FFI_TYPE_POINTER, NULL };

#pragma mark - Helper functions

static inline const char *a2_skipStructName(const char *type) {
	if (*type == _C_STRUCT_B) type++;

	if (*type == _C_UNDEF)
	{
		type++;
	}
	else if (isalpha(*type) || *type == '_')
	{
		while (isalnum(*type) || *type == '_')
		{
			type++;
		}
	}
	else
	{
		return type;
	}

	if (*type == '=') type++;

	return type;
}

static inline NSUInteger a2_getStructSize(const char *encodingType) {
	if (*encodingType != _C_STRUCT_B) return -1;
	while (*encodingType != _C_STRUCT_E && *encodingType++ != '='); // skip "<name>="

	NSUInteger ret = 0;
	while (*encodingType != _C_STRUCT_E)
	{
		encodingType = NSGetSizeAndAlignment(encodingType, NULL, NULL);
		ret++;
	}
	
	return ret;
}

static inline NSUInteger a2_sizeForType(ffi_type *type) {
	size_t size = type->size, align = type->alignment;
	return (size % align != 0) ? size + (align - size % align) : size;
}

static ffi_type *a2_typeForSignature(const char *argumentType, void *(^allocate)(size_t)) {
	switch (*argumentType) {
		case _C_CLASS: return &ffi_type_class; break;
		case _C_SEL: return &ffi_type_selector; break;
		case _C_ID: return &ffi_type_id; break;
		case _C_CHARPTR: return &ffi_type_charptr; break;
		case _C_ATOM:
		case _C_PTR:
			return &ffi_type_pointer; break;
		case _C_BOOL:
		case _C_UCHR:
			return &ffi_type_uchar; break;
		case _C_CHR: return &ffi_type_schar; break;
		case _C_SHT: return &ffi_type_sshort; break;
		case _C_USHT: return &ffi_type_ushort; break;
		case _C_INT: return &ffi_type_sint; break;
		case _C_UINT: return &ffi_type_uint; break;
		case _C_LNG: return &ffi_type_slong; break;
		case _C_ULNG: return &ffi_type_ulong; break;
		case _C_LNG_LNG: return &ffi_type_sint64; break;
		case _C_ULNG_LNG: return &ffi_type_uint64; break;
		case _C_FLT: return &ffi_type_float; break;
		case _C_DBL: return &ffi_type_double; break;
		case _C_VOID: return &ffi_type_void; break;
		case _C_BFLD:
		case _C_ARY_B:
		{
			NSUInteger size, align;
			NSGetSizeAndAlignment(argumentType, &size, &align);

			if (size > 0)
			{
				if (size == 1)
					return &ffi_type_uchar;
				else if (size == 2)
					return &ffi_type_ushort;
				else if (size <= 4)
					return &ffi_type_uint;
				else if (size > sizeof(void *))
					return &ffi_type_pointer;
				else
				{
					ffi_type *type = allocate(sizeof(ffi_type));
					type->size = size;
					type->alignment = (unsigned short)align;
					type->type = FFI_TYPE_STRUCT;
					type->elements = allocate((size + 1) * sizeof(ffi_type *));
					for (NSUInteger i = 0; i < size; i++)
						type->elements[i] = &ffi_type_uchar;
					type->elements[size] = NULL;
					return type;
				}
				
				break;
			}
		}
		case _C_STRUCT_B:
		{
			if (!strcmp(argumentType, @encode(NSRange)))
			{
				return &ffi_type_nsrange; break;
			}
			else if (!strcmp(argumentType, @encode(CGSize)))
			{
				return &ffi_type_cgsize; break;
			}
			else if (!strcmp(argumentType, @encode(CGPoint)))
			{
				return &ffi_type_cgpoint; break;
			}
			else if (!strcmp(argumentType, @encode(CGRect)))
			{
				return &ffi_type_cgrect; break;
			}
#if (TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE))
			else if (!strcmp(argumentType, @encode(NSSize)))
			{
				return &ffi_type_cgsize; break;
			}
			else if (!strcmp(argumentType, @encode(NSPoint)))
			{
				return &ffi_type_cgpoint; break;
			}
			else if (!strcmp(argumentType, @encode(NSRect)))
			{
				return &ffi_type_cgrect; break;
			}
#endif

			NSUInteger size, align;
			NSGetSizeAndAlignment(argumentType, &size, &align);

			ffi_type *type = allocate(sizeof(ffi_type));
			type->size = size;
			type->alignment = (unsigned short)align;
			type->type = FFI_TYPE_STRUCT;
			type->elements = allocate((a2_getStructSize(argumentType) + 1) * sizeof(ffi_type *));

			size_t index = 0;
			argumentType = a2_skipStructName(argumentType);
			while (*argumentType != _C_STRUCT_E)
			{
				type->elements[index] = a2_typeForSignature(argumentType, allocate);
				argumentType = NSGetSizeAndAlignment(argumentType, NULL, NULL);
				index++;
			}

			type->elements[index] = NULL;
			return type;
			break;
		}
		default:
		{
			NSCAssert(0, @"Unknown type in sig");
			return &ffi_type_void;
			break;
		}
	}
}

@interface A2BlockInvocation () {
	BOOL _argumentsRetained;
	BOOL _validReturn;
	void **_argumentFrame;
	void *_returnValue;
	size_t _returnLength;
	void *_block;
}

@property (nonatomic, strong, readwrite, setter = a2_setMethodSignature:) NSMethodSignature *methodSignature;
@property (nonatomic, strong, readwrite, setter = a2_setBlockSignature:) NSMethodSignature *blockSignature;
@property (nonatomic, strong) NSMutableArray *allocations;
@property (nonatomic, strong) NSMutableDictionary *arguments;
@property (nonatomic) ffi_cif interface;

@end

@implementation A2BlockInvocation

- (id) initWithBlock: (id) block methodSignature: (NSMethodSignature *)methodSignature
{
	NSParameterAssert(block);
	NSMethodSignature *blockSignature = a2_blockGetSignature(block);
	NSCAssert1(blockSignature, @"Incompatible block: %@", block);
	
	if ((self = [super init])) {
		NSMutableArray *allocations = [NSMutableArray new];

		void *(^allocate)(size_t) = ^(size_t howmuch){
			void *buffer = calloc(howmuch, 1);
			[allocations addObject: [NSData dataWithBytesNoCopy: buffer length: howmuch]];
			return buffer;
		};

		ffi_type *returnType = a2_typeForSignature(blockSignature.methodReturnType, allocate);
		if (returnType->type != FFI_TYPE_VOID) {
			_returnLength = a2_sizeForType(returnType);
			_returnValue = allocate(_returnLength);
		}

		unsigned int argCount = (unsigned int)blockSignature.numberOfArguments;

		ffi_type **methodArgs = allocate(argCount * sizeof(ffi_type *));
		_argumentFrame = allocate(argCount * sizeof(void *));

		methodArgs[0] = &ffi_type_pointer;

		for (NSUInteger i = 1; i < argCount; i++)
		{
			methodArgs[i] = a2_typeForSignature([blockSignature getArgumentTypeAtIndex: i], allocate);
			_argumentFrame[i] = allocate(a2_sizeForType(methodArgs[i]));
		}

		ffi_cif cif;
		ffi_status status = ffi_prep_cif(&cif, FFI_DEFAULT_ABI, argCount, returnType, methodArgs);
		NSCAssert2(status == FFI_OK, @"%@ -  Unable to create function interface for block: %@", [self class], [self block]);

		_block = (void *) Block_copy((__bridge void *) block);
		self.methodSignature = methodSignature;
		self.blockSignature = blockSignature;
		self.allocations = allocations;
		self.arguments = [NSMutableDictionary dictionaryWithCapacity:cif.nargs-1];
		self.interface = cif;

		_argumentFrame[0] = &_block;
	}
	return self;
}

- (id) block
{
	return (__bridge id) _block;
}

- (void) clearArguments
{
	for (int i = 0; i < self.interface.nargs - 1; i++)
		[self setArgument: 0 atIndex: i];
}
- (void) dealloc
{
	[self setReturnValue: nil];
	Block_release(_block);
}

- (void) retainArguments
{
	if (!_argumentsRetained)
	{
		ffi_cif cif = self.interface;
		
		for (NSUInteger i = 1; i < cif.nargs; i++)
		{
			if (cif.arg_types[i] == &ffi_type_id)
			{
				id argument = *(__unsafe_unretained id *)_argumentFrame[i];
                if (argument) self.arguments[@(i)] = argument;
			}
			else if (cif.arg_types[i] == &ffi_type_charptr)
			{
				char *old = *(char **)_argumentFrame[i];
				if (!old) continue;
                NSNumber *key = @(i);
                NSData *currentData = self.arguments[key];
                if (currentData.bytes == old) continue;
                
                char *new = strdup(old);
                currentData = [NSData dataWithBytesNoCopy:new length:strlen(new) freeWhenDone:YES];
                self.arguments[key] = currentData;
                const char *newPtr = currentData.bytes;
                memcpy(_argumentFrame[i], &newPtr, a2_sizeForType(&ffi_type_charptr));
			}
		}
		
		_argumentsRetained = YES;
	}
}
- (BOOL) argumentsRetained
{
	return _argumentsRetained;
}

- (void) getReturnValue: (void *) retLoc
{
	if (!_validReturn) return;
	memcpy(retLoc, _returnValue, _returnLength);
}
- (void) setReturnValue: (void *) retLoc
{
	ffi_type *returnType = self.interface.rtype;
	if (returnType == &ffi_type_void)
		return;
	else if (returnType == &ffi_type_id)
	{
		if (_validReturn)
			*(__autoreleasing id *) _returnValue = nil;
		else
			*(__unsafe_unretained id *) _returnValue = nil;

		if (retLoc)
		{
			*(__strong id *) _returnValue = *(__unsafe_unretained id *)retLoc;
			_validReturn = YES;
		}
		else
		{
			*(__unsafe_unretained id *) _returnValue = nil;
			_validReturn = NO;
		}
	}
	else
	{
		if (retLoc)
		{
			memcpy(_returnValue, retLoc, _returnLength);
			_validReturn = YES;
		}
		else
			_validReturn = NO;
	}
}

- (void) getArgument: (void *) buffer atIndex: (NSInteger) idx
{
	idx++;
	ffi_cif cif = self.interface;
	NSParameterAssert(idx >= 0 && idx < cif.nargs);
	memcpy(buffer, _argumentFrame[idx], a2_sizeForType(cif.arg_types[idx]));
}
- (void) setArgument: (void *) buffer atIndex: (NSInteger) idx
{
	idx++;
	ffi_cif cif = self.interface;
	NSParameterAssert(idx >= 0 && idx < cif.nargs);

	if (_argumentsRetained)
	{
		ffi_type *type = cif.arg_types[idx];
		if (type == &ffi_type_id)
		{
            NSNumber *key = @(idx);
            [self.arguments removeObjectForKey: key];
			
			if (buffer)
			{
				id new = *(__unsafe_unretained id *)buffer;
				if (new) self.arguments[key] = new;
			}
		}
		else if (type == &ffi_type_charptr)
		{
            NSNumber *key = @(idx);
            [self.arguments removeObjectForKey: key];
            
			if (buffer)
			{
				char *new = *(char**)buffer;
				if (new)
				{
                    NSMutableData *wrap = [NSMutableData dataWithBytes:new length:strlen(new)];
                    self.arguments[key] = wrap;
                    new = wrap.mutableBytes;
                    buffer = &new;
				}
			}
		}
	}
	
	if (buffer)
		memcpy(_argumentFrame[idx], buffer, a2_sizeForType(cif.arg_types[idx]));
	else
		memset(_argumentFrame[idx], 0, a2_sizeForType(cif.arg_types[idx]));
}

- (void) invoke
{
	ffi_cif cif = self.interface;
	void *returnValue = malloc(_returnLength);
	ffi_call(&cif, a2_blockGetInvoke(_block), returnValue, _argumentFrame);
	[self setReturnValue: returnValue];
	free(returnValue);
}
- (void) invokeUsingInvocation: (NSInvocation *) inv
{
	if (![inv isMemberOfClass: [NSInvocation class]])
		return;

	NSParameterAssert(inv.methodSignature.numberOfArguments - 1 == self.interface.nargs);

	[inv retainArguments];

	for (int i = 0; i < self.interface.nargs - 1; i++)
	{
		ffi_type *type = self.interface.arg_types[i];
		if (!type) break;

		size_t argSize = a2_sizeForType(type);
		void *thisArgument = malloc(argSize);
		if (!thisArgument) break;
		
		[inv getArgument: thisArgument atIndex: i + 2];
		[self setArgument: thisArgument atIndex: i];
		free(thisArgument);
	}

	[self invoke];

	if (_returnLength)
	{
		void *returnValue = malloc(_returnLength);
		[self getReturnValue: returnValue];
		[inv setReturnValue: returnValue];
		free(returnValue);
	}
}

@end
