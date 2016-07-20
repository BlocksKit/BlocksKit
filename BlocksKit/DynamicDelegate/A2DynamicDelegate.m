//
//  A2DynamicDelegate.m
//  BlocksKit
//

#import "A2DynamicDelegate.h"
@import ObjectiveC.message;
@import ObjectiveC.runtime;
#import "A2BlockInvocation.h"

Protocol *a2_dataSourceProtocol(Class cls);
Protocol *a2_delegateProtocol(Class cls);
Protocol *a2_protocolForDelegatingObject(id obj, Protocol *protocol);

static BOOL selectorsEqual(const void *item1, const void *item2, NSUInteger(*__unused size)(const void __unused *item))
{
	return sel_isEqual((SEL)item1, (SEL)item2);
}

static NSString *selectorDescribe(const void *item1)
{
	return NSStringFromSelector((SEL)item1);
}

static inline BOOL protocol_declaredSelector(Protocol *protocol, SEL selector)
{
    for (int i = 0; i < 4; i++) {
        BOOL required = 1 & (i);
        BOOL instance = 1 & (i >> 1);

        struct objc_method_description description = protocol_getMethodDescription(protocol, selector, required, instance);
        if (description.name) {
            return YES;
        }
    }
    return NO;
}

@interface NSMapTable (BKAdditions)

+ (instancetype)bk_selectorsToStrongObjectsMapTable;
- (id)bk_objectForSelector:(SEL)aSEL;
- (void)bk_removeObjectForSelector:(SEL)aSEL;
- (void)bk_setObject:(id)anObject forSelector:(SEL)aSEL;

@end

@implementation NSMapTable (BKAdditions)

+ (instancetype)bk_selectorsToStrongObjectsMapTable
{
	NSPointerFunctions *selectors = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsOpaqueMemory|NSPointerFunctionsOpaquePersonality];
	selectors.isEqualFunction = selectorsEqual;
	selectors.descriptionFunction = selectorDescribe;

	NSPointerFunctions *strongObjects = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPersonality];

	return [[NSMapTable alloc] initWithKeyPointerFunctions:selectors valuePointerFunctions:strongObjects capacity:1];
}

- (id)bk_objectForSelector:(SEL)aSEL
{
	void *selAsPtr = aSEL;
	return [self objectForKey:(__bridge id)selAsPtr];
}

- (void)bk_removeObjectForSelector:(SEL)aSEL
{
	void *selAsPtr = aSEL;
	[self removeObjectForKey:(__bridge id)selAsPtr];
}

- (void)bk_setObject:(id)anObject forSelector:(SEL)aSEL
{
	void *selAsPtr = aSEL;
	[self setObject:anObject forKey:(__bridge id)selAsPtr];
}


@end

@interface A2DynamicClassDelegate : A2DynamicDelegate

@property (nonatomic) Class proxiedClass;

@end

#pragma mark -

@interface A2DynamicDelegate ()

@property (nonatomic) A2DynamicClassDelegate *classProxy;
@property (nonatomic, readonly) NSMapTable *invocationsBySelectors;
@property (nonatomic, weak, readwrite) id realDelegate;

- (BOOL) isClassProxy;

@end

@implementation A2DynamicDelegate

- (A2DynamicClassDelegate *)classProxy
{
	if (!_classProxy)
	{
		_classProxy = [[A2DynamicClassDelegate alloc] initWithProtocol:self.protocol];
		_classProxy.proxiedClass = object_getClass(self);
	}

	return _classProxy;
}

- (BOOL)isClassProxy
{
	return NO;
}

- (Class)class
{
	Class myClass = object_getClass(self);
	if (myClass == [A2DynamicDelegate class] || [myClass superclass] == [A2DynamicDelegate class])
		return (Class)self.classProxy;
	return [super class];
}

- (instancetype)initWithProtocol:(Protocol *)protocol
{
	_protocol = protocol;
	_handlers = [NSMutableDictionary dictionary];
	_invocationsBySelectors = [NSMapTable bk_selectorsToStrongObjectsMapTable];
	return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	A2BlockInvocation *invocation = nil;
	if ((invocation = [self.invocationsBySelectors bk_objectForSelector:aSelector]))
		return invocation.methodSignature;
	else if ([self.realDelegate methodSignatureForSelector:aSelector])
		return [self.realDelegate methodSignatureForSelector:aSelector];
	else if (class_respondsToSelector(object_getClass(self), aSelector))
		return [object_getClass(self) methodSignatureForSelector:aSelector];
	return [[NSObject class] methodSignatureForSelector:aSelector];
}

+ (NSString *)description
{
	return @"A2DynamicDelegate";
}
- (NSString *)description
{
	return [NSString stringWithFormat:@"<A2DynamicDelegate:%p; protocol = %@>", (__bridge void *)self, NSStringFromProtocol(self.protocol)];
}

- (void)forwardInvocation:(NSInvocation *)outerInv
{
	SEL selector = outerInv.selector;
	A2BlockInvocation *innerInv = nil;
	if ((innerInv = [self.invocationsBySelectors bk_objectForSelector:selector])) {
		[innerInv invokeWithInvocation:outerInv];
	} else if ([self.realDelegate respondsToSelector:selector]) {
		[outerInv invokeWithTarget:self.realDelegate];
	}
}

#pragma mark -

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
	return protocol_isEqual(aProtocol, self.protocol) || [super conformsToProtocol:aProtocol];
}
- (BOOL)respondsToSelector:(SEL)selector
{
	return [self.invocationsBySelectors bk_objectForSelector:selector] ||
		   class_respondsToSelector(object_getClass(self), selector)   ||
	       (protocol_declaredSelector(self.protocol, selector) && [self.realDelegate respondsToSelector:selector]);
}

- (void)doesNotRecognizeSelector:(SEL)aSelector
{
	[NSException raise:NSInvalidArgumentException format:@"-[%s %@]: unrecognized selector sent to instance %p", object_getClassName(self), NSStringFromSelector(aSelector), (__bridge void *)self];
}

#pragma mark - Block Instance Method Implementations

- (id)blockImplementationForMethod:(SEL)selector
{
	A2BlockInvocation *invocation = nil;
	if ((invocation = [self.invocationsBySelectors bk_objectForSelector:selector]))
		return invocation.block;
	return NULL;
}

- (void)implementMethod:(SEL)selector withBlock:(id)block
{
	NSCAssert(selector, @"Attempt to implement or remove NULL selector");
	BOOL isClassMethod = self.isClassProxy;

	if (!block) {
		[self.invocationsBySelectors bk_removeObjectForSelector:selector];
		return;
	}

	struct objc_method_description methodDescription = protocol_getMethodDescription(self.protocol, selector, YES, !isClassMethod);
	if (!methodDescription.name) methodDescription = protocol_getMethodDescription(self.protocol, selector, NO, !isClassMethod);

	A2BlockInvocation *inv = nil;
	if (methodDescription.name) {
		NSMethodSignature *protoSig = [NSMethodSignature signatureWithObjCTypes:methodDescription.types];
		inv = [[A2BlockInvocation alloc] initWithBlock:block methodSignature:protoSig];
	} else {
		inv = [[A2BlockInvocation alloc] initWithBlock:block];
	}

	[self.invocationsBySelectors bk_setObject:inv forSelector:selector];
}
- (void)removeBlockImplementationForMethod:(SEL)selector __unused
{
	[self implementMethod:selector withBlock:nil];
}

#pragma mark - Block Class Method Implementations

- (id)blockImplementationForClassMethod:(SEL)selector
{
	return [self.classProxy blockImplementationForMethod:selector];
}

- (void)implementClassMethod:(SEL)selector withBlock:(id)block
{
	[self.classProxy implementMethod:selector withBlock:block];
}
- (void)removeBlockImplementationForClassMethod:(SEL)selector __unused
{
	[self.classProxy implementMethod:selector withBlock:nil];
}

@end

#pragma mark -

@implementation A2DynamicClassDelegate

- (BOOL)isClassProxy
{
	return YES;
}
- (BOOL)isEqual:(id)object
{
	return [super isEqual:object] || [_proxiedClass isEqual:object];
}
- (BOOL)respondsToSelector:(SEL)aSelector
{
	return [self.invocationsBySelectors bk_objectForSelector:aSelector] || [_proxiedClass respondsToSelector:aSelector];
}

- (Class)class
{
	return self.proxiedClass;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	A2BlockInvocation *invocation = nil;
	if ((invocation = [self.invocationsBySelectors bk_objectForSelector:aSelector]))
		return invocation.methodSignature;
	else if ([_proxiedClass methodSignatureForSelector:aSelector])
		return [_proxiedClass methodSignatureForSelector:aSelector];
	return [[NSObject class] methodSignatureForSelector:aSelector];
}

- (NSString *)description
{
	return [_proxiedClass description];
}

- (NSUInteger)hash
{
	return [_proxiedClass hash];
}

- (void)forwardInvocation:(NSInvocation *)outerInv
{
	SEL selector = outerInv.selector;
	A2BlockInvocation *innerInv = nil;
	if ((innerInv = [self.invocationsBySelectors bk_objectForSelector:selector])) {
		[innerInv invokeWithInvocation:outerInv];
	} else {
		[outerInv invokeWithTarget:_proxiedClass];
	}
}

#pragma mark - Unavailable Methods

- (id)blockImplementationForClassMethod:(SEL)selector
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (void)implementClassMethod:(SEL)selector withBlock:(id)block
{
	[self doesNotRecognizeSelector:_cmd];
}
- (void)removeBlockImplementationForClassMethod:(SEL)selector
{
	[self doesNotRecognizeSelector:_cmd];
}

@end

#pragma mark - Helper functions

static Protocol *a2_classProtocol(Class _cls, NSString *suffix, NSString *description)
{
	Class cls = _cls;
	while (cls) {
		NSString *className = NSStringFromClass(cls);
		NSString *protocolName = [className stringByAppendingString:suffix];
		Protocol *protocol = objc_getProtocol(protocolName.UTF8String);
		if (protocol) return protocol;

		cls = class_getSuperclass(cls);
	}

	NSCAssert(NO, @"Specify protocol explicitly: could not determine %@ protocol for class %@ (tried <%@>)", description, NSStringFromClass(_cls), [NSStringFromClass(_cls) stringByAppendingString:suffix]);
	return nil;
}

Protocol *a2_dataSourceProtocol(Class cls)
{
	return a2_classProtocol(cls, @"DataSource", @"data source");
}
Protocol *a2_delegateProtocol(Class cls)
{
	return a2_classProtocol(cls, @"Delegate", @"delegate");
}
Protocol *a2_protocolForDelegatingObject(id obj, Protocol *protocol)
{
	NSString *protocolName = NSStringFromProtocol(protocol);
	if ([protocolName hasSuffix:@"Delegate"]) {
		Protocol *p = a2_delegateProtocol([obj class]);
		if (p) return p;
	} else if ([protocolName hasSuffix:@"DataSource"]) {
		Protocol *p = a2_dataSourceProtocol([obj class]);
		if (p) return p;
	}

	return protocol;
}
