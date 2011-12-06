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

#define DICT_KEY(selector, isClassMethod) ([NSString stringWithFormat: @"%c%s", (isClassMethod) ? '+' : '-', sel_getName(selector)])

static void *A2BlockMapKey;
static void *A2ProtocolKey;

static const char *BlockSig(id blockObj);
static void *BlockImpl(id block);

@interface NSInvocation ()

- (void) invokeUsingIMP: (IMP)imp;

@end

@interface A2DynamicDelegate ()

@property (nonatomic, assign) Protocol *protocol;

+ (A2DynamicDelegate *) dynamicDelegateForProtocol: (Protocol *) protocol; // Designated initializer

+ (NSMutableDictionary *) blockMap;
- (NSMutableDictionary *) blockMap;

+ (Protocol *) protocol;

+ (void) forwardInvocation: (NSInvocation *) fwdInvocation fromClass: (BOOL) isClassMethod;
+ (void) setProtocol: (Protocol *) protocol;

@end

@implementation A2DynamicDelegate

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

#pragma mark - Block Map

+ (NSMutableDictionary *) blockMap
{
	NSMutableDictionary *blockMap = objc_getAssociatedObject(self, &A2BlockMapKey);
	if (!blockMap)
	{
		blockMap = [NSMutableDictionary dictionary];
		objc_setAssociatedObject(self, &A2BlockMapKey, blockMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	return blockMap;
}
- (NSMutableDictionary *) blockMap
{
	return [self.class blockMap];
}

#pragma mark - Forward Invocation

+ (void) forwardInvocation: (NSInvocation *) fwdInvocation fromClass: (BOOL) isClassMethod
{
	SEL selector = fwdInvocation.selector;
	id block = [self.blockMap objectForKey: DICT_KEY(selector, NO)];
	NSParameterAssert(block);
	
	const char *types = BlockSig(block);
	NSMethodSignature *sig = [NSMethodSignature signatureWithObjCTypes: types];
	
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: sig];
	[invocation setTarget: block];
	
	NSMethodSignature *fwdSig = fwdInvocation.methodSignature;
	NSUInteger i, argc = fwdSig.numberOfArguments;
	for (i = 2; i < argc; ++i)
	{
		const char *argType = [fwdSig getArgumentTypeAtIndex: i];
		NSString *tmpEncoding = [NSString stringWithFormat: @"%s@:", argType];
		NSMethodSignature *tmpSig = [NSMethodSignature signatureWithObjCTypes: tmpEncoding.UTF8String];
		NSUInteger length = tmpSig.methodReturnLength;
		
		void *argBufer = malloc(length);
		[fwdInvocation getArgument: argBufer atIndex: i];
		
		NSData *argData = [NSData dataWithBytesNoCopy: argBufer length: length];
		[invocation setArgument: (void *) argData.bytes atIndex: i - 1];
	}
	
	[invocation invokeUsingIMP: BlockImpl(block)];
	
	NSUInteger returnLength = fwdSig.methodReturnLength;
	if (returnLength)
	{
		void *returnBuffer = malloc(returnLength);
		[invocation getReturnValue: returnBuffer];
		
		NSData *returnData = [NSData dataWithBytesNoCopy: returnBuffer length: returnLength];
		[fwdInvocation setReturnValue: (void *) returnData.bytes];
	}
}
+ (void) forwardInvocation: (NSInvocation *) fwdInvocation
{
	[self forwardInvocation: fwdInvocation fromClass: YES];
}
- (void) forwardInvocation: (NSInvocation *) fwdInvocation
{
	[self.class forwardInvocation: fwdInvocation fromClass: NO];
}

#pragma mark - Method Signature

+ (NSMethodSignature *) instanceMethodSignatureForSelector: (SEL) selector
{
	NSMethodSignature *sig = [super instanceMethodSignatureForSelector: selector];
	if (!sig)
	{
		struct objc_method_description methodDescription = protocol_getMethodDescription(self.protocol, selector, YES, NO);
		if (!methodDescription.name) methodDescription = protocol_getMethodDescription(self.protocol, selector, NO, NO);
		
		const char *types = methodDescription.types;
		NSAssert2(types, @"Instance method %s not found in protocol <%s>", selector, protocol_getName(self.protocol));
		
		sig = [NSMethodSignature signatureWithObjCTypes: types];
	}
	
	return sig;
}
+ (NSMethodSignature *) methodSignatureForSelector: (SEL) selector
{
	NSMethodSignature *sig = [super instanceMethodSignatureForSelector: selector];
	if (!sig)
	{
		struct objc_method_description methodDescription = protocol_getMethodDescription(self.protocol, selector, YES, YES);
		if (!methodDescription.name) methodDescription = protocol_getMethodDescription(self.protocol, selector, NO, YES);
		
		const char *types = methodDescription.types;
		NSAssert2(types, @"Class method %s not found in protocol <%s>", selector, protocol_getName(self.protocol));
		
		sig = [NSMethodSignature signatureWithObjCTypes: types];
	}
	
	return sig;
}
- (NSMethodSignature *) methodSignatureForSelector: (SEL) selector
{
	return [super methodSignatureForSelector: selector] ?: [self.class instanceMethodSignatureForSelector: selector];
}

#pragma mark - Protocol

+ (Protocol *) protocol
{
	return objc_getAssociatedObject(self, &A2ProtocolKey);
}
+ (void) setProtocol: (Protocol *) protocol
{
#ifndef NS_BLOCK_ASSERTIONS
	Protocol *existing = objc_getAssociatedObject(self, &A2ProtocolKey);
	NSAssert(!existing || !protocol, @"A2DynamicDelegate protocol may only be set once");
#endif
	
	if (!protocol)
		return;
	
	objc_setAssociatedObject(self, &A2ProtocolKey, protocol, OBJC_ASSOCIATION_ASSIGN);
	
	BOOL success = class_addProtocol(self.class, protocol);
	NSAssert2(success, @"Protocol <%s> could not be added to %@", protocol_getName(protocol), self);
	
	unsigned int i, count;
	objc_property_t *properties = protocol_copyPropertyList(protocol, &count);
	
	for (i = 0; i < count; ++i)
	{
		objc_property_t property = properties[i];
		
		const char *name = property_getName(property);
		unsigned int attributeCount;
		objc_property_attribute_t *attributes = property_copyAttributeList(property, &attributeCount);
		
		BOOL success = class_addProperty(self.class, name, attributes, attributeCount);
		NSAssert2(success, @"Property %s could not be added to %@", name, self);
		
		free(attributes);
	}
	
	free(properties);
}

- (Protocol *) protocol
{
	return [self.class protocol];
}
- (void) setProtocol: (Protocol *) protocol
{
	[self.class setProtocol: protocol];
}

#pragma mark - Protocol Class Methods

- (id) blockImplementationForClassMethod: (SEL) selector
{
	NSAssert1(selector, @"%s requires a non-nil selector", _cmd);
	
	return [self.blockMap objectForKey: DICT_KEY(selector, YES)];
}

- (void) implementClassMethod: (SEL) selector withBlock: (id) block
{
	NSAssert1(selector, @"%s requires a non-nil selector", _cmd);
	NSAssert1(block, @"%s requires a non-nil block", _cmd);
	
#ifndef NS_BLOCK_ASSERTIONS
	// Throws if `selector` is not found in protocol
	[self.class methodSignatureForSelector: selector];
#endif
	
	block = [[block copy] autorelease];
	[self.blockMap setObject: block forKey: DICT_KEY(selector, YES)];
}
- (void) removeBlockImplementationForClassMethod: (SEL) selector
{
	NSAssert1(selector, @"%s requires a non-nil selector", _cmd);
	
	[self.blockMap removeObjectForKey: DICT_KEY(selector, YES)];
}

#pragma mark - Protocol Instance Methods

- (id) blockImplementationForMethod: (SEL) selector
{
	NSAssert1(selector, @"%s requires a non-nil selector", _cmd);
	
	return [self.blockMap objectForKey: DICT_KEY(selector, NO)];
}

- (void) implementMethod: (SEL) selector withBlock: (id) block
{
	NSAssert1(selector, @"%s requires a non-nil selector", _cmd);
	NSAssert1(block, @"%s requires a non-nil block", _cmd);
	
#ifndef NS_BLOCK_ASSERTIONS
	// Throws if `selector` is not found in protocol
	[self methodSignatureForSelector: selector];
#endif
	
	block = [[block copy] autorelease];
	[self.blockMap setObject: block forKey: DICT_KEY(selector, NO)];
}
- (void) removeBlockImplementationForMethod: (SEL) selector
{
	NSAssert1(selector, @"%s requires a non-nil selector", _cmd);
	
	[self.blockMap removeObjectForKey: DICT_KEY(selector, NO)];
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

#pragma mark - Responds To Selector

+ (BOOL) instancesRespondToSelector: (SEL) selector
{
	return [super instancesRespondToSelector: selector] || [self.blockMap objectForKey: DICT_KEY(selector, NO)];
}
+ (BOOL) respondsToSelector: (SEL) selector
{
	return [super respondsToSelector: selector] || [self.blockMap objectForKey: DICT_KEY(selector, YES)];
}
- (BOOL) respondsToSelector: (SEL) selector
{
	return [self.class instancesRespondToSelector: selector];
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

struct BlockDescriptor
{
	unsigned long reserved;
	unsigned long size;
	void *rest[1];
};

struct Block
{
	void *isa;
	int flags;
	int reserved;
	void *invoke;
	struct BlockDescriptor *descriptor;
};

enum {
	BLOCK_HAS_COPY_DISPOSE = (1 << 25),
	BLOCK_HAS_CXX_OBJ =		 (1 << 26), // Helpers have C++ code
	BLOCK_IS_GLOBAL =		 (1 << 28),
	BLOCK_HAS_STRET =		 (1 << 29), // IFF BLOCK_HAS_SIGNATURE
	BLOCK_HAS_SIGNATURE =	 (1 << 30), 
};

static const char *BlockSig(id blockObj)
{
	struct Block *block = (void *) blockObj;
	struct BlockDescriptor *descriptor = block->descriptor;
	
	assert(block->flags & BLOCK_HAS_SIGNATURE);
	
	int index = 0;
	if(block->flags & BLOCK_HAS_COPY_DISPOSE)
		index += 2;
	
	return descriptor->rest[index];
}

static void *BlockImpl(id block)
{
	return ((struct Block *) block)->invoke;
}
