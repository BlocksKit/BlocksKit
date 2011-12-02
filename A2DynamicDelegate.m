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
	#error "At present, 'A2DynamicDelegate.m' must be compiled without ARC. This is a limitation of the Obj-C runtime library. See here: http://j.mp/tJsoOV"
#endif

static id a2_blockImplementationForMethod(A2DynamicDelegate *dd, SEL selector, BOOL isClassMethod);
static void a2_implementMethodWithBlock(A2DynamicDelegate *dd, SEL selector, BOOL isClassMethod, id block);
static void a2_removeBlockImplementationForMethod(A2DynamicDelegate *dd, SEL selector, BOOL isClassMethod);

@interface A2DynamicDelegate ()

@property (nonatomic, assign) Protocol *protocol;

+ (A2DynamicDelegate *) dynamicDelegateForProtocol: (Protocol *) protocol; // Designated initializer

@end

@implementation A2DynamicDelegate

@synthesize protocol = _protocol;

+ (A2DynamicDelegate *) dynamicDelegateForProtocol: (Protocol *) protocol
{
	CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
	NSString *uuid = (NSString *) CFUUIDCreateString(kCFAllocatorDefault, cfuuid);
	CFRelease(cfuuid);
	
	NSString *subclassName = [NSString stringWithFormat: @"A2DynamicDelegate-%@", uuid];
	[uuid release];
	
	Class cls = objc_allocateClassPair([A2DynamicDelegate class], subclassName.UTF8String, 0);
	NSAssert(cls, @"Could not allocate A2DynamicDelegate subclass");
	
	objc_registerClassPair(cls);
	
	A2DynamicDelegate *delegate = [[cls new] autorelease];
	delegate.protocol = protocol;
	
	return delegate;
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
	[super dealloc];
	
	// Dispose of unique A2DynamicDelegate subclass
	objc_disposeClassPair(self.class);
}
- (void) setProtocol: (Protocol *) protocol
{
	NSAssert(!_protocol || !protocol, @"A2DynamicDelegate protocol may only be set once");
	_protocol = protocol;
	
	if (!protocol)
		return;
	
	BOOL success = class_addProtocol(self.class, protocol);
	NSAssert2(success, @"Could not add protocol <%s> to %@", protocol_getName(protocol), self);
	
	unsigned int i, count;
	objc_property_t *properties = protocol_copyPropertyList(protocol, &count);
	
	for (i = 0; i < count; ++i)
	{
		objc_property_t property = properties[i];
		
		const char *name = property_getName(property);
		unsigned int attributeCount;
		objc_property_attribute_t *attributes = property_copyAttributeList(property, &attributeCount);
		
		BOOL success = class_addProperty(self.class, name, attributes, attributeCount);
		NSAssert2(success, @"Could not add property %s to %@", name, self);
		
		free(attributes);
	}
	
	free(properties);
}

#pragma mark - Protocol Instance Methods

- (id) blockImplementationForMethod: (SEL) selector
{
	NSAssert1(selector, @"%s requires a non-nil selector", _cmd);
	return a2_blockImplementationForMethod(self, selector, NO);
}

- (void) implementMethod: (SEL) selector withBlock: (id) block
{
	NSAssert1(selector, @"%s requires a non-nil selector", _cmd);
	NSAssert1(block, @"%s requires a non-nil block", _cmd);
	a2_implementMethodWithBlock(self, selector, NO, block);
}
- (void) removeBlockImplementationForMethod: (SEL) selector
{
	NSAssert1(selector, @"%s requires a non-nil selector", _cmd);
	a2_removeBlockImplementationForMethod(self, selector, NO);
}

#pragma mark - Protocol Class Methods

- (id) blockImplementationForClassMethod: (SEL) selector
{
	NSAssert1(selector, @"%s requires a non-nil selector", _cmd);
	return a2_blockImplementationForMethod(self, selector, YES);
}

- (void) implementClassMethod: (SEL) selector withBlock: (id) block
{
	NSAssert1(selector, @"%s requires a non-nil selector", _cmd);
	NSAssert1(block, @"%s requires a non-nil block", _cmd);
	a2_implementMethodWithBlock(self, selector, YES, block);
}
- (void) removeBlockImplementationForClassMethod: (SEL) selector
{
	NSAssert1(selector, @"%s requires a non-nil selector", _cmd);
	a2_removeBlockImplementationForMethod(self, selector, YES);
}

#pragma mark - Protocol Properties

- (void *) valueForProtocolProperty: (NSString *) propertyName
{
#ifndef NS_BLOCK_ASSERTIONS
	objc_property_t property = protocol_getProperty(self.protocol, propertyName.UTF8String, YES, YES);
	if (!property) property = protocol_getProperty(self.protocol, propertyName.UTF8String, NO, YES);
	
	NSAssert2(property, @"Property \"%@\" is not a valid property of protocol <%s>", propertyName, protocol_getName(self.protocol));
#endif
	
	void *outValue = NULL;
	object_getInstanceVariable(self, propertyName.UTF8String, &outValue);
	return outValue;
}
- (void) setValue: (void *) value forProtocolProperty: (NSString *) propertyName
{
#ifndef NS_BLOCK_ASSERTIONS
	objc_property_t property = protocol_getProperty(self.protocol, propertyName.UTF8String, YES, YES);
	if (!property) property = protocol_getProperty(self.protocol, propertyName.UTF8String, NO, YES);
	
	NSAssert2(property, @"Property \"%@\" is not a valid property of protocol <%s>", propertyName, protocol_getName(self.protocol));
#endif
	
	object_setInstanceVariable(self, propertyName.UTF8String, value);
}

@end

@implementation NSObject (A2DynamicDelegate)

- (A2DynamicDelegate *) dynamicDataSource
{
	NSString *className = NSStringFromClass(self.class);
	NSString *protocolName = [className stringByAppendingString: @"DataSource"];
	Protocol *protocol = objc_getProtocol(protocolName.UTF8String);
	
	NSAssert2(protocol, @"Specify protocol explicitly: could not determine data source protocol for class %@ (tried <%@>)", className, protocolName);
	return [self dynamicDelegateForProtocol: protocol];
}

- (A2DynamicDelegate *) dynamicDelegate
{
	NSString *className = NSStringFromClass(self.class);
	NSString *protocolName = [className stringByAppendingString: @"Delegate"];
	Protocol *protocol = objc_getProtocol(protocolName.UTF8String);
	
	NSAssert2(protocol, @"Specify protocol explicitly: could not determine delegate protocol for class %@ (tried <%@>)", className, protocolName);
	return [self dynamicDelegateForProtocol: protocol];
}

- (A2DynamicDelegate *) dynamicDelegateForProtocol: (Protocol *) protocol
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
	
	id dynamicDelegate = objc_getAssociatedObject(self, &protocol);
	
	if (!dynamicDelegate)
	{
		dynamicDelegate = [A2DynamicDelegate dynamicDelegateForProtocol: protocol];
		objc_setAssociatedObject(self, &protocol, dynamicDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	return dynamicDelegate;
}

@end

static id a2_blockImplementationForMethod(A2DynamicDelegate *dd, SEL selector, BOOL isClassMethod)
{
	// Get class (but if class method, use meta-class).
	Class cls = dd.class;
	if (isClassMethod) cls = object_getClass(cls);
	
	// Get the implementation trampoline.
	IMP implementation = [cls methodForSelector: selector];
	
	// Get the block from the trampoline.
	id block = imp_getBlock(implementation);
	
	// Return the block
	if (block)
		return [[block copy] autorelease];
	else
		return nil;
}
static void a2_implementMethodWithBlock(A2DynamicDelegate *dd, SEL selector, BOOL isClassMethod, id block)
{
	// Maybe it's a required method...
	struct objc_method_description methodDescription = protocol_getMethodDescription(dd.protocol, selector, YES /* isRequiredMethod */, !isClassMethod /* isInstanceMethod */);
	
	// Or not...
	if (!methodDescription.name)
	{
		methodDescription = protocol_getMethodDescription(dd.protocol, selector, NO /* isRequiredMethod */, !isClassMethod /* isInstanceMethod */);
	}
	
	const char *types = methodDescription.types;
	
	// We need that type encoding
	NSCAssert2(types, @"Method %s not found in protocol <%s>", selector, protocol_getName(dd.protocol));
	
	// Copy the block to the heap.
	block = [[block copy] autorelease];
	
	// Get the implementation trampoline.
	IMP implementation = imp_implementationWithBlock(block);
	
	BOOL success;
	
	if (isClassMethod)
	{
		// Add the trampoline as a class method.
		Class metaClass = object_getClass(dd.class);
		success = class_addMethod(metaClass, selector, implementation, types);
	}
	else
	{
		// Add the trampoline as an instance method.
		success = class_addMethod(dd.class, selector, implementation, types);
	}
	
	NSCAssert4(success, @"Could not add%s method %s to %@ for protocol <%s>", isClassMethod ? " class" : "", selector, dd, protocol_getName(dd.protocol));
}
static void a2_removeBlockImplementationForMethod(A2DynamicDelegate *dd, SEL selector, BOOL isClassMethod)
{
	// Get class (but if class method, use meta-class).
	Class cls = dd.class;
	if (isClassMethod) cls = object_getClass(cls);
	
	Method method = class_getInstanceMethod(cls, selector);
	
	// Remove the block from the trampoline.
	IMP implementation = method_getImplementation(method);
	imp_removeBlock(implementation);
	
	// Implementing a method with the `(IMP) _objc_msgForward` is the same as removing it
	method_setImplementation(method, _objc_msgForward);
}
