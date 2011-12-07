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
#import "A2DynamicDelegate+Private.h"

#if __has_attribute(objc_arc)
	#error "At present, 'A2DynamicDelegate.m' must be compiled without ARC. This is a limitation of the Obj-C runtime library. See here: http://j.mp/tJsoOV"
#endif

#define BLOCK_MAP_DICT_KEY(selector, isClassMethod) (selector ? [NSString stringWithFormat: @"%c%s", (isClassMethod) ? '+' : '-', sel_getName(selector)] : nil)

static void *A2BlockMapKey;
static void *A2ProtocolKey;

static const char *BlockGetSignature(id block);
static void *BlockGetImplementation(id block);

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
	NSAssert1(cls, @"Could not allocate A2DynamicDelegate subclass for protocol <%s>", protocol_getName(protocol));
	
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
	
	if (self.superclass == [A2DynamicDelegate class])
	{
		// Dispose of unique A2DynamicDelegate (but not A2BlockDelegate) subclass.
		objc_disposeClassPair(self.class);
	}
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
	id block = [self.blockMap objectForKey: BLOCK_MAP_DICT_KEY(selector, NO)];
	NSParameterAssert(block);
	
	const char *types = BlockGetSignature(block);
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
	
	[invocation invokeUsingIMP: BlockGetImplementation(block)];
	
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
	NSMethodSignature *sig = [super methodSignatureForSelector: selector];
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
		NSAssert2(success, @"Property \"%s\" could not be added to %@", name, self);
		
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
	return [self.blockMap objectForKey: BLOCK_MAP_DICT_KEY(selector, YES)];
}

- (void) implementClassMethod: (SEL) selector withBlock: (id) block
{
	NSAssert(selector, @"Attempt to implement NULL selector");
	NSAssert1(block, @"Attempt to implement nil block (selector: %s)", sel_getName(selector));
	
#ifndef NS_BLOCK_ASSERTIONS
	// Throws if `selector` is not found in protocol
	NSMethodSignature *protoSig = [self.class methodSignatureForSelector: selector];
	NSMethodSignature *blockSig = [NSMethodSignature signatureWithObjCTypes: BlockGetSignature(block)];
	
	BOOL blockIsCompatible = (strcmp(protoSig.methodReturnType, blockSig.methodReturnType) == 0);
	NSUInteger i, argc = blockSig.numberOfArguments;
	
	// Start at `i = 1` because the block type ("@?") and target object type ("@") will appear to be incompatible
	for (i = 1; i < argc && blockIsCompatible; ++i)
	{
		// `i + 1` because the protocol method sig has an extra ":" (selector) argument
		const char *protoArgType = [protoSig getArgumentTypeAtIndex: i + 1];
		const char *blockArgType = [blockSig getArgumentTypeAtIndex: i];
		
		if (strcmp(protoArgType, blockArgType))
			blockIsCompatible = NO;
	}
	
	NSAssert1(blockIsCompatible, @"Attempt to implement selector with incompatible block (selector: %s)", sel_getName(selector));
#endif
	
	block = [[block copy] autorelease];
	[self.blockMap setObject: block forKey: BLOCK_MAP_DICT_KEY(selector, YES)];
}
- (void) removeBlockImplementationForClassMethod: (SEL) selector
{
	NSAssert(selector, @"Attempt to remove NULL selector");
	
	[self.blockMap removeObjectForKey: BLOCK_MAP_DICT_KEY(selector, YES)];
}

#pragma mark - Protocol Instance Methods

- (id) blockImplementationForMethod: (SEL) selector
{
	return [self.blockMap objectForKey: BLOCK_MAP_DICT_KEY(selector, NO)];
}

- (void) implementMethod: (SEL) selector withBlock: (id) block
{
	NSAssert(selector, @"Attempt to implement NULL selector");
	NSAssert1(block, @"Attempt to implement nil block (selector: %s)", sel_getName(selector));
	
#ifndef NS_BLOCK_ASSERTIONS
	// Throws if `selector` is not found in protocol
	NSMethodSignature *protoSig = [self methodSignatureForSelector: selector];
	NSMethodSignature *blockSig = [NSMethodSignature signatureWithObjCTypes: BlockGetSignature(block)];
	
	BOOL blockIsCompatible = (strcmp(protoSig.methodReturnType, blockSig.methodReturnType) == 0);
	NSUInteger i, argc = blockSig.numberOfArguments;
	
	// Start at `i = 1` because the block type ("@?") and target object type ("@") will appear to be incompatible
	for (i = 1; i < argc && blockIsCompatible; ++i)
	{
		// `i + 1` because the protocol method sig has an extra ":" (selector) argument
		const char *protoArgType = [protoSig getArgumentTypeAtIndex: i + 1];
		const char *blockArgType = [blockSig getArgumentTypeAtIndex: i];
		
		if (strcmp(protoArgType, blockArgType))
			blockIsCompatible = NO;
	}
	
	NSAssert1(blockIsCompatible, @"Attempt to implement selector with incompatible block (selector: %s)", sel_getName(selector));
#endif
	
	block = [[block copy] autorelease];
	[self.blockMap setObject: block forKey: BLOCK_MAP_DICT_KEY(selector, NO)];
}
- (void) removeBlockImplementationForMethod: (SEL) selector
{
	NSAssert(selector, @"Attempt to remove NULL selector");
	
	[self.blockMap removeObjectForKey: BLOCK_MAP_DICT_KEY(selector, NO)];
}

#pragma mark - Responds To Selector

+ (BOOL) instancesRespondToSelector: (SEL) selector
{
	return [super instancesRespondToSelector: selector] || [self.blockMap objectForKey: BLOCK_MAP_DICT_KEY(selector, NO)];
}
+ (BOOL) respondsToSelector: (SEL) selector
{
	return [super respondsToSelector: selector] || [self.blockMap objectForKey: BLOCK_MAP_DICT_KEY(selector, YES)];
}
- (BOOL) respondsToSelector: (SEL) selector
{
	return [self.class instancesRespondToSelector: selector];
}

@end

@implementation NSObject (A2DynamicDelegate)

- (A2DynamicDelegate *) dynamicDataSource
{
	Protocol *protocol = [self.class _dataSourceProtocol];
	return [self dynamicDelegateForProtocol: protocol];
}

- (A2DynamicDelegate *) dynamicDelegate
{
	Protocol *protocol = [self.class _delegateProtocol];
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

+ (Protocol *) _dataSourceProtocol
{
	NSString *className = NSStringFromClass(self.class);
	NSString *protocolName = [className stringByAppendingString: @"DataSource"];
	Protocol *protocol = objc_getProtocol(protocolName.UTF8String);
	
	NSAssert2(protocol, @"Specify protocol explicitly: could not determine data source protocol for class %@ (tried <%@>)", className, protocolName);
	return protocol;
}
+ (Protocol *) _delegateProtocol
{
	NSString *className = NSStringFromClass(self.class);
	NSString *protocolName = [className stringByAppendingString: @"Delegate"];
	Protocol *protocol = objc_getProtocol(protocolName.UTF8String);
	
	NSAssert2(protocol, @"Specify protocol explicitly: could not determine delegate protocol for class %@ (tried <%@>)", className, protocolName);
	return protocol;
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

static const char *BlockGetSignature(id _block)
{
	struct Block *block = (void *) _block;
	struct BlockDescriptor *descriptor = block->descriptor;
	
	assert(block->flags & BLOCK_HAS_SIGNATURE);
	
	int index = 0;
	if(block->flags & BLOCK_HAS_COPY_DISPOSE)
		index += 2;
	
	return descriptor->rest[index];
}

static void *BlockGetImplementation(id block)
{
	return ((struct Block *) block)->invoke;
}
