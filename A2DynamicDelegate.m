//
//  A2DynamicDelegate.m
//  A2DynamicDelegate
//
//  Created by Alexsander Akers on 11/26/11.
//  Copyright (c) 2011 Pandamonia LLC. All rights reserved.
//

#import <objc/message.h>
#import <objc/runtime.h>
#import <pthread.h>

#import "A2DynamicDelegate.h"

#if __has_attribute(objc_arc)
	#error "At present, 'A2DynamicDelegate.m' may not be compiled with ARC. This is a limitation of the Obj-C runtime library. See here: http://j.mp/tJsoOV"
#endif

#ifndef NSAlwaysAssert
	#define NSAlwaysAssert(condition, desc, ...) \
		do { if (!(condition)) { [NSException raise: NSInternalInconsistencyException format: [NSString stringWithFormat: @"%s: %@", __PRETTY_FUNCTION__, desc], ## __VA_ARGS__]; } } while(0)
#endif

#define BLOCK_MAP_DICT_KEY(selector, isClassMethod) (selector ? [NSString stringWithFormat: @"%c%s", "+-"[!!isClassMethod], sel_getName(selector)] : nil)

static void *A2DynamicDelegateBlockMapKey;
static void *A2DynamicDelegateBlockMapMutexKey;
static void *A2DynamicDelegateProtocolKey;

static const char *BlockGetSignature(id block);
static void *BlockGetImplementation(id block);

@interface NSInvocation ()

- (void) invokeUsingIMP: (IMP)imp;

@end

@interface NSObject ()

+ (Protocol *) a2_dataSourceProtocol;
+ (Protocol *) a2_delegateProtocol;

@end

@interface A2DynamicDelegate ()

+ (A2DynamicDelegate *) dynamicDelegateForProtocol: (Protocol *) protocol; // Designated initializer

+ (Class) clusterSubclassForProtocol: (Protocol *) protocol;

// Block Implementation Abstraction
+ (id) blockImplementationForMethod: (SEL) selector classMethod: (BOOL) isClassMethod;

+ (void) implementMethod: (SEL) selector classMethod: (BOOL) isClassMethod withBlock: (id) block;
+ (void) removeBlockImplementationForMethod: (SEL) selector classMethod: (BOOL) isClassMethod;

// Block Map
+ (int) lockBlockMapMutex;
+ (int) unlockBlockMapMutex;

+ (NSMutableDictionary *) blockMap;

+ (pthread_mutex_t *) blockMapMutex;

// Forward Invocation Abstraction
+ (void) forwardInvocation: (NSInvocation *) fwdInvocation fromClass: (BOOL) isClassMethod;

// Protocol
+ (Protocol *) protocol;
+ (void) setProtocol: (Protocol *) protocol;

@end

@implementation A2DynamicDelegate

+ (A2DynamicDelegate *) dynamicDelegateForProtocol: (Protocol *) protocol
{
	// Get cluster subclass
	Class cluster = [self clusterSubclassForProtocol: protocol];
	
	// Generate unique suffix
	CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
	NSString *uuid = (NSString *) CFUUIDCreateString(kCFAllocatorDefault, cfuuid);
	CFRelease(cfuuid);
	
	// Get unique subclass name, i.e. "A2Dynamic ## ProtocolName ## / ## UUID"
	NSString *subclassName = [NSString stringWithFormat: @"%@/%@", NSStringFromClass(cluster), uuid];
	[uuid release];
	
	// Allocate subclass
	Class cls = objc_allocateClassPair(cluster, subclassName.UTF8String, 0);
	NSAlwaysAssert(cls, @"Could not allocate A2DynamicDelegate subclass for protocol <%s>", protocol_getName(protocol));
	
	// Register class
	objc_registerClassPair(cls);
	
	// Set protocol and add properties
	cls.protocol = protocol;
	
	return [[cls new] autorelease];
}

+ (Class) clusterSubclassForProtocol: (Protocol *) protocol
{
	// Get cluster name, e.g. "A2DynamicUIAlertViewDelegate"
	NSString *clusterName = [NSString stringWithFormat: @"A2Dynamic%@", NSStringFromProtocol(protocol)];
	
	// Lock mutex
	static pthread_mutex_t clusterMtx = PTHREAD_MUTEX_INITIALIZER;
	pthread_mutex_lock(&clusterMtx);
	
	// Get cluster subclass
	Class cluster = NSClassFromString(clusterName);
	if (cluster)
	{
		NSAlwaysAssert(class_getSuperclass(cluster) == [A2DynamicDelegate class], @"Dynamic delegate cluster subclass %@ must be subclass of A2DynamicDelegate", clusterName);

		// Unlock mutex
		pthread_mutex_unlock(&clusterMtx);
		
		return cluster;
	}
	
	// If the cluster doesn't exist, allocate it
	cluster = objc_allocateClassPair([A2DynamicDelegate class], clusterName.UTF8String, 0);
	NSAlwaysAssert(cluster, @"Could not allocate A2DynamicDelegate cluster subclass for protocol <%s>", protocol_getName(protocol));
	
	// And register it
	objc_registerClassPair(cluster);
	
	// Unlock mutex
	pthread_mutex_unlock(&clusterMtx);
	
	return cluster;
}

+ (id) allocWithZone: (NSZone *) zone
{
	NSAlwaysAssert(self != [A2DynamicDelegate class] && self != [self clusterSubclassForProtocol: self.protocol], @"Tried to initialize instance of abstract dynamic delegate class %s", class_getName(self.class));
	return [super allocWithZone: zone];
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
	[super dealloc];
	
	// Dispose of unique A2DynamicDelegate subclass.
	objc_disposeClassPair(self.class);
}

#pragma mark - Block Map

+ (int) unlockBlockMapMutex
{
	return pthread_mutex_unlock([self blockMapMutex]);
}
+ (int) lockBlockMapMutex
{
	return pthread_mutex_lock([self blockMapMutex]);
}

+ (NSMutableDictionary *) blockMap
{
	NSMutableDictionary *blockMap = objc_getAssociatedObject(self, &A2DynamicDelegateBlockMapKey);
	if (!blockMap)
	{
		blockMap = [NSMutableDictionary dictionary];
		objc_setAssociatedObject(self, &A2DynamicDelegateBlockMapKey, blockMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	return blockMap;
}

+ (pthread_mutex_t *) blockMapMutex
{
	NSData *mutexData = objc_getAssociatedObject(self, &A2DynamicDelegateBlockMapMutexKey);
	if (mutexData)
	{
		return (pthread_mutex_t *) mutexData.bytes;
	}
	
	pthread_mutex_t *mutex = malloc(sizeof(pthread_mutex_t));
	pthread_mutex_init(mutex, NULL);
	mutexData = [NSData dataWithBytesNoCopy: mutex length: sizeof(pthread_mutex_t)];
	objc_setAssociatedObject(self, &A2DynamicDelegateBlockMapMutexKey, mutexData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	return mutex;
}

#pragma mark - Forward Invocation

+ (void) forwardInvocation: (NSInvocation *) fwdInvocation fromClass: (BOOL) isClassMethod
{
	SEL selector = fwdInvocation.selector;
	[self lockBlockMapMutex];
	id block = [self.blockMap objectForKey: BLOCK_MAP_DICT_KEY(selector, NO)];
	[self unlockBlockMapMutex];
	
	NSAlwaysAssert(block, @"Block implementation not found for %s method %c%s", (isClassMethod) ? "class" : "instance", "+-"[!!isClassMethod], fwdInvocation.selector);
	
	const char *types = BlockGetSignature(block);
	NSMethodSignature *sig = [NSMethodSignature signatureWithObjCTypes: types];
	
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: sig];
	[invocation setTarget: block];
	
	NSMethodSignature *fwdSig = fwdInvocation.methodSignature;
	NSUInteger i, argc = fwdSig.numberOfArguments;
	
	NSMutableArray *argumentsData = [NSMutableArray arrayWithCapacity: argc - 2];
	
	for (i = 2; i < argc; ++i)
	{
		const char *argType = [fwdSig getArgumentTypeAtIndex: i];
		NSUInteger length;
		NSGetSizeAndAlignment(argType, &length, NULL);
		
		void *argBufer = malloc(length);
		[fwdInvocation getArgument: argBufer atIndex: i];
		
		// `argData` now owns the pointer and will free it upon its deallocation
		NSData *argData = [NSData dataWithBytesNoCopy: argBufer length: length];
		// `argumentsData` extends the lifetime of the pointer data past the block's invocation
		[argumentsData addObject: argumentsData];
		
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
	
	// Deallocates all data objects and in turn frees their pointers
	[argumentsData removeAllObjects];
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
		NSAlwaysAssert(types, @"Instance method %s not found in protocol <%s>", selector, protocol_getName(self.protocol));
		
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
		NSAlwaysAssert(types, @"Class method %s not found in protocol <%s>", selector, protocol_getName(self.protocol));
		
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
	return objc_getAssociatedObject(self, &A2DynamicDelegateProtocolKey);
}
+ (void) setProtocol: (Protocol *) protocol
{
	Protocol *existing = objc_getAssociatedObject(self, &A2DynamicDelegateProtocolKey);
	NSAlwaysAssert(!existing || !protocol, @"A2DynamicDelegate protocol may only be set once");
	
	if (!protocol)
		return;
	
	objc_setAssociatedObject(self, &A2DynamicDelegateProtocolKey, protocol, OBJC_ASSOCIATION_ASSIGN);
	
	BOOL success = class_addProtocol(self.class, protocol);
	NSAlwaysAssert(success, @"Protocol <%s> could not be added to %@", protocol_getName(protocol), self);
	
	unsigned int i, count;
	objc_property_t *properties = protocol_copyPropertyList(protocol, &count);
	
	for (i = 0; i < count; ++i)
	{
		objc_property_t property = properties[i];
		
		const char *name = property_getName(property);
		unsigned int attributeCount;
		objc_property_attribute_t *attributes = property_copyAttributeList(property, &attributeCount);
		
		BOOL success = class_addProperty(self.class, name, attributes, attributeCount);
		NSAlwaysAssert(success, @"Property \"%s\" could not be added to %@", name, self);
		
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

#pragma mark - Protocol Methods

+ (id) blockImplementationForMethod: (SEL) selector classMethod: (BOOL) isClassMethod
{
	[self lockBlockMapMutex];
	id block = [self.blockMap objectForKey: BLOCK_MAP_DICT_KEY(selector, isClassMethod)];
	[self unlockBlockMapMutex];
	return block;
}

+ (void) implementMethod: (SEL) selector classMethod: (BOOL) isClassMethod withBlock: (id) block
{
	NSAlwaysAssert(selector, @"Attempt to implement NULL selector");
	NSAlwaysAssert(block, @"Attempt to implement nil block (selector: %c%s)", "+-"[!!isClassMethod], sel_getName(selector));
	
	// Throws if `selector` is not found in protocol
	SEL methodSignatureSelector = (isClassMethod) ? @selector(methodSignatureForSelector:) : @selector(instanceMethodSignatureForSelector:);
	NSMethodSignature *protoSig = ((NSMethodSignature *(*)(id, SEL, SEL)) objc_msgSend)(self, methodSignatureSelector, selector);
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
	
	NSAlwaysAssert(blockIsCompatible, @"Attempt to implement %s selector with incompatible block (selector: %c%s)", isClassMethod ? "class" : "instance", "+-"[!!isClassMethod], sel_getName(selector));
	
	[self lockBlockMapMutex];
	block = [[block copy] autorelease];
	[self.blockMap setObject: block forKey: BLOCK_MAP_DICT_KEY(selector, isClassMethod)];
	[self unlockBlockMapMutex];
}
+ (void) removeBlockImplementationForMethod: (SEL) selector classMethod: (BOOL) isClassMethod
{
	NSAlwaysAssert(selector, @"Attempt to remove NULL selector");
	
	[self lockBlockMapMutex];
	[self.blockMap removeObjectForKey: BLOCK_MAP_DICT_KEY(selector, NO)];
	[self unlockBlockMapMutex];
}

#pragma mark - Protocol Class Methods

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

#pragma mark - Protocol Instance Methods

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
	
	id dynamicDelegate = objc_getAssociatedObject(self, protocol);

	if (!dynamicDelegate)
	{
		dynamicDelegate = [A2DynamicDelegate dynamicDelegateForProtocol: protocol];
		objc_setAssociatedObject(self, protocol, dynamicDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	return dynamicDelegate;
}

+ (Protocol *) a2_dataSourceProtocol
{
	NSString *className = NSStringFromClass(self.class);
	NSString *protocolName = [className stringByAppendingString: @"DataSource"];
	Protocol *protocol = objc_getProtocol(protocolName.UTF8String);
	
	NSAlwaysAssert(protocol, @"Specify protocol explicitly: could not determine data source protocol for class %@ (tried <%@>)", className, protocolName);
	return protocol;
}
+ (Protocol *) a2_delegateProtocol
{
	NSString *className = NSStringFromClass(self.class);
	NSString *protocolName = [className stringByAppendingString: @"Delegate"];
	Protocol *protocol = objc_getProtocol(protocolName.UTF8String);
	
	NSAlwaysAssert(protocol, @"Specify protocol explicitly: could not determine delegate protocol for class %@ (tried <%@>)", className, protocolName);
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
