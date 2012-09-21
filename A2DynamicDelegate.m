//
//  A2DynamicDelegate.m
//  A2DynamicDelegate
//
//  Created by Alexsander Akers on 11/26/11.
//  Copyright (c) 2011 Pandamonia LLC. All rights reserved.
//

#import "A2DynamicDelegate.h"
#import "A2BlockClosure.h"
#import <objc/message.h>

#pragma mark -

#ifndef NSAlwaysAssert
	#define NSAlwaysAssert(condition, desc, ...) \
		do { if (!(condition)) { [NSException raise: NSInternalInconsistencyException format: [NSString stringWithFormat: @"%s: %@", __PRETTY_FUNCTION__, desc], ## __VA_ARGS__]; } } while(0)
#endif

Protocol *a2_dataSourceProtocol(Class cls);
Protocol *a2_delegateProtocol(Class cls);
extern BOOL a2_blockIsCompatible(id block, NSMethodSignature *signature);
extern void (*a2_blockGetInvocation(id block))(void);

@interface A2DynamicDelegate ()

@property (nonatomic, unsafe_unretained, readwrite) id delegatingObject;
@property (nonatomic) Protocol *protocol;
@property (nonatomic, strong) id classProxy;
@property (nonatomic, strong, readonly) NSMutableDictionary *blockMap;

- (id)init;

+ (dispatch_queue_t) dynamicDelegateBackgroundQueue;
- (BOOL)isClassProxy;

@end

@interface A2DynamicDelegateClassProxy : A2DynamicDelegate {
	Class _proxiedClass;
}

- (id) blockImplementationForClassMethod: (SEL) selector NS_UNAVAILABLE;
- (void) implementClassMethod: (SEL) selector withBlock: (id) block NS_UNAVAILABLE;
- (void) removeBlockImplementationForClassMethod: (SEL) selector NS_UNAVAILABLE;

@end

@implementation A2DynamicDelegate

- (id)init {
	if (self) {

	}
	return self;
}

- (NSString *) description {
	return [NSString stringWithFormat: @"<A2DynamicDelegate %@>", NSStringFromProtocol(self.protocol)];
}

+ (NSString *)description {
	return @"A2DynamicDelegate";
}

+ (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
	id ret = nil;
	if ([NSStringFromSelector(aSelector) isEqualToString:@"testClassMethod"]) {
		ret = [NSMethodSignature signatureWithObjCTypes:"@@:"];
	}
	if (!ret)
		ret = [[NSObject class] methodSignatureForSelector: aSelector];
	return ret;
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)aSelector {
	id ret = nil;
	NSString *key = NSStringFromSelector(aSelector);
	if (self.blockMap[key]) {
		ret = [self.blockMap[key] methodSignature];
	} else if ([NSStringFromSelector(aSelector) isEqualToString:@"testClassMethod"]) {
		ret = [NSMethodSignature signatureWithObjCTypes:"@@:"];
	}
	if (ret)
		return ret;
	return [[NSObject class] methodSignatureForSelector: aSelector];
}

- (void)forwardInvocation:(NSInvocation *)invoc {
	A2BlockClosure *closure = self.blockMap[NSStringFromSelector(invoc.selector)];
	if (closure) {
		[closure callWithInvocation: invoc];
	}
}

- (Class)class {
	if ([[A2DynamicDelegate class] isEqual: object_getClass(self)]) {
		return (Class)self.classProxy;
	}
	return [super class];
}

- (A2DynamicDelegateClassProxy *)classProxy {
	if (!_classProxy) {
		_classProxy = [[A2DynamicDelegateClassProxy alloc] init];
		[_classProxy setProtocol: self.protocol];
	}
	return _classProxy;
}

- (BOOL)isClassProxy {
	return NO;
}

+ (dispatch_queue_t) dynamicDelegateBackgroundQueue
{
	static dispatch_once_t onceToken;
	static dispatch_queue_t backgroundQueue = nil;
	dispatch_once(&onceToken, ^{
		backgroundQueue = dispatch_queue_create("us.pandamonia.A2DynamicDelegate.backgroundQueue", DISPATCH_QUEUE_SERIAL);
	});
	return backgroundQueue;
}

- (NSMutableDictionary *) blockMap
{
	if (!_blockMap) {
		_blockMap = [NSMutableDictionary dictionary];
	}
	return _blockMap;
}

#pragma mark -

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
	return (protocol_isEqual(aProtocol, self.protocol) || [super conformsToProtocol: aProtocol]);
}

- (BOOL) respondsToSelector: (SEL) selector
{
	return self.blockMap[NSStringFromSelector(selector)] || [super respondsToSelector: selector];
}

- (void)doesNotRecognizeSelector:(SEL)aSelector {
	[NSException raise: NSInvalidArgumentException format: @"-[%s %@]: unrecognized selector sent to instance %p", object_getClassName(self), NSStringFromSelector(aSelector), self];
}

#pragma mark -

- (id) blockImplementationForMethod: (SEL) selector {
	return [self.blockMap[NSStringFromSelector(selector)] block];
}

- (void) implementMethod: (SEL) selector withBlock: (id) block {
	NSAlwaysAssert(selector, @"Attempt to implement/remove NULL selector");
	BOOL isClassMethod = self.isClassProxy;
    NSString *key = NSStringFromSelector(selector);

	if (!block)
	{
		[self.blockMap removeObjectForKey: key];
		return;
	}

	struct objc_method_description methodDescription = protocol_getMethodDescription(self.protocol, selector, YES, !isClassMethod);
	if (!methodDescription.name) methodDescription = protocol_getMethodDescription(self.protocol, selector, NO, !isClassMethod);
	if (!methodDescription.name) return;
	NSMethodSignature *protoSig = [NSMethodSignature signatureWithObjCTypes: methodDescription.types];

    NSAlwaysAssert(a2_blockIsCompatible(block, protoSig), @"Attempt to implement %s selector with incompatible block (selector: %c%s)", isClassMethod ? "class" : "instance", "-+"[!!isClassMethod], sel_getName(selector));

	A2BlockClosure *closure = [[A2BlockClosure alloc] initWithBlock: block methodSignature: protoSig];
	[self.blockMap setObject: closure forKey: key];
}

- (void) removeBlockImplementationForMethod: (SEL) selector {
	[self implementMethod: selector withBlock: NULL];
}

- (id) blockImplementationForClassMethod: (SEL) selector {
	return [self.classProxy blockImplementationForMethod: selector];
}

- (void) implementClassMethod: (SEL) selector withBlock: (id) block {
	[self.classProxy implementMethod: selector withBlock: block];
}

- (void) removeBlockImplementationForClassMethod: (SEL) selector {
	[self.classProxy implementMethod: selector withBlock: NULL];
}

@end

#pragma mark -

@implementation A2DynamicDelegateClassProxy

- (id)init {
	if ((self = [super init])) {
		_proxiedClass = [A2DynamicDelegate class];
	}
	return self;
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)aSelector {
	return [_proxiedClass methodSignatureForSelector: aSelector] ?: [super methodSignatureForSelector: aSelector];
}

- (void)forwardInvocation:(NSInvocation *)invoc {
	if (self.blockMap[NSStringFromSelector(invoc.selector)]) {
		[super forwardInvocation:invoc];
	} else {
		[invoc invokeWithTarget: _proxiedClass];
	}
}

- (NSString *)description {
	return [_proxiedClass description];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
	return self.blockMap[NSStringFromSelector(aSelector)] || [_proxiedClass respondsToSelector: aSelector];
}

- (BOOL)isClassProxy {
	return YES;
}

- (Class)class {
	return _proxiedClass;
}

- (BOOL)isEqual:(id)object {
	return [super isEqual: object] || [_proxiedClass isEqual: object];
}

- (NSUInteger)hash {
	return [_proxiedClass hash];
}

- (id) blockImplementationForClassMethod: (SEL) selector {
	[self doesNotRecognizeSelector: _cmd];
	return nil;
}

- (void) implementClassMethod: (SEL) selector withBlock: (id) block {
	[self doesNotRecognizeSelector: _cmd];
}

- (void) removeBlockImplementationForClassMethod: (SEL) selector {
	[self doesNotRecognizeSelector: _cmd];
}

@end

#pragma mark - NSObject categories

@implementation NSObject (A2DynamicDelegate)

- (id) dynamicDataSource
{
	Protocol *protocol = a2_dataSourceProtocol([self class]);
	return [self dynamicDelegateForProtocol: protocol];
}
- (id) dynamicDelegate
{
	Protocol *protocol = a2_delegateProtocol([self class]);
	return [self dynamicDelegateForProtocol: protocol];
}
- (id) dynamicDelegateForProtocol: (Protocol *) protocol
{
	/**
	 * Storing the dynamic delegate as an associated object of the delegating
	 * object not only allows us to later retrieve the delegate, but it also
	 * creates a strong relationship to the delegate. Since delegates are weak
	 * references on the part of the delegating object, a dynamic delegate
	 * would be deallocated immediately after its declaring scope ends.
	 * Therefore, this strong relationship is required to ensure that the
	 * delegate's lifetime is at least as long as that of the delegating object.
	 **/
	
	__block A2DynamicDelegate *dynamicDelegate;
	
	dispatch_sync([A2DynamicDelegate dynamicDelegateBackgroundQueue], ^{
		dynamicDelegate = objc_getAssociatedObject(self, (__bridge const void *)protocol);
		
		if (!dynamicDelegate)
		{
			Class cls = NSClassFromString([@"A2Dynamic" stringByAppendingString: NSStringFromProtocol(protocol)]) ?: [A2DynamicDelegate class];
			dynamicDelegate = [[cls alloc] init];
			dynamicDelegate.delegatingObject = self;
			dynamicDelegate.protocol = protocol;
			objc_setAssociatedObject(self, (__bridge const void *)protocol, dynamicDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		}
	});
	
	return dynamicDelegate;
}

@end

#pragma mark - Functions

Protocol *a2_dataSourceProtocol(Class cls) {
    NSString *className = NSStringFromClass(cls);
	NSString *protocolName = [className stringByAppendingString: @"DataSource"];
	Protocol *protocol = objc_getProtocol(protocolName.UTF8String);
	
	NSAlwaysAssert(protocol, @"Specify protocol explicitly: could not determine data source protocol for class %@ (tried <%@>)", className, protocolName);
	return protocol;
}

Protocol *a2_delegateProtocol(Class cls) {
    NSString *className = NSStringFromClass(cls);
	NSString *protocolName = [className stringByAppendingString: @"Delegate"];
	Protocol *protocol = objc_getProtocol(protocolName.UTF8String);
	
	NSAlwaysAssert(protocol, @"Specify protocol explicitly: could not determine delegate protocol for class %@ (tried <%@>)", className, protocolName);
	return protocol;
}
	
