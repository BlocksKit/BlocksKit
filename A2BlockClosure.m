//
//  A2BlockClosure.m
//  A2DynamicDelegate
//
//  Created by Michael Ash on 9/17/10.
//  Copyright (c) 2010 Michael Ash. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//    * Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in the
//      documentation and/or other materials provided with the distribution.
//    * Neither the name of the  nor the
//      names of its contributors may be used to endorse or promote products
//      derived from this software without specific prior written permission.
//


#import "A2BlockClosure.h"
#import "A2BlockImplementation.h"

#if TARGET_OS_IPHONE
#import <CoreGraphics/CoreGraphics.h>
#endif

#ifndef NSAlwaysAssert
#define NSAlwaysAssert(condition, desc, ...) \
do { if (!(condition)) { [NSException raise: NSInternalInconsistencyException format: [NSString stringWithFormat: @"%s: %@", __PRETTY_FUNCTION__, desc], ## __VA_ARGS__]; } } while(0)
#endif

@interface A2BlockClosure ()

@property (nonatomic, readonly) ffi_cif *callInterface;
@property (nonatomic, readonly) NSUInteger numberOfArguments;

@end

static const char *a2_getSizeAndAlignment(const char *str)
{
    const char *out = NSGetSizeAndAlignment(str, NULL, NULL);
    while(isdigit(*out))
        out++;
    return out;
}

static int a2_getArgumentsCount(const char *str)
{
    int argcount = -2; // return type is the first one
    while(str && *str)
    {
        str = a2_getSizeAndAlignment(str);
        argcount++;
    }
    return argcount;
}

static void a2_executeBlockClosure(ffi_cif *cif, void *ret, void **args, void *userdata)
{
    A2BlockClosure *self = userdata;
    int count = self.numberOfArguments;
    void **innerArgs = malloc((count + 1) * sizeof(*innerArgs));
	
    innerArgs[0] = self.block;
    memcpy(innerArgs + 1, args + 2, count * sizeof(*args));
    ffi_call(self.callInterface, a2_blockGetImplementation(self.block), ret, innerArgs);
	
    free(innerArgs);
}

static const char *a2_skip_type_qualifiers(const char *types)
{
	while (*types == '+'
		   || *types == '-'
		   || *types == 'r'
		   || *types == 'n'
		   || *types == 'N'
		   || *types == 'o'
		   || *types == 'O'
		   || *types == 'R'
		   || *types == 'V'
		   || *types == '!'
		   || isdigit ((unsigned char) *types))
    {
		types++;
    }
	
	return types;
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

- (ffi_type *)a2_typeForEncoding: (const char *)typePtr advance:(const char **)advance {
	const char *type = NULL;
	ffi_type *ftype = NULL;
	
	typePtr = a2_skip_type_qualifiers(typePtr);
	type = typePtr;
	
	/*
	 *	Scan for size and alignment information.
	 */
	switch (*typePtr++)
    {
		case _C_ID:
		case _C_CLASS:
		case _C_SEL:
		case _C_ATOM:
		case _C_CHARPTR:
			ftype = &ffi_type_pointer;
			break;
		case _C_CHR: ftype = &ffi_type_schar;
			break;
		case _C_BOOL:
		case _C_UCHR: ftype = &ffi_type_uchar;
			break;
		case _C_SHT: ftype = &ffi_type_sshort;
			break;
		case _C_USHT: ftype = &ffi_type_ushort;
			break;
		case _C_INT: ftype = &ffi_type_sint;
			break;
		case _C_UINT: ftype = &ffi_type_uint;
			break;
		case _C_LNG: ftype = sizeof(int) == sizeof(long) ? &ffi_type_sint : &ffi_type_slong;
			break;
		case _C_ULNG: ftype = sizeof(unsigned int) == sizeof(unsigned long) ? &ffi_type_uint : &ffi_type_ulong;
			break;
#ifdef	_C_LNG_LNG
		case _C_LNG_LNG: ftype = &ffi_type_sint64;
			break;
#endif
#ifdef _C_ULNG_LNG
		case _C_ULNG_LNG: ftype = &ffi_type_uint64;
			break;
#endif
		case _C_FLT: ftype = &ffi_type_float;
			break;
		case _C_DBL: ftype = &ffi_type_double;
			break;
		case _C_BFLD:
		{
			NSUInteger size, i;
			NSGetSizeAndAlignment(type, &size, 0);
			
			if (size > 0) {
				if (size == 1)
					ftype = &ffi_type_uchar;
				else if (size == 2)
					ftype = &ffi_type_ushort;
				else if (size <= 4)
					ftype = &ffi_type_uint; 
				else {
					
					ftype = (ffi_type *)[self a2_allocate:sizeof(ffi_type)];
					ftype->size = size;
					ftype->alignment = 0;
					ftype->type = FFI_TYPE_STRUCT;
					ftype->elements = [self a2_allocate:size * sizeof(ffi_type *)];
					for (i = 0; i < size; i++)
						ftype->elements[i] = &ffi_type_uchar;
				}
			}
		}
			break;
		case _C_PTR:
			ftype = &ffi_type_pointer;
			if (*typePtr == '?')
			{
				typePtr++;
			}
			else
			{
				const char *adv;
				[self a2_typeForEncoding:typePtr advance:&adv];
				typePtr = adv;
			}
			break;
			
		case _C_ARY_B:
		{
			const char *adv;
			ftype = &ffi_type_pointer;
			
			while (isdigit(*typePtr))
			{
				typePtr++;
			}
			[self a2_typeForEncoding:typePtr advance:&adv];
			typePtr = adv;
			typePtr++;	/* Skip end-of-array	*/
		}
			break;
			
		case _C_STRUCT_B:
		{
			int types, maxtypes, size;
			ffi_type *local;
			const char *adv;
			unsigned   align = __alignof(double);
			
			/*
			 *	Skip "<name>=" stuff.
			 */
			while (*typePtr != _C_STRUCT_E)
			{
				if (*typePtr++ == '=')
				{
					break;
				}
			}
			
			types = 0;
			maxtypes = 4;
			size = sizeof(ffi_type);
			if (size % align != 0)
			{
				size += (align - (size % align));
			}
			
			NSMutableData *data = [NSMutableData dataWithLength:size + (maxtypes+1)*sizeof(ffi_type)];
			ftype = data.mutableBytes;
			ftype->size = 0;
			ftype->alignment = 0;
			ftype->type = FFI_TYPE_STRUCT;
			ftype->elements = (void*)ftype + size;
			/*
			 *	Continue accumulating structure size.
			 */
			while (*typePtr != _C_STRUCT_E)
			{
				local = [self a2_typeForEncoding:typePtr advance:&adv];
				typePtr = adv;
				NSCAssert(typePtr, @"End of signature while parsing");
				ftype->elements[types++] = local;
				if (types >= maxtypes)
				{
					[data setLength:size + (types+1)*sizeof(ffi_type)];
					ftype = (void *)data.mutableBytes;
					ftype->elements = (void*)ftype + size;
				}
			}
			ftype->elements[types] = NULL;
			typePtr++;	/* Skip end-of-struct	*/
			[_allocations addObject:data];
		}
			break;
			
		case _C_UNION_B:
		{
			const char *adv;
			int	max_align = 0;
			
			/*
			 *	Skip "<name>=" stuff.
			 */
			while (*typePtr != _C_UNION_E)
			{
				if (*typePtr++ == '=')
				{
					break;
				}
			}
			ftype = NULL;
			while (*typePtr != _C_UNION_E)
			{
				ffi_type *local;
				NSUInteger align;
				NSGetSizeAndAlignment(typePtr, NULL, &align);
				local = [self a2_typeForEncoding:typePtr advance:&adv];
				typePtr = adv;
				NSCAssert(typePtr, @"End of signature while parsing");
				if (align > max_align)
				{
					if (ftype && ftype->type == FFI_TYPE_STRUCT)
						free(ftype);
					ftype = local;
					max_align = align;
				}
			}
			typePtr++;	/* Skip end-of-union	*/
		}
			break;
			
		case _C_VOID: ftype = &ffi_type_void;
			break;
		default:
			ftype = &ffi_type_void;
			NSCAssert(0, @"Unknown type in sig");
    }
	
	/* Skip past any offset information, if there is any */
	if (*type != _C_PTR || *type == '?')
    {
		if (*typePtr == '+')
			typePtr++;
		if (*typePtr == '-')
			typePtr++;
		while (isdigit(*typePtr))
			typePtr++;
    }
	if (advance)
		*advance = typePtr;
	
	return ftype;
}

- (void)a2_prepareCIF {
	const char *signature = a2_blockGetSignature(self.block);
	int argCount = a2_getArgumentsCount(signature);
	int blockArgCount = argCount + 1, methodArgCount = argCount + 2;
	
	ffi_type **blockArgs = [self a2_allocate: blockArgCount * sizeof(ffi_type *)];
	ffi_type **methodArgs = [self a2_allocate: methodArgCount * sizeof(ffi_type *)];

	blockArgs[0] = methodArgs[0] = methodArgs[1] = &ffi_type_pointer;
	
	ffi_type *rtype = [self a2_typeForEncoding:signature advance:&signature];
    
    int argc = -2, bargc = 1, margc = 2;
    while (signature && *signature) {
        const char *next = a2_getSizeAndAlignment(signature);
        if (argc) {
            blockArgs[bargc] = methodArgs[margc] = [self a2_typeForEncoding: signature advance: NULL];
			bargc++;
			margc++;
		}
        argc++;
        signature = next;
    }
	
	ffi_cif blockCif;
    ffi_status blockStatus = ffi_prep_cif(&blockCif, FFI_DEFAULT_ABI, blockArgCount, rtype, blockArgs);
	
	ffi_cif methodCif;
	ffi_status methodStatus = ffi_prep_cif(&methodCif, FFI_DEFAULT_ABI, methodArgCount, rtype, methodArgs);
	
	NSAssert(blockStatus == FFI_OK, @"Unable to create function interface for block. %@ %@", [self class], self.block);
	NSAssert(methodStatus == FFI_OK, @"Unable to create function interface for method. %@ %@", [self class], self.block);
	
	_closureCIF = methodCif;
	_innerCIF = blockCif;
	_numberOfArguments = blockArgCount;
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