//
//  A2BlockClosure.m
//  A2DynamicDelegate
//

#import "A2BlockClosure.h"
#if TARGET_OS_IPHONE
#import <CoreGraphics/CoreGraphics.h>
#endif
#import <objc/runtime.h>
#import <ffi.h>

#pragma mark - Block Internals

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
    // imported variables
};

typedef struct Block *BlockRef;

#pragma mark - Declarations and macros

#ifndef NSAlwaysAssert
#define NSAlwaysAssert(condition, desc, ...) \
do { if (!(condition)) { [NSException raise: NSInternalInconsistencyException format: [NSString stringWithFormat: @"%s: %@", __PRETTY_FUNCTION__, desc], ## __VA_ARGS__]; } } while(0)
#endif

#pragma mark - Core Graphics FFI types

const ffi_type *_ffi_type_elements_nsrange[] = { &ffi_type_ulong, &ffi_type_ulong, NULL };
ffi_type ffi_type_nsrange = { 0, 0, FFI_TYPE_STRUCT, (ffi_type **)_ffi_type_elements_nsrange };

#if CGFLOAT_IS_DOUBLE
const ffi_type *_ffi_type_elements_cgpoint[] = { &ffi_type_double, &ffi_type_double, NULL };
const ffi_type *_ffi_type_elements_cgsize[] = { &ffi_type_double, &ffi_type_double, NULL };
#else
const ffi_type *_ffi_type_elements_cgpoint[] = { &ffi_type_float, &ffi_type_float, NULL };
const ffi_type *_ffi_type_elements_cgsize[] = { &ffi_type_float, &ffi_type_float, NULL };
#endif

ffi_type ffi_type_cgpoint = { 0, 0, FFI_TYPE_STRUCT, (ffi_type **)_ffi_type_elements_cgpoint };
ffi_type ffi_type_cgsize = { 0, 0, FFI_TYPE_STRUCT, (ffi_type **)_ffi_type_elements_cgsize };

const ffi_type *_ffi_type_elements_cgrect[] = { &ffi_type_cgpoint, &ffi_type_cgsize, NULL };
ffi_type ffi_type_cgrect = { 0, 0, FFI_TYPE_STRUCT, (ffi_type **)_ffi_type_elements_cgrect };

#pragma mark - Helper functions

static NSMethodSignature *a2_blockGetSignature(id block) {
	BlockRef layout = (__bridge void *)block;
	
	int requiredFlags = BLOCK_HAS_SIGNATURE;
    if ((layout->flags & requiredFlags) != requiredFlags)
		return nil;
	
    uint8_t *desc = (uint8_t *)layout->descriptor;
    desc += sizeof(struct Block_descriptor_1);
    if (layout->flags & BLOCK_HAS_COPY_DISPOSE)
        desc += sizeof(struct Block_descriptor_2);
    
	struct Block_descriptor_3 *desc3 = (struct Block_descriptor_3 *)desc;
    if (!desc3)
		return nil;

	const char *signature = desc3->signature;
	return [NSMethodSignature signatureWithObjCTypes: signature];
}

BOOL a2_blockIsCompatible(id block, NSMethodSignature *signature);

BOOL a2_blockIsCompatible(id block, NSMethodSignature *signature) {
    NSMethodSignature *blockSig = a2_blockGetSignature(block);
	if (!blockSig)
		return NO;
	
    BOOL isCompatible = (strcmp(blockSig.methodReturnType, signature.methodReturnType) == 0);
    NSUInteger i, argc = blockSig.numberOfArguments;
    for (i = 1; i < argc && isCompatible; ++i)
    {
        // `i + 1` because the protocol method sig has an extra ":" (selector) argument
        const char *firstArgType = [blockSig getArgumentTypeAtIndex: i];
        const char *secondArgType = [signature getArgumentTypeAtIndex: i + 1];
        
        if (strcmp(secondArgType, firstArgType))
            isCompatible = NO;
    }
    return isCompatible;
}

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

static inline size_t a2_getStructSize(const char *encodingType) {
    if (*encodingType != _C_STRUCT_B) return -1;
    while (*encodingType != _C_STRUCT_E && *encodingType++ != '='); // skip "<name>="
    
    size_t ret = 0;
    while (*encodingType != _C_STRUCT_E) {
        encodingType = NSGetSizeAndAlignment(encodingType, NULL, NULL);
        ret++;
    }
    
    return ret;
}

#pragma mark -

@implementation A2BlockClosure

- (void *)a2_allocate: (size_t)howmuch
{
    NSMutableData *data = [NSMutableData dataWithLength: howmuch];
    [_allocations addObject: data];
    return [data mutableBytes];
}

- (ffi_type *) a2_typeForSignature:(const char *)argumentType {
    switch (*argumentType) {
        case _C_ID:
        case _C_CLASS:
        case _C_SEL:
        case _C_ATOM:
        case _C_CHARPTR:
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
                else {
                    ffi_type *type = [self a2_allocate: sizeof(ffi_type)];
                    type->size = size;
                    type->alignment = align;
                    type->type = FFI_TYPE_STRUCT;
                    type->elements = [self a2_allocate: (size + 1) * sizeof(ffi_type *)];
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

            ffi_type *type = [self a2_allocate: sizeof(ffi_type)];
            type->size = 0;
            type->alignment = 0;
            type->type = FFI_TYPE_STRUCT;
			
            type->elements = [self a2_allocate: (a2_getStructSize(argumentType) + 1) * sizeof(ffi_type *)];

            size_t index = 0;
            argumentType = a2_skipStructName(argumentType);
            while (*argumentType != _C_STRUCT_E) {
                type->elements[index] = [self a2_typeForSignature:argumentType];
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

- (id)initWithBlock: (id) block methodSignature: (NSMethodSignature *) signature {
	if ((self = [super init])) {
		self.block = [block copy];
		self.methodSignature = signature;
		_allocations = [NSMutableArray new];

		unsigned int blockArgCount = (unsigned int)signature.numberOfArguments - 1;
		ffi_cif blockCif;

		ffi_type **methodArgs = [self a2_allocate: blockArgCount * sizeof(ffi_type *)];
		ffi_type *returnType = [self a2_typeForSignature: signature.methodReturnType];
		methodArgs[0] = &ffi_type_pointer;

		for (unsigned int i = 2; i < signature.numberOfArguments; i++) {
			methodArgs[i - 1] = [self a2_typeForSignature: [signature getArgumentTypeAtIndex: i]];
		}

		ffi_status status = ffi_prep_cif(&blockCif, FFI_DEFAULT_ABI, blockArgCount, returnType, methodArgs);

		NSAlwaysAssert(status == FFI_OK, @"Unable to create function interface for block. %@ %@", [self class], self.block);

		_functionInterface = malloc(sizeof(ffi_cif));
		*(ffi_cif *)_functionInterface = blockCif;
	}
	return self;
}

- (void)dealloc
{
    if (_functionInterface)
        free(_functionInterface);
}

- (void)a2_callWithArguments:(void **)args return:(void **)retVal
{
	ffi_cif *cif = _functionInterface;
	void (*blockInvocation)(void) = self.function;
	void *ret = NULL;
	ffi_call(cif, blockInvocation, &ret, args);
	*retVal = ret;
}

- (void)callWithInvocation:(NSInvocation *)invoc
{
	NSAlwaysAssert([_methodSignature isEqual: invoc.methodSignature], @"Invocation isn't compatible with block: %s", invoc.selector);

	ffi_cif *cif = _functionInterface;

	[invoc retainArguments];
	void **arguments = calloc(cif->nargs, sizeof(void *));

	arguments[0] = &_block;
	for (int i = 1; i < cif->nargs; i++) {
		NSMutableData *argData = [NSMutableData dataWithCapacity: cif->arg_types[i]->size];
		[invoc getArgument: argData.mutableBytes atIndex: i + 1];
		arguments[i] = argData.mutableBytes;
	}

	void *result = NULL;
	[self a2_callWithArguments: arguments return: &result];
	if (invoc.methodSignature.methodReturnLength)
		[invoc setReturnValue: &result];
	free(arguments);
}

- (void(*)(void))function {
	BlockRef layout = (__bridge void *)_block;
	return layout->invoke;
}

@end