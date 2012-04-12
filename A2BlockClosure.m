//
//  A2BlockClosure.m
//  A2DynamicDelegate
//
//  Created by Michael Ash on 9/17/10.
//  Copyright (c) 2010 Michael Ash. All rights reserved.
//  Licensed under BSD.
//

#import "A2BlockClosure.h"
#import "A2BlockImplementation.h"
#if TARGET_OS_IPHONE
#import <CoreGraphics/CoreGraphics.h>
#endif
#import <objc/runtime.h>

#ifndef NSAlwaysAssert
#define NSAlwaysAssert(condition, desc, ...) \
do { if (!(condition)) { [NSException raise: NSInternalInconsistencyException format: [NSString stringWithFormat: @"%s: %@", __PRETTY_FUNCTION__, desc], ## __VA_ARGS__]; } } while(0)
#endif

@interface A2BlockClosure ()

@property (nonatomic, readonly) ffi_cif *callInterface;
@property (nonatomic, readonly) NSUInteger numberOfArguments;

@end

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

static void a2_executeBlockClosure(ffi_cif *cif, void *ret, void **args, void *userdata)
{
    A2BlockClosure *self = userdata;
    int count = self.numberOfArguments;
    void **innerArgs = malloc(count * sizeof(*innerArgs));
	
    innerArgs[0] = self.block;
    memcpy(innerArgs + 1, args + 2, (count - 1) * sizeof(*args));
    a2_ffi_call_block(self.callInterface, self.block, ret, innerArgs);
	
    free(innerArgs);
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

@implementation A2BlockClosure

@synthesize block = _block, functionPointer = _functionPointer, numberOfArguments = _numberOfArguments;

- (ffi_cif *)callInterface {
	return &_blockCIF;
}

- (void *)a2_allocate: (size_t)howmuch
{
    NSMutableData *data = [NSMutableData dataWithLength: howmuch];
    [_allocations addObject: data];
    return [data mutableBytes];
}

- (ffi_type *) a2_typeForSignature:(const char *)argumentType {
    
    ffi_type *type = NULL;
    
    switch (*argumentType) {
        case _C_ID:
        case _C_CLASS:
        case _C_SEL:
        case _C_ATOM:
        case _C_CHARPTR:
        case _C_PTR:
            type = &ffi_type_pointer; break;
		case _C_BOOL:
		case _C_UCHR:
            type = &ffi_type_uchar; break;
        case _C_CHR: type = &ffi_type_schar; break;
		case _C_SHT: type = &ffi_type_sshort; break;
		case _C_USHT: type = &ffi_type_ushort; break;
		case _C_INT: type = &ffi_type_sint; break;
		case _C_UINT: type = &ffi_type_uint; break;
		case _C_LNG: type = sizeof(int) == sizeof(long) ? &ffi_type_sint : &ffi_type_slong; break;
		case _C_ULNG: type = sizeof(unsigned int) == sizeof(unsigned long) ? &ffi_type_uint : &ffi_type_ulong; break;
		case _C_LNG_LNG: type = &ffi_type_sint64; break;
		case _C_ULNG_LNG: type = &ffi_type_uint64; break;
		case _C_FLT: type = &ffi_type_float; break;
		case _C_DBL: type = &ffi_type_double; break;
		case _C_VOID: type = &ffi_type_void; break;
        case _C_BFLD:
        case _C_ARY_B:
        {
            NSUInteger size, align;
            
            NSGetSizeAndAlignment(argumentType, &size, &align);
            
            if (size > 0) {
                if (size == 1)
                    type = &ffi_type_uchar;
                else if (size == 2)
                    type = &ffi_type_ushort;
                else if (size <= 4)
                    type = &ffi_type_uint; 
                else {
                    type = [self a2_allocate: sizeof(ffi_type)];
                    type->size = size;
                    type->alignment = align;
                    type->type = FFI_TYPE_STRUCT;
                    type->elements = [self a2_allocate: (size + 1) * sizeof(ffi_type *)];
                    for (NSUInteger i = 0; i < size; i++)
                        type->elements[i] = &ffi_type_uchar;
                    type->elements[size] = NULL;
                }
                break;
            }
        }
        case _C_STRUCT_B:
        {
            if (!strcmp(argumentType, @encode(NSRange))) {
                type = &ffi_type_nsrange; break;
            } else if (!strcmp(argumentType, @encode(CGSize))) {
                type = &ffi_type_cgsize; break;
            } else if (!strcmp(argumentType, @encode(CGPoint))) {
                type = &ffi_type_cgpoint; break;
            } else if (!strcmp(argumentType, @encode(CGRect))) {
                type = &ffi_type_cgrect; break;
            }
#if !TARGET_OS_MAC
            else if (!strcmp(argumentType, @encode(NSSize))) {
                type = &ffi_type_cgsize; break;
            } else if (!strcmp(argumentType, @encode(NSPoint))) {
                type = &ffi_type_cgpoint; break;
            } else if (!strcmp(argumentType, @encode(NSRect))) {
                type = &ffi_type_cgrect; break;
            }
#endif
                        
            type = [self a2_allocate: sizeof(ffi_type)];
            type->size = 0;
            type->alignment = 0;
            type->type = FFI_TYPE_STRUCT;
            type->elements = [self a2_allocate: (a2_getStructSize(argumentType) + 1) * sizeof(ffi_type *)];
            
            size_t index = 0;
            while (*argumentType != _C_STRUCT_E && *argumentType != '=') argumentType++;
            if (*argumentType == '=') {
                argumentType++;
                while (*argumentType != _C_STRUCT_E) {
                    type->elements[index] = [self a2_typeForSignature:argumentType];
                    argumentType = NSGetSizeAndAlignment(argumentType, NULL, NULL);
                    index++;
                }
            }
            type->elements[index] = NULL;

            break;
        }
        default:
        {
            type = &ffi_type_void;
			NSCAssert(0, @"Unknown type in sig");
            break;
        }
    }
    return type;
}

- (id)initWithBlock: (id) block methodSignature: (NSMethodSignature *) signature
{
    if ((self = [self init]))
    {
        NSAlwaysAssert(a2_blockIsCompatible(block, signature), @"Attempt to implement a method with incompatible block");
        
        _allocations = [NSMutableArray new];
        _block = [block copy];
		_closure = ffi_closure_alloc(sizeof(ffi_closure), &_functionPointer);
        
        NSUInteger blockArgCount = signature.numberOfArguments - 1, methodArgCount = signature.numberOfArguments;
        ffi_cif blockCif, methodCif;
        
        ffi_type **blockArgs = [self a2_allocate: blockArgCount * sizeof(ffi_type *)];
        ffi_type **methodArgs = [self a2_allocate: methodArgCount * sizeof(ffi_type *)];
        ffi_type *returnType = [self a2_typeForSignature: signature.methodReturnType];
        
        blockArgs[0] = methodArgs[0] = methodArgs[1] = &ffi_type_pointer;
        
        for (NSUInteger i = 2; i < signature.numberOfArguments; i++) {
            blockArgs[i-1] = methodArgs[i] = [self a2_typeForSignature: [signature getArgumentTypeAtIndex: i]];
        }
        
        ffi_status blockStatus = ffi_prep_cif(&blockCif, FFI_DEFAULT_ABI, blockArgCount, returnType, blockArgs);
        ffi_status methodStatus = ffi_prep_cif(&methodCif, FFI_DEFAULT_ABI, methodArgCount, returnType, methodArgs);
        
        NSAssert(blockStatus == FFI_OK, @"Unable to create function interface for block. %@ %@", [self class], self.block);
        NSAssert(methodStatus == FFI_OK, @"Unable to create function interface for method. %@ %@", [self class], self.block);
        
        _methodCIF = methodCif;
        _blockCIF = blockCif;
        _numberOfArguments = blockArgCount;
        
        if (ffi_prep_closure_loc(_closure, &_methodCIF, a2_executeBlockClosure, self, _functionPointer) != FFI_OK) {
            [self release];
            return nil;
        }
    }
    return self;
}

- (void)dealloc
{
    if(_closure)
        ffi_closure_free(_closure); _closure = NULL;
	[_block release];
    [_allocations release];
    [super dealloc];
}

@end