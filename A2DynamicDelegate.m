//
//  A2DynamicDelegate.m
//  DynamicDelegate
//
//  Created by Alexsander Akers on 11/26/11.
//  Copyright (c) 2011 Pandamonia LLC. All rights reserved.
//

#import <objc/message.h>
#import <objc/runtime.h>

#import "A2DynamicDelegate.h"

#if __has_attribute(objc_arc)
	#error "At present, 'A2DynamicDelegate.m' must be compiled without ARC (add the '-fno-objc-arc' compile flag)."
#endif

@interface A2DynamicDelegate ()

@property (nonatomic, strong) Protocol *protocol;

+ (A2DynamicDelegate *) dynamicDelegateForProtocol: (Protocol *) aProtocol; // Designated initializer

@end

@implementation A2DynamicDelegate

@synthesize protocol = _protocol;

+ (A2DynamicDelegate *) dynamicDelegateForProtocol: (Protocol *) aProtocol
{
	CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
	NSString *uuid = (NSString *) CFUUIDCreateString(kCFAllocatorDefault, cfuuid);
	CFRelease(cfuuid);
	
	NSString *subclassName = [NSString stringWithFormat: @"A2DynamicDelegate-%@", uuid];
	[uuid release];
	
	Class cls = objc_allocateClassPair([A2DynamicDelegate class], subclassName.UTF8String, 0);
	NSAssert(cls, @"Could not allocate A2DynamicDelegate subclass");
	
	BOOL success = class_addProtocol(cls, aProtocol);
	NSAssert1(success, @"Could not add protocol <%s> to A2DynamicDelegate subclass", protocol_getName(aProtocol));
	
	objc_registerClassPair(cls);
	
	A2DynamicDelegate *delegate = [[cls new] autorelease];
	delegate.protocol = aProtocol;
	
	return delegate;
}

- (BOOL) implementSelector: (SEL) aSelector withBlock: (id) block
{
	NSAssert1(block, @"%s requires a non-nil block", _cmd);
	NSAssert1(aSelector, @"%s requires a non-nil aSelector", _cmd);
		
	// Maybe it's a required method...
	struct objc_method_description methodDescription = protocol_getMethodDescription(self.protocol, aSelector, YES, YES);
	
	// Or not...
	if (!methodDescription.name)
	{
		methodDescription = protocol_getMethodDescription(self.protocol, aSelector, NO, YES);
	}

	const char *types = methodDescription.types;
	
	// We need that type encoding
	NSAssert2(types, @"Method %s not found in protocol <%s>", aSelector, protocol_getName(self.protocol));

	// Copy the block to the heap.
	block = [[block copy] autorelease];
	
	// Get the implementation trampoline.
	IMP implementation = imp_implementationWithBlock(block);
	
	// Add the trampoline as our class's method.
	return class_addMethod(self.class, aSelector, implementation, types);
}
- (BOOL) removeImplementationForSelector: (SEL) aSelector
{
	IMP implementation = [self methodForSelector: aSelector];
	BOOL didRemovedBlock = imp_removeBlock(implementation);
	
	// Implementing a method with the `(IMP) _objc_msgForward` is the same as removing it
	Method method = class_getInstanceMethod(self.class, aSelector);
	method_setImplementation(method, _objc_msgForward);
	
	BOOL didSetImplementation = (_objc_msgForward == class_getMethodImplementation(self.class, aSelector));
	
	return (didRemovedBlock && didSetImplementation);
}

- (id) implementationForSelector: (SEL) aSelector
{
	// Get the implementation trampoline.
	IMP implementation = [self methodForSelector: aSelector];
	
	// Get the block from the trampoline.
	id block = imp_getBlock(implementation);
	
	// Return the block
	if (block)
		return [[block copy] autorelease];
	else
		return nil;
}

- (NSString *) description
{
	if (self.protocol)
		return [NSString stringWithFormat: @"<A2DynamicDelegate[%@] %p>", NSStringFromProtocol(self.protocol), self];
	else
		return [NSString stringWithFormat: @"<A2DynamicDelegate %p>", self];
}

- (void) dealloc
{
	self.protocol = nil;
	
	[super dealloc];
	
	// Dispose of unique A2DynamicDelegate subclass
	objc_disposeClassPair(self.class);
}

@end

@implementation NSObject (A2DynamicDelegate)

- (A2DynamicDelegate *) dynamicDelegate
{
	NSString *protocolName = [NSString stringWithFormat: @"%sDelegate", object_getClassName(self)];
	Protocol *protocol = objc_getProtocol(protocolName.UTF8String);
	
	NSAssert1(protocol, @"Protocol named <%@> not found. Use -dynamicDelegateForProtocol: instead", protocolName);
	return [self dynamicDelegateForProtocol: protocol];
}

- (A2DynamicDelegate *) dynamicDelegateForProtocol: (Protocol *) aProtocol
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
	
	id dynamicDelegate = objc_getAssociatedObject(self, &aProtocol);
	
	if (!dynamicDelegate)
	{
		dynamicDelegate = [A2DynamicDelegate dynamicDelegateForProtocol: aProtocol];
		objc_setAssociatedObject(self, &aProtocol, dynamicDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	return dynamicDelegate;
}

@end
