//
//  A2DynamicDelegate.m
//  A2DynamicDelegate
//
//  Created by Alexsander Akers on 11/26/11.
//  Copyright (c) 2011 Pandamonia LLC. All rights reserved.
//

#import "A2DynamicDelegate.h"
#import "A2BlockInvocation.h"
#import <objc/message.h>

#ifndef NSAlwaysAssert
	#define NSAlwaysAssert(condition, desc, ...) \
		do { if (!(condition)) { [NSException raise: NSInternalInconsistencyException format: [NSString stringWithFormat: @"%s: %@", __PRETTY_FUNCTION__, desc], ## __VA_ARGS__]; } } while(0)
#endif

Protocol *a2_dataSourceProtocol(Class cls);
Protocol *a2_delegateProtocol(Class cls);

static BOOL a2_methodSignaturesCompatible(NSMethodSignature *methodSignature, NSMethodSignature *blockSignature)
{
	if (strcmp(methodSignature.methodReturnType, blockSignature.methodReturnType))
		return NO;

	NSUInteger numberOfArguments = methodSignature.numberOfArguments;
	for (NSUInteger i = 2; i < numberOfArguments; i++) {
		if (strcmp([methodSignature getArgumentTypeAtIndex: i], [blockSignature getArgumentTypeAtIndex: i - 1]))
			return NO;
	}
	return YES;
}

@interface A2DynamicClassDelegate : A2DynamicDelegate

- (id) initWithClass: (Class) proxy;

#pragma mark - Unavailable Methods

- (id) blockImplementationForClassMethod: (SEL) selector NS_UNAVAILABLE;

- (void) implementClassMethod: (SEL) selector withBlock: (id) block NS_UNAVAILABLE;
- (void) removeBlockImplementationForClassMethod: (SEL) selector NS_UNAVAILABLE;

@end

#pragma mark -

@interface A2DynamicDelegate ()
{
	NSMutableDictionary *_blockMap;
	NSMutableDictionary *_signatureMap;
}

@property (nonatomic, readwrite) Protocol *protocol;
@property (nonatomic, strong) id classProxy;
@property (nonatomic, strong, readonly) NSMutableDictionary *blockMap;
@property (nonatomic, strong, readonly) NSMutableDictionary *signatureMap;
@property (nonatomic, unsafe_unretained, readwrite) id realDelegate;

- (BOOL) isClassProxy;

+ (dispatch_queue_t) dynamicDelegateBackgroundQueue;

- (id) init;

@end

@implementation A2DynamicDelegate

- (A2DynamicClassDelegate *) classProxy
{
	if (!_classProxy)
	{
		Class cls = NSClassFromString([@"A2Dynamic" stringByAppendingString: NSStringFromProtocol(self.protocol)]) ?: [A2DynamicClassDelegate class];
		_classProxy = [[A2DynamicClassDelegate alloc] initWithClass: cls];
		[_classProxy setRealDelegate: self];
		[_classProxy setProtocol: self.protocol];
	}
	
	return _classProxy;
}

- (BOOL) isClassProxy
{
	return NO;
}

- (Class) class
{
	Class myClass = object_getClass(self);
	if (myClass == [A2DynamicDelegate class] || [myClass superclass] == [A2DynamicDelegate class])
		return (Class) self.classProxy;
	return [super class];
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

- (id) init
{
	self->_handlers = [NSMutableDictionary dictionary];
	return self;
}
- (id) realDelegate
{
	id obj = _realDelegate;
	if ([obj isKindOfClass: [NSValue class]])
		return [obj nonretainedObjectValue];
	else
		return obj;
}

- (NSMethodSignature*) methodSignatureForSelector: (SEL) aSelector
{
	NSString *key = NSStringFromSelector(aSelector);
	if (self.signatureMap[key])
		return self.signatureMap[key];
	else if ([self.realDelegate methodSignatureForSelector: aSelector])
		return [self.realDelegate methodSignatureForSelector: aSelector];
	
	return [[NSObject class] methodSignatureForSelector: aSelector];
}

- (NSMutableDictionary *) blockMap
{
	if (!_blockMap) _blockMap = [NSMutableDictionary dictionary];
	return _blockMap;
}
- (NSMutableDictionary *) signatureMap
{
	if (!_signatureMap) _signatureMap = [NSMutableDictionary dictionary];
	return _signatureMap;
}

+ (NSString *) description
{
	return @"A2DynamicDelegate";
}
- (NSString *) description
{
	return [NSString stringWithFormat: @"<A2DynamicDelegate: %p; protocol = %@>", self, NSStringFromProtocol(self.protocol)];
}

- (void) forwardInvocation: (NSInvocation *) outerInv
{
	A2BlockInvocation *innerInv = self.blockMap[NSStringFromSelector(outerInv.selector)];
	if (innerInv)
		[innerInv invokeUsingInvocation: outerInv];
	else if ([self.realDelegate respondsToSelector: outerInv.selector])
		[outerInv invokeWithTarget: self.realDelegate];
}

#pragma mark -

- (BOOL) conformsToProtocol: (Protocol *) aProtocol
{
	return protocol_isEqual(aProtocol, self.protocol) || [super conformsToProtocol: aProtocol];
}
- (BOOL) respondsToSelector: (SEL) selector
{
	return self.blockMap[NSStringFromSelector(selector)] || [self.realDelegate respondsToSelector: selector] || [super respondsToSelector: selector];
}

- (void) doesNotRecognizeSelector: (SEL) aSelector
{
	[NSException raise: NSInvalidArgumentException format: @"-[%s %@]: unrecognized selector sent to instance %p", object_getClassName(self), NSStringFromSelector(aSelector), self];
}

#pragma mark - Block Instance Method Implementations

- (id) blockImplementationForMethod: (SEL) selector
{
	return [self.blockMap[NSStringFromSelector(selector)] block];
}

- (void) implementMethod: (SEL) selector withBlock: (id) block
{
	NSAlwaysAssert(selector, @"Attempt to implement or remove NULL selector");
	BOOL isClassMethod = self.isClassProxy;
    NSString *key = NSStringFromSelector(selector);

	if (!block)
	{
		[self.blockMap removeObjectForKey: key];
		[self.signatureMap removeObjectForKey: key];
		return;
	}

	struct objc_method_description methodDescription = protocol_getMethodDescription(self.protocol, selector, YES, !isClassMethod);
	if (!methodDescription.name) methodDescription = protocol_getMethodDescription(self.protocol, selector, NO, !isClassMethod);
	if (!methodDescription.name) return;

	A2BlockInvocation *inv = [A2BlockInvocation invocationWithBlock: block];
	NSMethodSignature *protoSig = [NSMethodSignature signatureWithObjCTypes: methodDescription.types];

    NSAlwaysAssert(a2_methodSignaturesCompatible(protoSig, inv.methodSignature), @"Attempt to implement %s selector with incompatible block (selector: %c%s)", isClassMethod ? "class" : "instance", "-+"[!!isClassMethod], sel_getName(selector));
	
	self.blockMap[key] = inv;
	self.signatureMap[key] = protoSig;
}
- (void) removeBlockImplementationForMethod: (SEL) selector
{
	[self implementMethod: selector withBlock: NULL];
}

#pragma mark - Block Class Method Implementations

- (id) blockImplementationForClassMethod: (SEL) selector
{
	return [self.classProxy blockImplementationForMethod: selector];
}

- (void) implementClassMethod: (SEL) selector withBlock: (id) block
{
	[self.classProxy implementMethod: selector withBlock: block];
}
- (void) removeBlockImplementationForClassMethod: (SEL) selector
{
	[self.classProxy implementMethod: selector withBlock: NULL];
}

@end

#pragma mark -

@implementation A2DynamicClassDelegate
{
	Class _proxiedClass;
}

- (BOOL) isClassProxy
{
	return YES;
}
- (BOOL) isEqual: (id) object
{
	return [super isEqual: object] || [_proxiedClass isEqual: object];
}
- (BOOL) respondsToSelector: (SEL) aSelector
{
	return self.blockMap[NSStringFromSelector(aSelector)] || [_proxiedClass respondsToSelector: aSelector];
}

- (Class) class
{
	return _proxiedClass;
}

- (id) init
{
	[self doesNotRecognizeSelector: _cmd];
	return nil;
}
- (id) initWithClass: (Class) proxy
{
	if ((self = [super init]))
	{
		_proxiedClass = proxy;
	}
	
	return self;
}

- (NSMethodSignature *) methodSignatureForSelector: (SEL) aSelector
{
	return [_proxiedClass methodSignatureForSelector: aSelector] ?: [super methodSignatureForSelector: aSelector];
}

- (NSString *) description
{
	return [_proxiedClass description];
}

- (NSUInteger) hash
{
	return [_proxiedClass hash];
}

- (void) forwardInvocation: (NSInvocation *) invoc
{
	if (self.blockMap[NSStringFromSelector(invoc.selector)])
		[super forwardInvocation: invoc];
	else
		[invoc invokeWithTarget: _proxiedClass];
}

#pragma mark - Unavailable Methods

- (id) blockImplementationForClassMethod: (SEL) selector
{
	[self doesNotRecognizeSelector: _cmd];
	return nil;
}

- (void) implementClassMethod: (SEL) selector withBlock: (id) block
{
	[self doesNotRecognizeSelector: _cmd];
}
- (void) removeBlockImplementationForClassMethod: (SEL) selector
{
	[self doesNotRecognizeSelector: _cmd];
}

@end

#pragma mark - NSObject Categories

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
			dynamicDelegate.realDelegate = self;
			dynamicDelegate.protocol = protocol;
			objc_setAssociatedObject(self, (__bridge const void *)protocol, dynamicDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		}
	});
	
	return dynamicDelegate;
}

@end

#pragma mark - Functions

Protocol *a2_dataSourceProtocol(Class cls)
{
    NSString *className = NSStringFromClass(cls);
	NSString *protocolName = [className stringByAppendingString: @"DataSource"];
	Protocol *protocol = objc_getProtocol(protocolName.UTF8String);
	
	NSAlwaysAssert(protocol, @"Specify protocol explicitly: could not determine data source protocol for class %@ (tried <%@>)", className, protocolName);
	return protocol;
}
Protocol *a2_delegateProtocol(Class cls)
{
    NSString *className = NSStringFromClass(cls);
	NSString *protocolName = [className stringByAppendingString: @"Delegate"];
	Protocol *protocol = objc_getProtocol(protocolName.UTF8String);
	
	NSAlwaysAssert(protocol, @"Specify protocol explicitly: could not determine delegate protocol for class %@ (tried <%@>)", className, protocolName);
	return protocol;
}
	
