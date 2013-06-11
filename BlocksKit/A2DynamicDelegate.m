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

Protocol *a2_dataSourceProtocol(Class cls);
Protocol *a2_delegateProtocol(Class cls);

static BOOL a2_methodSignaturesCompatible(NSMethodSignature *methodSignature, NSMethodSignature *blockSignature)
{
	if (methodSignature.methodReturnType[0] != blockSignature.methodReturnType[0])
		return NO;

	NSUInteger numberOfArguments = methodSignature.numberOfArguments;
	for (NSUInteger i = 2; i < numberOfArguments; i++) {
		if ([methodSignature getArgumentTypeAtIndex: i][0] != [blockSignature getArgumentTypeAtIndex: i - 1][0])
			return NO;
	}
	return YES;
}

@interface A2DynamicClassDelegate : A2DynamicDelegate

@property (nonatomic) Class proxiedClass;

#pragma mark - Unavailable Methods

- (id) blockImplementationForClassMethod: (SEL) selector NS_UNAVAILABLE;

- (void) implementClassMethod: (SEL) selector withBlock: (id) block NS_UNAVAILABLE;
- (void) removeBlockImplementationForClassMethod: (SEL) selector NS_UNAVAILABLE;

@end

#pragma mark -

@interface A2DynamicDelegate ()

@property (nonatomic, readwrite) Protocol *protocol;
@property (nonatomic, strong) A2DynamicClassDelegate *classProxy;
@property (nonatomic, strong, readonly) NSMutableDictionary *blockInvocations;
@property (nonatomic, weak, readwrite) id realDelegate;

- (BOOL) isClassProxy;

@end

@implementation A2DynamicDelegate

- (A2DynamicClassDelegate *) classProxy
{
	if (!_classProxy)
	{
		_classProxy = [[A2DynamicClassDelegate alloc] initWithProtocol: self.protocol];
		_classProxy.proxiedClass = object_getClass(self);
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

- (id) initWithProtocol:(Protocol *)protocol
{
	_protocol = protocol;
	_handlers = [NSMutableDictionary dictionary];
	_blockInvocations = [NSMutableDictionary dictionary];
	return self;
}

- (NSMethodSignature*) methodSignatureForSelector: (SEL) aSelector
{
	NSString *key = NSStringFromSelector(aSelector);
	if (self.blockInvocations[key])
		return [self.blockInvocations[key] methodSignature];
	else if ([self.realDelegate methodSignatureForSelector: aSelector])
		return [self.realDelegate methodSignatureForSelector: aSelector];
	else if (class_respondsToSelector(object_getClass(self), aSelector))
		return [object_getClass(self) methodSignatureForSelector: aSelector];
	return [[NSObject class] methodSignatureForSelector: aSelector];
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
	A2BlockInvocation *innerInv = self.blockInvocations[NSStringFromSelector(outerInv.selector)];
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
	return self.blockInvocations[NSStringFromSelector(selector)] || class_respondsToSelector(object_getClass(self), selector) || [self.realDelegate respondsToSelector: selector];
}

- (void) doesNotRecognizeSelector: (SEL) aSelector
{
	[NSException raise: NSInvalidArgumentException format: @"-[%s %@]: unrecognized selector sent to instance %p", object_getClassName(self), NSStringFromSelector(aSelector), self];
}

#pragma mark - Block Instance Method Implementations

- (id) blockImplementationForMethod: (SEL) selector
{
	return [self.blockInvocations[NSStringFromSelector(selector)] block];
}

- (void) implementMethod: (SEL) selector withBlock: (id) block
{
	NSCAssert(selector, @"Attempt to implement or remove NULL selector");
	BOOL isClassMethod = self.isClassProxy;
	NSString *key = NSStringFromSelector(selector);

	if (!block)
	{
		[self.blockInvocations removeObjectForKey: key];
		return;
	}

	struct objc_method_description methodDescription = protocol_getMethodDescription(self.protocol, selector, YES, !isClassMethod);
	if (!methodDescription.name) methodDescription = protocol_getMethodDescription(self.protocol, selector, NO, !isClassMethod);
	if (!methodDescription.name) return;

	NSMethodSignature *protoSig = [NSMethodSignature signatureWithObjCTypes: methodDescription.types];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock: block methodSignature: protoSig];

	NSCAssert3(a2_methodSignaturesCompatible(inv.methodSignature, inv.blockSignature), @"Attempt to implement %s selector with incompatible block (selector: %c%s)", isClassMethod ? "class" : "instance", "-+"[!!isClassMethod], sel_getName(selector));
	
	self.blockInvocations[key] = inv;
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
	return self.blockInvocations[NSStringFromSelector(aSelector)] || [_proxiedClass respondsToSelector: aSelector];
}

- (Class) class
{
	return _proxiedClass;
}

- (id) initWithClass: (Class) proxy
{
	if ((self = [super initWithProtocol: NULL]))
	{
		_proxiedClass = proxy;
	}
	
	return self;
}

- (NSMethodSignature *) methodSignatureForSelector: (SEL) aSelector
{
	NSString *key = NSStringFromSelector(aSelector);
	if (self.blockInvocations[key])
		return [self.blockInvocations[key] methodSignature];
	else if ([_proxiedClass methodSignatureForSelector: aSelector])
		return [_proxiedClass methodSignatureForSelector: aSelector];
	return [[NSObject class] methodSignatureForSelector: aSelector];
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
	if (self.blockInvocations[NSStringFromSelector(invoc.selector)])
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

#pragma mark - Helper functions

Protocol *a2_dataSourceProtocol(Class cls)
{
	NSString *className = NSStringFromClass(cls);
	NSString *protocolName = [className stringByAppendingString: @"DataSource"];
	Protocol *protocol = objc_getProtocol(protocolName.UTF8String);

	NSCAssert2(protocol, @"Specify protocol explicitly: could not determine data source protocol for class %@ (tried <%@>)", className, protocolName);
	return protocol;
}
Protocol *a2_delegateProtocol(Class cls)
{
	NSString *className = NSStringFromClass(cls);
	NSString *protocolName = [className stringByAppendingString: @"Delegate"];
	Protocol *protocol = objc_getProtocol(protocolName.UTF8String);

	NSCAssert2(protocol, @"Specify protocol explicitly: could not determine delegate protocol for class %@ (tried <%@>)", className, protocolName);
	return protocol;
}
