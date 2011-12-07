//
//  A2BlockDelegate.m
//  A2DynamicDelegate
//
//  Created by Alexsander Akers on 12/6//11.
//  Copyright (c) 2011 Pandamonia LLC. All rights reserved.
//

#import <objc/runtime.h>

#import "A2BlockDelegate.h"
#import "A2DynamicDelegate.h"

#if __has_attribute(objc_arc)
	#error "At present, 'A2BlockDelegate.m' must be compiled without ARC. This is a limitation of the Obj-C runtime library. See here: http://j.mp/tJsoOV"
#endif

static void *A2BlockDelegateProtocolsKey;
static void *A2BlockDelegateMapKey;

static char *a2_property_copyAttributeValue(objc_property_t property, const char *attributeName);
static void *a2_blockPropertyGetter(id self, SEL _cmd);
static void a2_blockPropertySetter(id self, SEL _cmd, id block);

@interface NSObject ()

+ (BOOL) a2_resolveInstanceMethod: (SEL) selector;
+ (BOOL) getProtocol: (Protocol **) protocol representedSelector: (SEL *) representedSelector isSetter: (BOOL *) isSetter forPropertyAccessor: (SEL) selector;

+ (NSMutableDictionary *) propertyMapForProtocol: (Protocol *) protocol;
+ (NSMutableDictionary *) selectorCacheForProtocol: (Protocol *) protocol;

+ (NSMutableSet *) protocols;

+ (Protocol *) _dataSourceProtocol;
+ (Protocol *) _delegateProtocol;

@end

@implementation NSObject (A2BlockDelegate)

#pragma mark - Helpers

+ (BOOL) a2_resolveInstanceMethod: (SEL) selector
{
	Protocol *protocol;
	SEL representedSelector;
	BOOL isSetter;
	if ([self getProtocol: &protocol representedSelector: &representedSelector isSetter: &isSetter forPropertyAccessor: selector])
	{
		IMP implementation;
		const char *types;
		
		if (isSetter)
		{
			if (&imp_implementationWithBlock)
			{
				implementation = imp_implementationWithBlock(^(NSObject *obj, id block) {
					[[obj dynamicDelegateForProtocol: protocol] implementMethod: representedSelector withBlock: block];
				});
			}
			else
			{
				implementation = (IMP) a2_blockPropertySetter;
			}
			
			types = "v@:@?";
		}
		else
		{
			if (&imp_implementationWithBlock)
			{
				implementation = imp_implementationWithBlock(^id(NSObject *obj) {
					return [[obj dynamicDelegateForProtocol: protocol] blockImplementationForMethod: representedSelector];
				});
			}
			else
			{
				implementation = (IMP) a2_blockPropertyGetter;
			}
			
			types = "@?@:";
		}
		
		if (class_addMethod(self, selector, implementation, types)) return YES;
	}
	
	return [self a2_resolveInstanceMethod: selector];
}
+ (BOOL) getProtocol: (Protocol **) _protocol representedSelector: (SEL *) _representedSelector isSetter: (BOOL *) _isSetter forPropertyAccessor: (SEL) selector;
{
	__block BOOL found = NO;
	
	[self.protocols enumerateObjectsUsingBlock: ^(Protocol *protocol, BOOL *stop) {
		NSString *cachedData = [[self selectorCacheForProtocol: protocol] objectForKey: NSStringFromSelector(selector)];
		if (cachedData)
		{
			if (_isSetter) *_isSetter = ([cachedData characterAtIndex: 0] == 'S');
			if (_representedSelector) *_representedSelector = NSSelectorFromString([cachedData substringFromIndex: 1]);
			if (_protocol) *_protocol = protocol;
			found = *stop = YES;
		}
	}];
	
	if (found) return YES;
	
	BOOL isSetter = NO;
	
	NSString *propertyName = NSStringFromSelector(selector);
	if ([propertyName hasPrefix: @"set"])
	{
		isSetter = YES;
		unichar firstChar = [propertyName characterAtIndex: 3];
		NSString *coda = [propertyName substringFromIndex: 4];
		propertyName = [NSString stringWithFormat: @"%c%@", firstChar, coda];
	}
	
	if (!class_getProperty(self, propertyName.UTF8String))
	{
		// It's not a simple -xBlock/setXBlock: pair
		propertyName = nil;
	
		unsigned int i, count;
		objc_property_t *properties = class_copyPropertyList(self, &count);
		
		for (i = 0; i < count; ++i)
		{
			objc_property_t property = properties[i];
			
			char *setterName = a2_property_copyAttributeValue(property, "S");
			if (setterName)
			{
				objc_property_t property = properties[i];
				
				char *setterName = a2_property_copyAttributeValue(property, "S");
				if (setterName)
				{
					SEL setter = sel_getUid(setterName);
					if (sel_isEqual(selector, setter))
					{
						propertyName = [NSString stringWithUTF8String: property_getName(property)];
						isSetter = YES;
					}
					
					free(setterName);
					break; // from for-loop
				}
				
				char *getterName = a2_property_copyAttributeValue(property, "G");
				if (getterName)
				{
					SEL getter = sel_getUid(getterName);
					if (sel_isEqual(selector, getter))
					{
						propertyName = [NSString stringWithUTF8String: property_getName(property)];
					}
					
					free(getterName);
					break; // from for-loop
				}
			}
			
			free(properties);
		}
	}
	
	if (!propertyName) return NO;

	if (_isSetter) *_isSetter = isSetter;
	
	[self.protocols enumerateObjectsUsingBlock: ^(Protocol *protocol, BOOL *stop) {
		NSString *selectorName = [[self propertyMapForProtocol: protocol] objectForKey: propertyName];
		[[self selectorCacheForProtocol: protocol] setObject: [NSString stringWithFormat: @"%c%@", (isSetter) ? 'S' : 'G', selectorName] forKey: NSStringFromSelector(selector)];
		
		if (_representedSelector) *_representedSelector = NSSelectorFromString(selectorName);
		if (_protocol) *_protocol = protocol;
		found = *stop = YES;
		return;
	}];
	
	return found;
}

+ (NSDictionary *) mapForProtocol: (Protocol *) protocol
{
	[self.protocols addObject: protocol];
	
	NSMutableDictionary *map = objc_getAssociatedObject(self, &A2BlockDelegateMapKey);
	if (!map)
	{
		map = [NSMutableDictionary dictionary];
		objc_setAssociatedObject(self, &A2BlockDelegateMapKey, map, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	NSDictionary *protocolMap = [map objectForKey: NSStringFromProtocol(protocol)];
	if (!protocolMap)
	{
		protocolMap = [NSDictionary dictionaryWithObjectsAndKeys:
					   [NSMutableDictionary dictionary], @"properties",
					   [NSMutableDictionary dictionary], @"cache", nil];
		[map setObject: protocolMap forKey: NSStringFromProtocol(protocol)];
	}
	
	return protocolMap;
}

+ (NSMutableDictionary *) propertyMapForProtocol: (Protocol *) protocol
{
	return [[self mapForProtocol: protocol] objectForKey: @"properties"];
}
+ (NSMutableDictionary *) selectorCacheForProtocol: (Protocol *) protocol
{
	return [[self mapForProtocol: protocol] objectForKey: @"cache"];
}

+ (NSMutableSet *) protocols
{
	NSMutableSet *protocols = objc_getAssociatedObject(self, &A2BlockDelegateProtocolsKey);
	if (!protocols)
	{
		protocols = [NSMutableSet set];
		objc_setAssociatedObject(self, &A2BlockDelegateProtocolsKey, protocols, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	return protocols;
}

#pragma mark - Data Source

+ (void) linkCategoryBlockProperty: (NSString *) propertyName withDataSourceMethod: (SEL) selector
{
	NSDictionary *dictionary = [NSDictionary dictionaryWithObject: NSStringFromSelector(selector) forKey: propertyName];
	[self linkProtocol: self._dataSourceProtocol methods: dictionary];
}
+ (void) linkDataSourceMethods: (NSDictionary *) dictionary
{
	[self linkProtocol: self._dataSourceProtocol methods: dictionary];
}

#pragma mark - Delegate

+ (void) linkCategoryBlockProperty: (NSString *) propertyName withDelegateMethod: (SEL) selector
{
	NSDictionary *dictionary = [NSDictionary dictionaryWithObject: NSStringFromSelector(selector) forKey: propertyName];
	[self linkProtocol: self._delegateProtocol methods: dictionary];
}
+ (void) linkDelegateMethods: (NSDictionary *) dictionary
{
	[self linkProtocol: self._delegateProtocol methods: dictionary];
}

#pragma mark - Other Protocol

+ (void) linkCategoryBlockProperty: (NSString *) propertyName withProtocol: (Protocol *) protocol method: (SEL) selector
{
	NSDictionary *dictionary = [NSDictionary dictionaryWithObject: NSStringFromSelector(selector) forKey: propertyName];
	[self linkProtocol: protocol methods: dictionary];
}
+ (void) linkProtocol: (Protocol *) protocol methods: (NSDictionary *) dictionary
{
#ifndef NS_BLOCK_ASSERTIONS
	[dictionary enumerateKeysAndObjectsUsingBlock: ^(NSString *propertyName, NSString *selectorName, BOOL *stop) {
		objc_property_t property = class_getProperty(self, propertyName.UTF8String);
		NSAssert2(property, @"Property \"%@\" does not exist on class %s", propertyName, class_getName(self));
		
		char *dynamic = a2_property_copyAttributeValue(property, "D");
		NSAssert2(dynamic, @"Property \"%@\" on class %s is not dynamic", propertyName, class_getName(self));
		
		SEL selector = NSSelectorFromString(selectorName);
		struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, YES, YES);
		if (!methodDescription.name) methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
		NSAssert2(methodDescription.name, @"Instance method %@ not found in protocol <%s>", selectorName, protocol_getName(protocol));
	}];
#endif
	
	static void *didSwizzleKey;
	if (!objc_getAssociatedObject(self, &didSwizzleKey))
	{
		Class metaClass = object_getClass(self);
		SEL origSel = @selector(resolveInstanceMethod:);
		SEL newSel = @selector(a2_resolveInstanceMethod:);
		
		Method origMethod = class_getClassMethod(self, origSel);
		Method newMethod = class_getClassMethod(self, newSel);
		
		if (class_addMethod(metaClass, origSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
			class_replaceMethod(metaClass, newSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
		else
			method_exchangeImplementations(origMethod, newMethod);

		objc_setAssociatedObject(self, &didSwizzleKey, (void *) kCFBooleanTrue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	[[self propertyMapForProtocol: protocol] addEntriesFromDictionary: dictionary];
}

@end

static char *a2_property_copyAttributeValue(objc_property_t property, const char *attributeName)
{
	if (&property_copyAttributeValue)
	{
		return property_copyAttributeValue(property, attributeName);
	}
	
	const unsigned long attributeNameLength = strlen(attributeName);
	const char *attributes = property_getAttributes(property);
	
	char buffer[strlen(attributes) + 1];
	strcpy(buffer, attributes);
	
	char *state = buffer, *attribute;
	
	while ((attribute = strsep(&state, ",")))
	{
		if (!strncmp(attribute, attributeName, attributeNameLength))
		{
			break;
		}
	}
	
	const unsigned long attributeLength = strlen(attribute) - attributeLength;
	char *returnBuffer = malloc(attributeLength);
	strcpy(returnBuffer, attribute + attributeNameLength);
	return returnBuffer;
}
static void *a2_blockPropertyGetter(NSObject *self, SEL _cmd)
{
	Protocol *protocol;
	SEL representedSelector;
	if (![self.class getProtocol: &protocol representedSelector: &representedSelector isSetter: NULL forPropertyAccessor: _cmd])
		return nil;

	return [[self dynamicDelegateForProtocol: protocol] blockImplementationForMethod: representedSelector];
}
static void a2_blockPropertySetter(NSObject *self, SEL _cmd, id block)
{
	Protocol *protocol;
	SEL representedSelector;
	if (![self.class getProtocol: &protocol representedSelector: &representedSelector isSetter: NULL forPropertyAccessor: _cmd])
		return;
	
	[[self dynamicDelegateForProtocol: protocol] implementMethod: representedSelector withBlock: block];
}
