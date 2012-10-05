//
//  A2BlockInvocation.m
//  A2DynamicDelegate
//
//  Created by Zachary Waldowski on 10/3/12.
//  Copyright (c) 2012 Pandamonia LLC. All rights reserved.
//

#import "A2BlockInvocation.h"
#if TARGET_OS_IPHONE
#import <CoreGraphics/CoreGraphics.h>
#endif
#import <objc/runtime.h>
#import <ffi.h>

#pragma mark Block Internals

typedef enum {
    BLOCK_DEALLOCATING =      (0x0001),
    BLOCK_REFCOUNT_MASK =     (0xfffe),
    BLOCK_NEEDS_FREE =        (1 << 24),
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
    BLOCK_HAS_CTOR =          (1 << 26), // helpers have C++ code
    BLOCK_IS_GC =             (1 << 27),
    BLOCK_IS_GLOBAL =         (1 << 28),
    BLOCK_USE_STRET =         (1 << 29), // undefined if !BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE  =    (1 << 30)
} block_flags_t;

typedef enum {
    BLOCK_FIELD_IS_OBJECT   =  3,  // id, NSObject, __attribute__((NSObject)), block, ...
    BLOCK_FIELD_IS_BLOCK    =  7,  // a block variable
    BLOCK_FIELD_IS_BYREF    =  8,  // the on stack structure holding the __block variable
    BLOCK_FIELD_IS_WEAK     = 16,  // declared __weak, only used in byref copy helpers
    BLOCK_BYREF_CALLER      = 128, // called from __block (byref) copy/dispose support routines.
} block_field_flags_t;

struct Block_descriptor_1 {
    unsigned long int reserved;
    unsigned long int size;
};

struct Block_descriptor_2 {
    // requires BLOCK_HAS_COPY_DISPOSE
    void (*copy)(void *dst, const void *src);
    void (*dispose)(const void *);
};

struct Block_descriptor_3 {
    // requires BLOCK_HAS_SIGNATURE
    const char *signature;
    const char *layout;
};

struct Block {
    void *isa;
    block_flags_t flags;
    int reserved;
    void (*invoke)(void);
    struct Block_descriptor_1 *descriptor;
};

static NSMethodSignature *a2_blockGetSignature(id block) {
	struct Block *layout = (__bridge void *)block;

	int requiredFlags = BLOCK_HAS_SIGNATURE;
    if ((layout->flags & requiredFlags) != requiredFlags)
		return nil;

    void *desc = (void *)layout->descriptor;
    desc += sizeof(struct Block_descriptor_1);
    if (layout->flags & BLOCK_HAS_COPY_DISPOSE)
        desc += sizeof(struct Block_descriptor_2);

	struct Block_descriptor_3 *desc3 = (struct Block_descriptor_3 *)desc;
    if (!desc3)
		return nil;

	return [NSMethodSignature signatureWithObjCTypes: desc3->signature];
}

static void (*a2_blockGetInvoke(id block))(void) {
	struct Block *layout = (__bridge void *)block;
	return layout->invoke;
}

#pragma mark - Declarations and macros

#ifndef NSAlwaysAssert
#define NSAlwaysAssert(condition, desc, ...) \
do { if (!(condition)) { [NSException raise: NSInternalInconsistencyException format: [NSString stringWithFormat: @"%s: %@", __PRETTY_FUNCTION__, desc], ## __VA_ARGS__]; } } while(0)
#endif

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

    if (*type == _C_UNDEF) {
        type++;
    } else if (isalpha(*type) || *type == '_') {
        while (isalnum(*type) || *type == '_') {
            type++;
        }
    } else {
        return type;
    }

    if (*type == '=') type++;

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

            if (size > 0) {
                if (size == 1)
                    return &ffi_type_uchar;
                else if (size == 2)
                    return &ffi_type_ushort;
                else if (size <= 4)
                    return &ffi_type_uint;
				else if (size > sizeof(void *))
					return &ffi_type_pointer;
                else {
                    ffi_type *type = allocate(sizeof(ffi_type));
                    type->size = size;
                    type->alignment = align;
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
            if (!strcmp(argumentType, @encode(NSRange))) {
                return &ffi_type_nsrange; break;
            } else if (!strcmp(argumentType, @encode(CGSize))) {
                return &ffi_type_cgsize; break;
            } else if (!strcmp(argumentType, @encode(CGPoint))) {
                return &ffi_type_cgpoint; break;
            } else if (!strcmp(argumentType, @encode(CGRect))) {
                return &ffi_type_cgrect; break;
            }
#if !TARGET_OS_MAC
            if (!strcmp(argumentType, @encode(NSSize))) {
                return &ffi_type_cgsize; break;
            } else if (!strcmp(argumentType, @encode(NSPoint))) {
                return &ffi_type_cgpoint; break;
            } else if (!strcmp(argumentType, @encode(NSRect))) {
                return &ffi_type_cgrect; break;
            }
#endif

			NSUInteger size, align;
            NSGetSizeAndAlignment(argumentType, &size, &align);

            ffi_type *type = allocate(sizeof(ffi_type));
            type->size = size;
            type->alignment = align;
            type->type = FFI_TYPE_STRUCT;
            type->elements = allocate((a2_getStructSize(argumentType) + 1) * sizeof(ffi_type *));

            size_t index = 0;
            argumentType = a2_skipStructName(argumentType);
            while (*argumentType != _C_STRUCT_E) {
                type->elements[index] = a2_typeForSignature(argumentType, allocate);
                argumentType = NSGetSizeAndAlignment(argumentType, NULL, NULL);
                index++;
            }

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
@private
	BOOL _argumentsRetained;
	BOOL _validReturn;
	void **_argumentFrame;
	void *_returnValue;
	size_t _returnLength;
}

@property (nonatomic, copy, readwrite, setter = _a2_setBlock:) id block;
@property (nonatomic, strong) NSMutableSet *allocations;
@property (nonatomic, strong) NSMutableSet *retainedArguments;
@property (nonatomic) ffi_cif interface;

@end

@implementation A2BlockInvocation

+ (A2BlockInvocation *)invocationWithBlock:(id)block {
	NSParameterAssert(block);
    NSMethodSignature *signature = a2_blockGetSignature(block);
	NSAlwaysAssert(signature, @"Incompatible block: %@", block);
	
	A2BlockInvocation *inv = [self alloc];
	if (inv) {
		inv.allocations = [NSMutableSet set];
		void *(^allocate)(size_t) = ^(size_t howmuch){
			NSMutableData *data = [NSMutableData dataWithLength: howmuch];
			[inv.allocations addObject: data];
			return [data mutableBytes];
		};
		
		ffi_type *returnType = a2_typeForSignature(signature.methodReturnType, allocate);
		inv->_returnLength = a2_sizeForType(returnType);
		inv->_returnValue = allocate(inv->_returnLength);

		unsigned int argCount = (unsigned int)signature.numberOfArguments;

		ffi_type **methodArgs = allocate(argCount * sizeof(ffi_type *));
		inv->_argumentFrame = allocate(argCount * sizeof(void *));
		for (NSUInteger i = 0; i < argCount; i++) {
			methodArgs[i] = a2_typeForSignature([signature getArgumentTypeAtIndex: i], allocate);
			inv->_argumentFrame[i] = allocate(a2_sizeForType(methodArgs[i]));
		}

		ffi_cif cif;
		ffi_status status = ffi_prep_cif(&cif, FFI_DEFAULT_ABI, argCount, returnType, methodArgs);
		NSAlwaysAssert(status == FFI_OK, @"%@ -  Unable to create function interface for block: %@", [self class], block);

		inv.interface = cif;
		inv.block = block;
		inv.retainedArguments = [NSMutableSet setWithCapacity: cif.nargs];
		
		void *blockRef = (__bridge void *)inv.block;
		memcpy(inv->_argumentFrame[0], &blockRef, cif.arg_types[0]->size);
	}
	return inv;
}

- (void)dealloc {
	[self setReturnValue: nil];
}

- (NSMethodSignature *)methodSignature {
	return a2_blockGetSignature(self.block);
}

- (void)getReturnValue:(void *)retLoc {
	if (!_validReturn)
		return;
	
	memcpy(retLoc, _returnValue, _returnLength);
}

- (void)setReturnValue:(void *)retLoc {
	ffi_type *returnType = self.interface.rtype;
	if (returnType == &ffi_type_void) {
		return;
	} else if (returnType == &ffi_type_id) {
		if (_validReturn) {
			*(__strong id *)_returnValue = nil;
		} else {
			*(__unsafe_unretained id *)_returnValue = nil;
		}

		id value = nil;
		if (retLoc)
			value = *(__unsafe_unretained id *)retLoc;

		if (value) {
			*(__strong id *)_returnValue = value;
			_validReturn = YES;
		} else {
			*(__unsafe_unretained id *)_returnValue = nil;
			_validReturn = NO;
		}
	} else {
		if (retLoc) {
			memcpy(_returnValue, retLoc, _returnLength);
			_validReturn = YES;
		} else {
			_validReturn = NO;
		}
	}
}

- (void)getArgument:(void *)buffer atIndex:(NSInteger)idx {
	idx++;
	ffi_cif cif = self.interface;
	NSParameterAssert(idx >= 0 && idx < cif.nargs);
	memcpy(buffer, _argumentFrame[idx], a2_sizeForType(cif.arg_types[idx]));
}

- (void)setArgument:(void *)buffer atIndex:(NSInteger)idx {
	idx++;
	
	ffi_cif cif = self.interface;
	NSParameterAssert(idx >= 0 && idx < cif.nargs);

	if (_argumentsRetained) {
		ffi_type *type = cif.arg_types[idx];
		if (type == &ffi_type_id) {
			id old = *(__unsafe_unretained id *)_argumentFrame[idx];
			if (old)
				[self.retainedArguments removeObject: old];

			id new = *(__unsafe_unretained id *)buffer;
			if (new)
				[self.retainedArguments addObject: new];
		} else if (type == &ffi_type_charptr) {
			char *old = *(char **)_argumentFrame[idx];
			if (old)
				free(old);
			
			char *new = *(char**)buffer;
			if (new) {
				size_t len = strlen(new);
				char *tmp = malloc(len + 1);
				strncpy(tmp, new, len);
				tmp[len] = '\0';
				buffer = tmp;
			}
		}
	}
	
	memcpy(_argumentFrame[idx], buffer, a2_sizeForType(cif.arg_types[idx]));
}

- (void)retainArguments {
	if (!_argumentsRetained) {
		ffi_cif cif = self.interface;

		for (NSUInteger i = 1; i < cif.nargs; i++) {
			if (cif.arg_types[i] != &ffi_type_id)
				continue;

			id argument = *(__unsafe_unretained id *)_argumentFrame[i];
			if (argument)
				[self.retainedArguments addObject: argument];
		}
		
		_argumentsRetained = YES;
	}
}

- (BOOL)argumentsRetained {
	return _argumentsRetained;
}

- (void)invoke {
	ffi_cif cif = self.interface;
	void *returnValue = malloc(_returnLength);
	ffi_call(&cif, a2_blockGetInvoke(self.block), returnValue, _argumentFrame);
	[self setReturnValue: returnValue];
	free(returnValue);
}

- (void)invokeUsingInvocation:(NSInvocation *)inv {
	if (![inv isMemberOfClass: [NSInvocation class]])
		return;

	[inv retainArguments];

	void *argument = NULL;
	for (int i = 0; i < self.interface.nargs - 1; i++) {
		size_t argSize = a2_sizeForType(self.interface.arg_types[i]);
		argument = realloc(argument, argSize);
		[inv getArgument: argument atIndex: i + 2];
		[self setArgument: argument atIndex: i];
	}

	[self invoke];

	if (_returnLength) {
		argument = realloc(argument, _returnLength);
		[self getReturnValue: argument];
		[inv setReturnValue: argument];
	}
	
	if (argument)
		free(argument);
}

- (void)clearArguments {
	for (int i = 0; i < self.interface.nargs - 1; i++) {
		[self setArgument: 0 atIndex: i];
	}
}

#pragma mark - Unavailable methods

+ (NSInvocation *)invocationWithMethodSignature:(NSMethodSignature *)sig {
	[self doesNotRecognizeSelector: _cmd];
	return nil;
}

- (id)target {
	[self doesNotRecognizeSelector: _cmd];
	return nil;
}

- (void)setTarget:(id)target {
	[self doesNotRecognizeSelector: _cmd];
}

- (SEL)selector {
	[self doesNotRecognizeSelector: _cmd];
	return NULL;
}

- (void)setSelector:(SEL)selector {
	[self doesNotRecognizeSelector: _cmd];
}

- (void)invokeWithTarget:(id)target {
	[self doesNotRecognizeSelector: _cmd];
}

@end
