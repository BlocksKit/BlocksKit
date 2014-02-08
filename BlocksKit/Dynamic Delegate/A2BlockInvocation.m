//
//  A2BlockInvocation.m
//  BlocksKit
//

#import "A2BlockInvocation.h"
#import "BKFFICompatibility.h"
#import <objc/runtime.h>
#import <CoreGraphics/CoreGraphics.h>

#ifndef NSFoundationVersionNumber10_8
#define NSFoundationVersionNumber10_8 945.00
#endif

#ifndef NSFoundationVersionNumber_iOS_6_0
#define NSFoundationVersionNumber_iOS_6_0  993.00
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
	void (*invoke)(struct _BKBlock *block, ...);
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
    
    const char *signature = (*(const char **)desc);
    
#if (TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MIN_REQUIRED < 60000) || (TARGET_OS_MAC && __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_8)
    static BOOL shouldStrip = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if TARGET_OS_IPHONE
        shouldStrip = (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_6_0);
#elif TARGET_OS_MAC
        shouldStrip = (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber10_8);
#else
        shouldStrip = YES;
#endif
    });
    
    if (shouldStrip) {
        NSMutableString *mutableSignature = [NSMutableString stringWithUTF8String:signature];
        [mutableSignature replaceOccurrencesOfString:@"\"[^\"]*\"" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, mutableSignature.length)];
        signature = [mutableSignature UTF8String];
    }
#endif
    
	return [NSMethodSignature signatureWithObjCTypes:signature];
}

static void (*a2_blockGetInvoke(id block))(void) {
	BKBlockRef layout = (__bridge BKBlockRef)block;
	return FFI_FN(layout->invoke);
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
static ffi_type ffi_type_bool = { sizeof(BOOL), __alignof(BOOL), FFI_TYPE_SINT8, NULL };

#pragma mark - Helper functions

static inline const char *a2_skipStructName(const char *type) {
	if (*type == _C_STRUCT_B) type++;

	if (*type == _C_UNDEF) {
		type++;
	} else if (isalpha(*type) || *type == '_') {
		while (isalnum(*type) || *type == '_')
			type++;
	} else {
		return type;
	}

	if (*type == '=')
		type++;

	return type;
}

static inline NSUInteger a2_getStructSize(const char *encodingType) {
	if (*encodingType != _C_STRUCT_B) return -1;
	while (*encodingType != _C_STRUCT_E && *encodingType++ != '='); // skip "<name>="

	NSUInteger ret = 0;
	while (*encodingType != _C_STRUCT_E) {
		encodingType = NSGetSizeAndAlignment(encodingType, NULL, NULL);
		ret++;
	}

	return ret;
}

static inline NSUInteger a2_sizeForType(ffi_type *type) {
    if (!type || type->type == FFI_TYPE_VOID) {
		return 0;
    }
	size_t size = type->size, align = type->alignment;
	return (size % align != 0) ? size + (align - size % align) : size;
}

static ffi_type *a2_typeForSignature(const char *argumentType, void *(^allocate)(size_t, size_t)) {
    ffi_type *type = NULL;
	switch (*argumentType) {
		case _C_CLASS:      type = &ffi_type_class; break;
		case _C_SEL:        type = &ffi_type_selector; break;
		case _C_ID:         type = &ffi_type_id; break;
		case _C_CHARPTR:    type = &ffi_type_charptr; break;
		case _C_BOOL:       type = &ffi_type_bool; break;
		case _C_PTR:        type = &ffi_type_pointer; break;
		case _C_UCHR:       type = &ffi_type_uchar; break;
		case _C_CHR:        type = &ffi_type_schar; break;
		case _C_SHT:        type = &ffi_type_sshort; break;
		case _C_USHT:       type = &ffi_type_ushort; break;
		case _C_INT:        type = &ffi_type_sint; break;
		case _C_UINT:       type = &ffi_type_uint; break;
		case _C_LNG:        type = &ffi_type_slong; break;
		case _C_ULNG:       type = &ffi_type_ulong; break;
		case _C_LNG_LNG:    type = &ffi_type_sint64; break;
		case _C_ULNG_LNG:   type = &ffi_type_uint64; break;
		case _C_FLT:        type = &ffi_type_float; break;
		case _C_DBL:        type = &ffi_type_double; break;
		case _C_VOID:       type = &ffi_type_void; break;
		case _C_BFLD:
		case _C_ARY_B: {
			NSUInteger size, align;
			NSGetSizeAndAlignment(argumentType, &size, &align);

			if (size > 0) {
				if (size == sizeof(uint8_t)) {
					return &ffi_type_uchar;
				} else if (size == sizeof(uint16_t)) {
					return &ffi_type_ushort;
				} else if (size == sizeof(uint32_t)) {
					return &ffi_type_uint;
				}  else if (size == sizeof(uint64_t)) {
					return &ffi_type_uint;
				} else if (size > sizeof(void *)) {
					return &ffi_type_pointer;
				} else {
					type = allocate(1, sizeof(ffi_type));
					type->size = size;
					type->alignment = (unsigned short)align;
					type->type = FFI_TYPE_STRUCT;
					type->elements = allocate(size + 1, sizeof(ffi_type *));
					for (NSUInteger i = 0; i < size; i++)
						type->elements[i] = &ffi_type_uchar;
					type->elements[size] = NULL;
				}
				break;
			}
		}
		case _C_STRUCT_B: {
			if (!strcmp(argumentType, @encode(NSRange))) {
				return &ffi_type_nsrange; break;
			} else if (!strcmp(argumentType, @encode(CGSize))) {
				return &ffi_type_cgsize; break;
			} else if (!strcmp(argumentType, @encode(CGPoint))) {
				return &ffi_type_cgpoint; break;
			} else if (!strcmp(argumentType, @encode(CGRect))) {
				return &ffi_type_cgrect; break;
			}

			NSUInteger size, align;
			NSGetSizeAndAlignment(argumentType, &size, &align);

			type = allocate(1, sizeof(ffi_type));
			type->size = size;
			type->alignment = (unsigned short)align;
			type->type = FFI_TYPE_STRUCT;
			type->elements = allocate(a2_getStructSize(argumentType) + 1, sizeof(ffi_type *));

			size_t index = 0;
			argumentType = a2_skipStructName(argumentType);
			while (*argumentType != _C_STRUCT_E) {
				type->elements[index] = a2_typeForSignature(argumentType, allocate);
				argumentType = NSGetSizeAndAlignment(argumentType, NULL, NULL);
				index++;
			}

			type->elements[index] = NULL;
			break;
		}
		default: {
            NSString *reason = [NSString stringWithFormat:@"Unknown type in signature: \"%s\"", argumentType];
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
			break;
		}
	}
    return type;
}

@interface A2BlockInvocation ()
{
	BOOL _argumentsRetained;
	BOOL _validReturn;
	void **_argumentFrame;
	size_t _returnLength;
}

@property (nonatomic, readonly) NSHashTable *typeAllocations;
@property (nonatomic, readonly) NSPointerArray *retainedArguments;
@property (nonatomic, readonly) NSMutableDictionary *arguments DEPRECATED_ATTRIBUTE;
@property (nonatomic, readonly) ffi_cif interface;

@end

@implementation A2BlockInvocation

- (id)initWithBlock:(id)block methodSignature:(NSMethodSignature *)methodSignature
{
	NSParameterAssert(block);
	NSMethodSignature *blockSignature = a2_blockGetSignature(block);
	NSCAssert1(blockSignature, @"Incompatible block: %@", block);

	self = [super init];
	if (!self) return nil;
    
    _block = [block copy];
    _typeAllocations = [NSHashTable hashTableWithOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPersonality];
    
	void *(^callocate)(size_t, size_t) = ^(size_t count, size_t size) {
        NSMutableData *alloc = [NSMutableData dataWithLength:(count * size)];
		[_typeAllocations addObject:alloc];
        return alloc.mutableBytes;
	};

	NSUInteger argCount = blockSignature.numberOfArguments;

	_argumentFrame = callocate(argCount, sizeof(void *));
	_argumentFrame[0] = &_block;
    
	ffi_type **methodArgs = callocate(argCount, sizeof(ffi_type *));
	methodArgs[0] = &ffi_type_pointer;

	for (NSUInteger i = 1; i < argCount; i++) {
		methodArgs[i] = a2_typeForSignature([blockSignature getArgumentTypeAtIndex:i], callocate);
		_argumentFrame[i] = callocate(1, a2_sizeForType(methodArgs[i]));
	}
    
    ffi_type *returnType = a2_typeForSignature(blockSignature.methodReturnType, callocate);

    if (ffi_prep_cif(&_interface, FFI_DEFAULT_ABI, (unsigned int)argCount, returnType, methodArgs) != FFI_OK) {
        NSString *reason = [NSString stringWithFormat:@"%@ -  Unable to create function interface for block: %@", NSStringFromClass(self.class), self.block];
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
    }

	_methodSignature = methodSignature;
	_blockSignature = blockSignature;
    
    NSPointerArray *arguments = [NSPointerArray strongObjectsPointerArray];
    arguments.count = _interface.nargs;
    
    _returnLength = a2_sizeForType(returnType);
    NSMutableData *retBuf = [NSMutableData dataWithLength:_returnLength];
    [arguments replacePointerAtIndex:0 withPointer:(__bridge void *)retBuf];
    
    _retainedArguments = arguments;

	return self;
}

- (NSMutableData *)returnBuffer
{
    return (__bridge NSMutableData *)[self.retainedArguments pointerAtIndex:0];
}

- (void)clearArguments
{
	for (NSUInteger i = 0; i < self.interface.nargs - 1; i++)
		[self setArgument:NULL atIndex:i];
}
- (void)dealloc
{
	[self setReturnValue:NULL];
}

- (void)retainArguments
{
	if (_argumentsRetained) return;

	ffi_cif cif = self.interface;

	for (NSUInteger i = 1; i < cif.nargs; i++) {
        void *objPtr = NULL;

        ffi_type *type = cif.arg_types[i];
		if (type == &ffi_type_id) {
            objPtr = *(void **)_argumentFrame[i];
		} else if (type == &ffi_type_charptr) {
			char *arg = *(char **)_argumentFrame[i];
            if (arg) {
                NSData *data = [self.retainedArguments pointerAtIndex:i];
                if (data.bytes == arg) continue;
                
                data = [NSData dataWithBytes:arg length:strlen(arg)];
                const char *newPtr = data.bytes;
                memcpy(_argumentFrame[i], &newPtr, a2_sizeForType(&ffi_type_charptr));
                objPtr = (__bridge void *)data;
            }
		}
        
        [self.retainedArguments replacePointerAtIndex:i withPointer:objPtr];
	}

	_argumentsRetained = YES;
}

- (void)getReturnValue:(void *)retLoc
{
	if (!_validReturn) return;
    NSMutableData *buf = self.returnBuffer;
    [self.returnBuffer getBytes:retLoc length:buf.length];
}
- (void)setReturnValue:(void *)retLoc
{
	ffi_type *returnType = self.interface.rtype;
	if (returnType == &ffi_type_void) {
		return;
	}
    
    NSMutableData *bufData = self.returnBuffer;
    void *returnValue = bufData.mutableBytes;
    NSRange allRet = NSMakeRange(0, bufData.length);
    
    if (returnType == &ffi_type_id) {
		if (_validReturn) {
			*(__autoreleasing id *)returnValue = nil;
		}

		if (retLoc) {
			*(__strong id *)returnValue = *(__unsafe_unretained id *)retLoc;
			_validReturn = YES;
		} else {
			*(__unsafe_unretained id *)returnValue = nil;
			_validReturn = NO;
		}
	} else {
		if (retLoc) {
            [bufData replaceBytesInRange:allRet withBytes:retLoc];
			_validReturn = YES;
		} else {
			_validReturn = NO;
		}
	}
}

- (void)getArgument:(void *)buffer atIndex:(NSInteger)idx
{
	idx++;
	ffi_cif cif = self.interface;
	NSParameterAssert(idx >= 0 && idx < cif.nargs);
	memcpy(buffer, _argumentFrame[idx], a2_sizeForType(cif.arg_types[idx]));
}
- (void)setArgument:(void *)buffer atIndex:(NSInteger)idx
{
	idx++;
	ffi_cif cif = self.interface;
	NSParameterAssert(idx >= 0 && idx < cif.nargs);

    size_t typeSize = a2_sizeForType(cif.arg_types[idx]);
	if (_argumentsRetained)
	{
		ffi_type *type = cif.arg_types[idx];
		if (type == &ffi_type_id) {
            void *newValue = buffer ? *(void **)buffer : NULL;
            [self.retainedArguments replacePointerAtIndex:idx withPointer:newValue];
		} else if (type == &ffi_type_charptr) {
            void *newPtr = NULL;
            char *newValue = buffer ? *(char **)buffer : NULL;
            
            if (newValue) {
                size_t len = strlen(newValue);
                NSMutableData *wrap = [NSMutableData dataWithBytes:newValue length:len+1];
                newValue = wrap.mutableBytes;
                newValue[len] = '\0';
                newPtr = (__bridge void *)wrap;
            }
            
            [self.retainedArguments replacePointerAtIndex:idx withPointer:newPtr];
            
            if (newValue) {
                memcpy(_argumentFrame[idx], &newValue, typeSize);
                return;
            }
		}
	}

	if (buffer) {
		memcpy(_argumentFrame[idx], buffer, typeSize);
	} else {
		memset(_argumentFrame[idx], 0, typeSize);
	}
}

- (void)invoke
{
	ffi_cif cif = self.interface;
	void *returnValue = malloc(_returnLength);
	ffi_call(&cif, a2_blockGetInvoke(_block), returnValue, _argumentFrame);
	[self setReturnValue:returnValue];
	free(returnValue);
}
- (void)invokeUsingInvocation:(NSInvocation *)inv
{
	if (![inv isMemberOfClass:[NSInvocation class]])
		return;

	NSParameterAssert(inv.methodSignature.numberOfArguments - 1 == self.interface.nargs);

	[inv retainArguments];

	for (int i = 0; i < self.interface.nargs - 1; i++) {
		ffi_type *type = self.interface.arg_types[i];
		if (!type) break;

		size_t argSize = a2_sizeForType(type);
        void *thisArgument = NULL;
        if (argSize) thisArgument = malloc(argSize);
		if (!thisArgument) break;

		[inv getArgument:thisArgument atIndex:i + 2];
		[self setArgument:thisArgument atIndex:i];
		free(thisArgument);
	}

	[self invoke];

	if (_returnLength) {
		void *returnValue = malloc(_returnLength);
		[self getReturnValue:returnValue];
		[inv setReturnValue:returnValue];
		free(returnValue);
	}
}

@end
