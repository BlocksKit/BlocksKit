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

@implementation A2BlockClosure

@synthesize block = _block, functionPointer = _functionPointer, numberOfArguments = _numberOfArguments;

- (ffi_cif *)callInterface {
	return &_innerCIF;
}

- (void *)a2_allocate: (size_t)howmuch
{
    NSMutableData *data = [NSMutableData dataWithLength: howmuch];
    [_allocations addObject: data];
    return [data mutableBytes];
}

- (ffi_type *)a2_argumentForEncoding: (const char *)str
{
    #define SINT(type) do { \
    	if(str[0] == @encode(type)[0]) \
    	{ \
    	   if(sizeof(type) == 1) \
    	       return &ffi_type_sint8; \
    	   else if(sizeof(type) == 2) \
    	       return &ffi_type_sint16; \
    	   else if(sizeof(type) == 4) \
    	       return &ffi_type_sint32; \
    	   else if(sizeof(type) == 8) \
    	       return &ffi_type_sint64; \
    	   else \
    	   { \
    	       NSLog(@"Unknown size for type %s", #type); \
    	       abort(); \
    	   } \
        } \
    } while(0)
    
    #define UINT(type) do { \
    	if(str[0] == @encode(type)[0]) \
    	{ \
    	   if(sizeof(type) == 1) \
    	       return &ffi_type_uint8; \
    	   else if(sizeof(type) == 2) \
    	       return &ffi_type_uint16; \
    	   else if(sizeof(type) == 4) \
    	       return &ffi_type_uint32; \
    	   else if(sizeof(type) == 8) \
    	       return &ffi_type_uint64; \
    	   else \
    	   { \
    	       NSLog(@"Unknown size for type %s", #type); \
    	       abort(); \
    	   } \
        } \
    } while(0)
    
    #define INT(type) do { \
        SINT(type); \
        UINT(unsigned type); \
    } while(0)
    
    #define COND(type, name) do { \
        if(str[0] == @encode(type)[0]) \
            return &ffi_type_ ## name; \
    } while(0)
    
    #define PTR(type) COND(type, pointer)
    
    #define STRUCT(structType, ...) do { \
        if(strncmp(str, @encode(structType), strlen(@encode(structType))) == 0) \
        { \
           ffi_type *elementsLocal[] = { __VA_ARGS__, NULL }; \
           ffi_type **elements = [self a2_allocate: sizeof(elementsLocal)]; \
           memcpy(elements, elementsLocal, sizeof(elementsLocal)); \
            \
           ffi_type *structType = [self a2_allocate: sizeof(*structType)]; \
           structType->type = FFI_TYPE_STRUCT; \
           structType->elements = elements; \
           return structType; \
        } \
    } while(0)
    
    SINT(_Bool);
    SINT(signed char);
    UINT(unsigned char);
    INT(short);
    INT(int);
    INT(long);
    INT(long long);
    
    PTR(id);
    PTR(Class);
    PTR(SEL);
    PTR(void *);
    PTR(char *);
    PTR(void (*)(void));
    
    COND(float, float);
    COND(double, double);
    
    COND(void, void);
    
    ffi_type *CGFloatFFI = sizeof(CGFloat) == sizeof(float) ? &ffi_type_float : &ffi_type_double;
    STRUCT(CGRect, CGFloatFFI, CGFloatFFI, CGFloatFFI, CGFloatFFI);
    STRUCT(CGPoint, CGFloatFFI, CGFloatFFI);
    STRUCT(CGSize, CGFloatFFI, CGFloatFFI);
	
	ffi_type *NSUIntegerFFI = sizeof(NSUInteger) == sizeof(unsigned long) ? &ffi_type_ulong : &ffi_type_uint;
	STRUCT(NSRange, NSUIntegerFFI, NSUIntegerFFI);
    
#if !TARGET_OS_IPHONE
    STRUCT(NSRect, CGFloatFFI, CGFloatFFI, CGFloatFFI, CGFloatFFI);
    STRUCT(NSPoint, CGFloatFFI, CGFloatFFI);
    STRUCT(NSSize, CGFloatFFI, CGFloatFFI);
#endif
    
    NSLog(@"Unknown encode string %s", str);
    abort();
}

- (ffi_cif)a2_prepareCIFWithEncoding:(const char *)str forBlock: (BOOL)isBlock arguments:(NSUInteger *)count {
	int argCount = a2_getArgumentsCount(str) + (isBlock ? 1 : 2);
    ffi_type **argTypes = [self a2_allocate: argCount * sizeof(*argTypes)];
	
	argTypes[0] = [self a2_argumentForEncoding: @encode(id)];
	
	if (!isBlock)
		argTypes[1] = [self a2_argumentForEncoding: @encode(SEL)];
	
	ffi_type *rtype;
    
    int i = -2, j = isBlock ? 1 : 2;
    while(str && *str)
    {
        const char *next = a2_getSizeAndAlignment(str);
        if(i >= 0) {
            argTypes[j] = [self a2_argumentForEncoding: str];
			j++;
		} else if (i == -2) {
			rtype = [self a2_argumentForEncoding: str];
		}
        i++;
        str = next;
    }
    
	ffi_cif cif;
    ffi_status status = ffi_prep_cif(&cif, FFI_DEFAULT_ABI, argCount, rtype, argTypes);
    if(status != FFI_OK)
    {
        NSLog(@"Got result %ld from ffi_prep_cif", (long)status);
        abort();
    }
	
	if (count)
		*count = argCount;
	
	return cif;
}

- (id)initWithBlock: (id)block
{
    if((self = [self init]))
    {
        _allocations = [NSMutableArray new];
        _block = block;
		_closure = ffi_closure_alloc(sizeof(ffi_closure), &_functionPointer);
        _closureCIF = [self a2_prepareCIFWithEncoding: a2_blockGetSignature(_block) forBlock: NO arguments: NULL];
        _innerCIF = [self a2_prepareCIFWithEncoding: a2_blockGetSignature(_block) forBlock: YES arguments: &_numberOfArguments];
        if (ffi_prep_closure_loc(_closure, &_closureCIF, a2_executeBlockClosure, self, _functionPointer) != FFI_OK) {
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
    [_allocations release];
    [super dealloc];
}

@end