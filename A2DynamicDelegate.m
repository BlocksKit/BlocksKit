//
//  A2DynamicDelegate.m
//  A2DynamicDelegate
//
//  Created by Alexsander Akers on 11/26/11.
//  Copyright (c) 2011 Pandamonia LLC. All rights reserved.
//

#import <objc/message.h>
#import <objc/runtime.h>

#import "A2DynamicDelegate.h"

#if __has_attribute(objc_arc)
	#error "At present, 'A2DynamicDelegate.m' may not be compiled with ARC. This is a limitation of the Obj-C runtime library. See here: http://j.mp/tJsoOV"
#endif

#ifndef NSAlwaysAssert
	#define NSAlwaysAssert(condition, desc, ...) \
		do { if (!(condition)) { [NSException raise: NSInternalInconsistencyException format: [NSString stringWithFormat: @"%s: %@", __PRETTY_FUNCTION__, desc], ## __VA_ARGS__]; } } while(0)
#endif

#define BLOCK_MAP_DICT_KEY(selector, isClassMethod) (selector ? [NSString stringWithFormat: @"%c%s", "+-"[!!isClassMethod], sel_getName(selector)] : nil)

static NSMutableDictionary *A2BlockDictionaryCreate(void) NS_RETURNS_RETAINED;
static const void *A2BlockDictionaryRetain(CFAllocatorRef allocator, const void *value);
static void A2BlockDictionaryRelease(CFAllocatorRef allocator, const void *value);

static Class a2_clusterSubclassForProtocol(Protocol *protocol);

static void *A2DynamicDelegateBlockMapKey;
static void *A2DynamicDelegateProtocolKey;

static dispatch_queue_t backgroundQueue = nil;

#pragma mark -

@interface NSObject (A2DelegateProtocols)

+ (Protocol *) a2_dataSourceProtocol;
+ (Protocol *) a2_delegateProtocol;

@end

#pragma mark -

@interface A2DynamicDelegate ()

// Block Map
+ (NSMutableDictionary *) blockMap;

// Block Implementations
+ (id) blockImplementationForMethod: (SEL) selector classMethod: (BOOL) isClassMethod;

+ (void) implementMethod: (SEL) selector classMethod: (BOOL) isClassMethod withBlock: (id) block;
+ (void) removeBlockImplementationForMethod: (SEL) selector classMethod: (BOOL) isClassMethod;

// Forward Invocation
+ (void) forwardInvocation: (NSInvocation *) fwdInvocation fromClass: (BOOL) isClassMethod;

// Protocol
+ (Protocol *) protocol;
+ (void) setProtocol: (Protocol *) protocol;

@end

#pragma mark -

@implementation A2DynamicDelegate

@synthesize handlers = _handlers;

#pragma mark NSObject

+ (id) allocWithZone: (NSZone *) zone
{
	NSAlwaysAssert(self != [A2DynamicDelegate class] && self != a2_clusterSubclassForProtocol(self.protocol), \
				   @"Tried to initialize instance of abstract dynamic delegate class %s", class_getName(self.class));
	return [super allocWithZone: zone];
}
- (id) init
{
	if ((self = [super init]))
	{
		_handlers = A2BlockDictionaryCreate();
	}
	
	return self;
}

+ (NSString *) description
{
	return [NSString stringWithFormat: @"A2DynamicDelegate[%@]", NSStringFromProtocol(self.protocol)];
}
- (NSString *) description
{
	return [NSString stringWithFormat: @"<%@ %p>", [self.class description], self];
}

- (void) dealloc
{
	[_handlers release];
	
	const char *className = object_getClassName(self);
	
	[super dealloc];
	
	dispatch_async(backgroundQueue, ^{
		Class cls = objc_getClass(className);
		
		// Dispose of unique A2DynamicDelegate subclass.
		objc_disposeClassPair(cls);
	});
}
+ (void) load
{
	backgroundQueue = dispatch_queue_create("us.pandamonia.A2DynamicDelegate.backgroundQueue", DISPATCH_QUEUE_SERIAL);
}

+ (void) forwardInvocation: (NSInvocation *) fwdInvocation
{
	[self forwardInvocation: fwdInvocation fromClass: YES];
}
- (void) forwardInvocation: (NSInvocation *) fwdInvocation
{
	[self.class forwardInvocation: fwdInvocation fromClass: NO];
}

+ (NSMethodSignature *) instanceMethodSignatureForSelector: (SEL) selector
{
	NSMethodSignature *sig = [super instanceMethodSignatureForSelector: selector];
	if (!sig)
	{
		struct objc_method_description methodDescription = protocol_getMethodDescription(self.protocol, selector, YES, NO);
		if (!methodDescription.name) methodDescription = protocol_getMethodDescription(self.protocol, selector, NO, NO);
		
		const char *types = methodDescription.types;
		if (types) sig = [NSMethodSignature signatureWithObjCTypes: types];
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
		if (types) sig = [NSMethodSignature signatureWithObjCTypes: types];
	}
	
	return sig;
}
- (NSMethodSignature *) methodSignatureForSelector: (SEL) selector
{
	return [super methodSignatureForSelector: selector] ?: [self.class instanceMethodSignatureForSelector: selector];
}

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

#pragma mark Block Class Method Implementations

- (id) blockImplementationForClassMethod: (SEL) selector
{
	return [self.class blockImplementationForMethod: selector classMethod: YES];
}

- (void) implementClassMethod: (SEL) selector withBlock: (id) block
{
	[self.class implementMethod: selector classMethod: YES withBlock: block];
}
- (void) removeBlockImplementationForClassMethod: (SEL) selector
{
	[self.class removeBlockImplementationForMethod: selector classMethod: YES];
}

#pragma mark Block Instance Method Implementations

- (id) blockImplementationForMethod: (SEL) selector
{
	return [self.class blockImplementationForMethod: selector classMethod: NO];
}

- (void) implementMethod: (SEL) selector withBlock: (id) block
{
	[self.class implementMethod: selector classMethod: NO withBlock: block];
}
- (void) removeBlockImplementationForMethod: (SEL) selector
{
	[self.class removeBlockImplementationForMethod: selector classMethod: NO];
}

#pragma mark - Block Map

+ (NSMutableDictionary *) blockMap
{
	NSMutableDictionary *blockMap = objc_getAssociatedObject(self, &A2DynamicDelegateBlockMapKey);
	if (!blockMap)
	{
		blockMap = A2BlockDictionaryCreate();
		objc_setAssociatedObject(self, &A2DynamicDelegateBlockMapKey, blockMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		[blockMap release];
	}
	
	return blockMap;
}

#pragma mark Block Implementations

+ (id) blockImplementationForMethod: (SEL) selector classMethod: (BOOL) isClassMethod
{
	return [self.blockMap objectForKey: BLOCK_MAP_DICT_KEY(selector, isClassMethod)];
}

+ (void) implementMethod: (SEL) selector classMethod: (BOOL) isClassMethod withBlock: (id) block
{
	NSAlwaysAssert(selector, @"Attempt to implement NULL selector");
	if (!block)
	{
		[self removeBlockImplementationForMethod: selector classMethod: isClassMethod];
		return;
	}
	
	NSMethodSignature *protoSig = isClassMethod ? [self methodSignatureForSelector:selector] : [self instanceMethodSignatureForSelector:selector];
	
	// If the protocol does not have a method signature for this selecor, return.
	if (!protoSig) return;
	
	[self.blockMap setObject: block forKey: BLOCK_MAP_DICT_KEY(selector, isClassMethod)];
}
+ (void) removeBlockImplementationForMethod: (SEL) selector classMethod: (BOOL) isClassMethod
{
	NSAlwaysAssert(selector, @"Attempt to remove NULL selector");
	
	[self.blockMap removeObjectForKey: BLOCK_MAP_DICT_KEY(selector, isClassMethod)];
}

#pragma mark Forward Invocation

+ (void) forwardInvocation: (NSInvocation *) invocation fromClass: (BOOL) isClassMethod
{
	id block = [self.blockMap objectForKey: BLOCK_MAP_DICT_KEY(invocation.selector, NO)];
	
	NSAlwaysAssert(block, @"Block implementation not found for %s method %c%s", (isClassMethod) ? "class" : "instance", "+-"[!!isClassMethod], invocation.selector);
	
	NSMethodSignature *sig = invocation.methodSignature;
	NSUInteger i, argc = sig.numberOfArguments;
	
	void *argData = NULL;
	for (i = 2; i < argc; ++i)
	{
		const char *argType = [sig getArgumentTypeAtIndex: i];
		NSUInteger length;
		NSGetSizeAndAlignment(argType, &length, NULL);
		
		argData = realloc(argData, length);
		[invocation getArgument: argData atIndex: i];
		[invocation setArgument: argData atIndex: i - 1];
	}
	free(argData);
	
	[invocation invokeWithTarget: block];
}

#pragma mark Protocol

+ (Protocol *) protocol
{
	Class class = self;
	while (class.superclass != [A2DynamicDelegate class]) class = class.superclass;
	if (!class) return nil;
	
	return objc_getAssociatedObject(class, &A2DynamicDelegateProtocolKey);
}
+ (void) setProtocol: (Protocol *) protocol
{
	Class class = self;
	while (class.superclass != [A2DynamicDelegate class]) class = class.superclass;
	if (!class) return;
	
	// If protocol is already set, return
	if ([self protocol]) return;
	
	objc_setAssociatedObject(class, &A2DynamicDelegateProtocolKey, protocol, OBJC_ASSOCIATION_ASSIGN);
	
	// Make class conform to protocol (if it doesn't already)
	if (!class_conformsToProtocol(class, protocol))
	{
		BOOL success = class_addProtocol(class, protocol);
		NSAlwaysAssert(success, @"Protocol <%s> could not be added to %@", protocol_getName(protocol), class);
	}
	
	unsigned int i, count;
	objc_property_t *properties = protocol_copyPropertyList(protocol, &count);
	
	for (i = 0; i < count; ++i)
	{
		objc_property_t property = properties[i];
		
		const char *name = property_getName(property);
		
		unsigned int attributeCount;
		objc_property_attribute_t *attributes = property_copyAttributeList(property, &attributeCount);
		
		if (class_getProperty(class, name))
		{
			const char *attrStr = property_getAttributes(property);
			const char *cAttrStr = property_getAttributes(class_getProperty(class, name));
			
			NSAlwaysAssert(strcmp(attrStr, cAttrStr) == 0, @"Property \"%s\" on class %s does not match declaration in protocol <%s>", name, class_getName(class), protocol_getName(protocol));
		}
		else
		{
			BOOL success = class_addProperty(class, name, attributes, attributeCount);
			NSAlwaysAssert(success, @"Property \"%s\" could not be added to %@", name, class);
		}
		
		free(attributes);
	}
	
	free(properties);
}

@end

#pragma mark - Internal functions

static Class a2_clusterSubclassForProtocol(Protocol *protocol) {
	// Get cluster name, e.g. "A2DynamicUIAlertViewDelegate"
	NSString *clusterName = [NSString stringWithFormat: @"A2Dynamic%@", NSStringFromProtocol(protocol)];
	
	// Get cluster subclass
	Class cluster = NSClassFromString(clusterName);
	if (cluster)
	{
		NSAlwaysAssert(class_getSuperclass(cluster) == [A2DynamicDelegate class], @"Dynamic delegate cluster subclass %@ must be subclass of A2DynamicDelegate", clusterName);
		
		// Set protocol and add properties
		[cluster setProtocol: protocol];
		
		return cluster;
	}
	
	// If the cluster doesn't exist, allocate it
	cluster = objc_allocateClassPair([A2DynamicDelegate class], clusterName.UTF8String, 0);
	NSAlwaysAssert(cluster, @"Could not allocate A2DynamicDelegate cluster subclass for protocol <%s>", protocol_getName(protocol));
	
	// And register it
	objc_registerClassPair(cluster);
	
	// Set protocol and add properties
	[cluster setProtocol: protocol];
	
	return cluster;
}

#pragma mark - NSObject categories

@implementation NSObject (A2DynamicDelegate)

- (id) dynamicDataSource
{
	Protocol *protocol = [self.class a2_dataSourceProtocol];
	return [self dynamicDelegateForProtocol: protocol];
}
- (id) dynamicDelegate
{
	Protocol *protocol = [self.class a2_delegateProtocol];
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
	
	__block id dynamicDelegate;
	
	dispatch_sync(backgroundQueue, ^{
		dynamicDelegate = objc_getAssociatedObject(self, protocol);
		
		if (!dynamicDelegate)
		{
			// Get cluster subclass
			Class cluster = a2_clusterSubclassForProtocol(protocol);
			
			// Generate unique suffix
			CFUUIDRef cfuuid = CFUUIDCreate(NULL);
			NSString *uuid = (NSString *) CFUUIDCreateString(NULL, cfuuid);
			CFRelease(cfuuid);
			
			// Get unique subclass name, i.e. "A2Dynamic ## ProtocolName ## / ## UUID"
			NSString *subclassName = [NSString stringWithFormat: @"%@/%@", NSStringFromClass(cluster), uuid];
			[uuid release];
			
			// Allocate subclass
			Class cls = objc_allocateClassPair(cluster, subclassName.UTF8String, 0);
			NSAlwaysAssert(cls, @"Could not allocate A2DynamicDelegate subclass for protocol <%s>", protocol_getName(protocol));
			
			// Register class
			objc_registerClassPair(cls);
			
			// Create and associate an instance
			dynamicDelegate = [cls new];
			objc_setAssociatedObject(self, protocol, dynamicDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
			[dynamicDelegate release];
		}
	});
	
	return dynamicDelegate;
}

@end

@implementation NSObject (A2DelegateProtocols)

+ (Protocol *) a2_dataSourceProtocol
{
	NSString *className = NSStringFromClass([self class]);
	NSString *protocolName = [className stringByAppendingString: @"DataSource"];
	Protocol *protocol = objc_getProtocol(protocolName.UTF8String);
	
	NSAlwaysAssert(protocol, @"Specify protocol explicitly: could not determine data source protocol for class %@ (tried <%@>)", className, protocolName);
	return protocol;
}
+ (Protocol *) a2_delegateProtocol
{
	NSString *className = NSStringFromClass([self class]);
	NSString *protocolName = [className stringByAppendingString: @"Delegate"];
	Protocol *protocol = objc_getProtocol(protocolName.UTF8String);
	
	NSAlwaysAssert(protocol, @"Specify protocol explicitly: could not determine delegate protocol for class %@ (tried <%@>)", className, protocolName);
	return protocol;
}

@end

#pragma mark - Block dictionary

static NSMutableDictionary *A2BlockDictionaryCreate(void) {
	CFDictionaryValueCallBacks valueCallBacks = kCFTypeDictionaryValueCallBacks;
	valueCallBacks.retain = A2BlockDictionaryRetain;
	valueCallBacks.release = A2BlockDictionaryRelease;
	
	return (NSMutableDictionary *)CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &valueCallBacks);
}

static const void *A2BlockDictionaryRetain(__unused CFAllocatorRef allocator, const void *value)
{
	return Block_copy(value);
}

static void A2BlockDictionaryRelease(__unused CFAllocatorRef allocator, const void *value)
{
	Block_release(value);
}