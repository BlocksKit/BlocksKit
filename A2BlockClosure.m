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

#if __has_attribute(objc_arc)
#error "At present, 'A2BlockClosure.m' may not be compiled with ARC. This is a limitation of the Obj-C runtime library. See here: http://j.mp/tJsoOV"
#endif

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

static inline const char *a2_blockGetSignature(id block) {
	BlockRef layout = (void *)block;
	
	int requiredFlags = BLOCK_HAS_SIGNATURE;
    if ((layout->flags & requiredFlags) != requiredFlags)
		return NULL;
	
    uint8_t *desc = (uint8_t *)layout->descriptor;
    desc += sizeof(struct Block_descriptor_1);
    if (layout->flags & BLOCK_HAS_COPY_DISPOSE)
        desc += sizeof(struct Block_descriptor_2);
    
	struct Block_descriptor_3 *desc3 = (struct Block_descriptor_3 *)desc;
    if (!desc3)
		return NULL;
    
    return desc3->signature;
}

BOOL a2_blockIsCompatible(id block, NSMethodSignature *signature);

BOOL a2_blockIsCompatible(id block, NSMethodSignature *signature) {
    NSMethodSignature *blockSig = [NSMethodSignature signatureWithObjCTypes: a2_blockGetSignature(block)];
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

#pragma mark - FFI closure function

static void a2_executeArgumentsOnlyBlock(ffi_cif *cif, void *ret, void **args, void *userdata) {
    A2BlockClosure *self = userdata;
    BlockRef block = (void *)(self->_block);
    
    void **innerArgs = args + 1;
    innerArgs[0] = &block;
    ffi_call(self->_blockCIF, block->invoke, ret, innerArgs);
}

#pragma mark -

@implementation A2BlockClosure

@synthesize block = _block, functionPointer = _functionPointer;

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

- (id)initWithBlock: (id) block methodSignature: (NSMethodSignature *) signature
{
    if ((self = [super init]))
    {
        _allocations = [NSMutableArray new];
        _block = [block copy];
		_closure = ffi_closure_alloc(sizeof(ffi_closure), &_functionPointer);
        
        unsigned int methodArgCount = (unsigned int)signature.numberOfArguments, blockArgCount = (unsigned int)signature.numberOfArguments - 1;
        ffi_cif methodCif, blockCif;
        
        ffi_type **methodArgs = [self a2_allocate: methodArgCount * sizeof(ffi_type *)];
        ffi_type *returnType = [self a2_typeForSignature: signature.methodReturnType];
        
        methodArgs[0] = methodArgs[1] = &ffi_type_pointer;
        
        for (unsigned int i = 2; i < signature.numberOfArguments; i++) {
            methodArgs[i] = [self a2_typeForSignature: [signature getArgumentTypeAtIndex: i]];
        }
        
        ffi_type **blockArgs = methodArgs + 1;
        
        ffi_status methodStatus = ffi_prep_cif(&methodCif, FFI_DEFAULT_ABI, methodArgCount, returnType, methodArgs);
        ffi_status blockStatus = ffi_prep_cif(&blockCif, FFI_DEFAULT_ABI, blockArgCount, returnType, blockArgs);
        
        NSAlwaysAssert(methodStatus == FFI_OK, @"Unable to create function interface for method. %@ %@", [self class], self.block);
        NSAlwaysAssert(blockStatus == FFI_OK, @"Unable to create function interface for block. %@ %@", [self class], self.block);
        
        _methodCIF = malloc(sizeof(ffi_cif));
        *(ffi_cif *)_methodCIF = methodCif;
        
        _blockCIF =  malloc(sizeof(ffi_cif));
        *(ffi_cif *)_blockCIF = blockCif;
        
        ffi_status status = ffi_prep_closure_loc(_closure, _methodCIF, a2_executeArgumentsOnlyBlock, self, _functionPointer);
        
        NSAlwaysAssert(status == FFI_OK, @"Unable to create function closure for block. %@ %@", [self class], self.block);
    }
    return self;
}

- (void)dealloc
{
    if(_closure)
        ffi_closure_free(_closure);
    if (_methodCIF)
        free(_methodCIF);
    if (_blockCIF)
        free(_blockCIF);
    [_allocations release];
	[_block release];
    [super dealloc];
}

@end