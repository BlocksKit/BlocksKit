#import "A2BlockClosure.h"
#import "A2BlockImplementation.h"

#if TARGET_OS_IPHONE
#import <CoreGraphics/CoreGraphics.h>
#endif

@interface A2BlockClosure ()

@property (nonatomic, readonly) ffi_cif *callInterface;
@property (nonatomic, readonly) NSUInteger numberOfArguments;

@end

static void A2BlockClosureExecute(ffi_cif *cif, void *ret, void **args, void *userdata)
{
	A2BlockClosure *self = userdata;
    int count = self.numberOfArguments;
    void **innerArgs = malloc((count + 1) * sizeof(*innerArgs));
    innerArgs[0] = self.block;
    memcpy(innerArgs + 1, args + 2, count * sizeof(*args)); // copy arguments after self and _cmd to after the block
    ffi_call(self.callInterface, a2_block_get_implementation(self.block), ret, innerArgs);
    free(innerArgs);
}

static const char *A2GetSizeAndAlignment(const char *str, NSUInteger *sizep, NSUInteger *alignp, int *len)
{
    const char *out = NSGetSizeAndAlignment(str, sizep, alignp);
    if(len)
        *len = out - str;
    while(isdigit(*out))
        out++;
    return out;
}

static int A2GetArgumentsCount(const char *str)
{
    int argcount = -2; // return type is the first one
    while(str && *str)
    {
        str = A2GetSizeAndAlignment(str, NULL, NULL, NULL);
        argcount++;
    }
    return argcount;
}

@implementation A2BlockClosure

@synthesize functionPtr = _closureFptr, numberOfArguments = _innerArgCount;

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

- (ffi_cif)a2_prepareCIFWithEncoding:(const char *)str forMethod: (BOOL)isMethod arguments: (NSUInteger *) count {
	int argCount = A2GetArgumentsCount(str) + (isMethod ? 2 : 1);
    ffi_type **argTypes = [self a2_allocate: argCount * sizeof(*argTypes)];
	
	argTypes[0] = [self a2_argumentForEncoding:@encode(id)];
	
	if (isMethod)
		argTypes[1] = [self a2_argumentForEncoding:@encode(SEL)];
	
	ffi_type *rtype = [self a2_argumentForEncoding: A2GetSizeAndAlignment(str, NULL, NULL, NULL)];
    
    int i = -2, j = isMethod ? 2 : 1;
    while(str && *str)
    {
        const char *next = A2GetSizeAndAlignment(str, NULL, NULL, NULL);
        if (i >= 0) {
            argTypes[j] = [self a2_argumentForEncoding: str];
			j++;
		}
        i++;
        str = next;
    }
    
	ffi_cif cif;
    ffi_status status = ffi_prep_cif(&cif, FFI_DEFAULT_ABI, argCount, rtype, argTypes);
    if (status != FFI_OK)
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
    if((self = [super init]))
    {
        _allocations = [NSMutableArray new];
        _block = block;
		_closure = ffi_closure_alloc(sizeof(ffi_closure), &_closureFptr);
		const char *signature = a2_block_signature(_block);
		_closureCIF = [self a2_prepareCIFWithEncoding: signature forMethod: YES arguments: NULL];
		_innerCIF = [self a2_prepareCIFWithEncoding: signature forMethod: NO arguments: &_innerArgCount];
        ffi_status status = ffi_prep_closure_loc(_closure, &_closureCIF, A2BlockClosureExecute, self, _closureFptr);
		if(status != FFI_OK) {
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