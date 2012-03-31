//
//  A2DynamicDelegate.m
//  A2DynamicDelegate
//
//  Created by Alexsander Akers on 11/26/11.
//  Copyright (c) 2011 Pandamonia LLC. All rights reserved.
//

#import "A2DynamicDelegate.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import "blockimp.h"

#if __has_attribute(objc_arc)
	#error "At present, 'A2DynamicDelegate.m' may not be compiled with ARC. This is a limitation of the Obj-C runtime library. See here: http://j.mp/tJsoOV"
#endif

#ifndef NSAlwaysAssert
	#define NSAlwaysAssert(condition, desc, ...) \
		do { if (!(condition)) { [NSException raise: NSInternalInconsistencyException format: [NSString stringWithFormat: @"%s: %@", __PRETTY_FUNCTION__, desc], ## __VA_ARGS__]; } } while(0)
#endif

#define BLOCK_MAP_DICT_KEY(selector, isClassMethod) (selector ? [NSString stringWithFormat: @"%c%s", "+-"[!!isClassMethod], sel_getName(selector)] : nil)

static Class a2_clusterSubclassForProtocol(Protocol *protocol);

static void *A2DynamicDelegateBlockMapKey;
static void *A2DynamicDelegateImplementationsMapKey;
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
+ (NSMutableDictionary *) implementationMap;

// Block Implementations
+ (id) blockImplementationForMethod: (SEL) selector classMethod: (BOOL) isClassMethod;

+ (void) implementMethod: (SEL) selector classMethod: (BOOL) isClassMethod withBlock: (id) block;
+ (void) removeBlockImplementationForMethod: (SEL) selector classMethod: (BOOL) isClassMethod;

// Protocol
+ (Protocol *) protocol;
+ (void) setProtocol: (Protocol *) protocol;

@end

#pragma mark -

@implementation A2DynamicDelegate

@synthesize handlers = _handlers;

#pragma mark NSObject

+ (void) load
{
	backgroundQueue = dispatch_queue_create("us.pandamonia.A2DynamicDelegate.backgroundQueue", DISPATCH_QUEUE_SERIAL);
}

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
		_handlers = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

+ (NSString *) description
{
	return [NSString stringWithFormat: @"A2DynamicDelegate[%@]", NSStringFromProtocol(self.protocol)];
}
- (NSString *) description
{
	return [NSString stringWithFormat: @"<%@d %p>", [self.class description], self];
}

- (void) dealloc
{
	[_handlers release];
	
	const char *className = object_getClassName(self);
	
	[super dealloc];
	
	dispatch_async(backgroundQueue, ^{
		Class cls = objc_getClass(className);
		
		// Get all of the NSValues containing IMPs
		NSArray *implementations = [[[cls implementationMap] allValues] copy];
		
		// Dispose of unique A2DynamicDelegate subclass.
		objc_disposeClassPair(cls);
		
		// Dispose of the blocks backing the IMPs.
		[implementations enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL *stop) {
			IMP imp = [obj pointerValue];
			pl_imp_removeBlock(imp);
		}];
		
		[implementations release];
	});
}

+ (BOOL) instancesRespondToSelector: (SEL) selector
{
	IMP imp = class_getMethodImplementation(self.class, selector);
	return ([super instancesRespondToSelector: selector] && imp != _objc_msgForward) || [self.blockMap objectForKey: BLOCK_MAP_DICT_KEY(selector, NO)];
}
+ (BOOL) respondsToSelector: (SEL) selector
{
	IMP imp = class_getMethodImplementation(object_getClass(self.class), selector);
	return ([super respondsToSelector: selector] && imp != _objc_msgForward) || [self.blockMap objectForKey: BLOCK_MAP_DICT_KEY(selector, YES)];
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
		blockMap = [NSMutableDictionary dictionary];
		objc_setAssociatedObject(self, &A2DynamicDelegateBlockMapKey, blockMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	return blockMap;
}

+ (NSMutableDictionary *) implementationMap
{
	NSMutableDictionary *impsMap = objc_getAssociatedObject(self, &A2DynamicDelegateImplementationsMapKey);
	if (!impsMap)
	{
		impsMap = [NSMutableDictionary dictionary];
		objc_setAssociatedObject(self, &A2DynamicDelegateImplementationsMapKey, impsMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	return impsMap;
}

#pragma mark Block Implementations

+ (id) blockImplementationForMethod: (SEL) selector classMethod: (BOOL) isClassMethod
{
	NSString *key = BLOCK_MAP_DICT_KEY(selector, isClassMethod);
	return [self.blockMap objectForKey: key] ?: [self.implementationMap objectForKey: key];
}

+ (void) implementMethod: (SEL) selector classMethod: (BOOL) isClassMethod withBlock: (id) block
{
	NSAlwaysAssert(selector, @"Attempt to implement NULL selector");
	if (!block)
	{
		[self removeBlockImplementationForMethod: selector classMethod: isClassMethod];
		return;
	}
	
	// If the protocol does not have a method description for this selector, return.
	struct objc_method_description methodDescription = protocol_getMethodDescription(self.protocol, selector, YES, !isClassMethod);
	if (!methodDescription.name) methodDescription = protocol_getMethodDescription(self.protocol, selector, NO, !isClassMethod);
	if (!methodDescription.name) return;
	
	NSString *key = BLOCK_MAP_DICT_KEY(selector, isClassMethod);
	if (isClassMethod ? [[self superclass] respondsToSelector: selector] : [[self superclass] instancesRespondToSelector: selector])
	{
		[self.blockMap setObject: block forKey: key];
	}
	else
	{
		Class cls = isClassMethod ? object_getClass(self) : self;
		IMP imp = pl_imp_implementationWithBlock(block);
		class_replaceMethod(cls, selector, imp, methodDescription.types);
		[self.implementationMap setObject: [NSValue valueWithPointer: imp] forKey: key];
	}
}
+ (void) removeBlockImplementationForMethod: (SEL) selector classMethod: (BOOL) isClassMethod
{
	NSAlwaysAssert(selector, @"Attempt to remove NULL selector");
	NSString *key = BLOCK_MAP_DICT_KEY(selector, isClassMethod);
	if ([self.blockMap objectForKey: key])
	{
		[self.blockMap removeObjectForKey: key];
	}
	else if ([self.implementationMap objectForKey: key])
	{
		Class cls = isClassMethod ? object_getClass(self) : self;
		IMP imp = class_replaceMethod(cls, selector, _objc_msgForward, NULL);
		pl_imp_removeBlock(imp);
		[self.implementationMap removeObjectForKey: key];
	}
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
			dynamicDelegate = [[cls new] autorelease];
			objc_setAssociatedObject(self, protocol, dynamicDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
