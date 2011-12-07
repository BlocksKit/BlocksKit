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
#import "A2DynamicDelegate+Private.h"

#if __has_attribute(objc_arc)
	#error "At present, 'A2BlockDelegate.m' must be compiled without ARC. This is a limitation of the Obj-C runtime library. See here: http://j.mp/tJsoOV"
#endif

#define SELECTOR_CACHE_DATA(propertyName, isSetter) (propertyName ? [NSString stringWithFormat: @"%c%@", (isSetter) ? 'S' : 'G', propertyName] : nil)

static void *A2BlockDelegatePropertyMapKey;
static void *A2BlockDelegateSelectorCacheKey;

static char *a2_property_copyAttributeValue(objc_property_t property, const char *attributeName);
static void *a2_blockPropertyGetter(id self, SEL _cmd);
static void a2_blockPropertySetter(id self, SEL _cmd, void *block);

@interface A2BlockDelegate : A2DynamicDelegate

+ (BOOL) a2_resolveInstanceMethod: (SEL) selector;

+ (Class) subclassForProtocol: (Protocol *) protocol;

+ (NSMutableDictionary *) propertyMap;
+ (NSMutableDictionary *) selectorCache;

@end

@implementation A2BlockDelegate

+ (A2DynamicDelegate *) dynamicDelegateForProtocol: (Protocol *) protocol
{
	Class cls = [self subclassForProtocol: protocol];
	A2BlockDelegate *delegate = [[cls new] autorelease];
	delegate.protocol = protocol;
	
	return delegate;
}

+ (BOOL) a2_resolveInstanceMethod: (SEL) selector
{
	NSString *selectorName = NSStringFromSelector(selector);
	__block BOOL isSetter = NO;
	if ([selectorName hasPrefix: @"set"])
	{
		isSetter = YES;
		unichar firstChar = [selectorName characterAtIndex: 3];
		NSString *coda = [selectorName substringFromIndex: 4];
		selectorName = [NSString stringWithFormat: @"%c%@", firstChar, coda];
	}
	
	__block BOOL cacheHasData = NO;
	if (!class_getProperty(self, selectorName.UTF8String)) // In case it's not a simple -ivar/setVar: pair?
	{
		NSString *propertyData = [self.selectorCache objectForKey: NSStringFromSelector(selector)];
		if (propertyData)
		{
			cacheHasData = YES;
			isSetter = ([propertyData characterAtIndex: 0] == 'S');
		}
		else
		{
			[self.blockMap enumerateKeysAndObjectsUsingBlock: ^(NSString *_propertyName, NSString *selectorName, BOOL *stop) {
				objc_property_t _property = class_getProperty(self, _propertyName.UTF8String);
				
				char *setterName = a2_property_copyAttributeValue(_property, "S");
				if (setterName)
				{
					SEL setter = sel_getUid(setterName);
					if (sel_isEqual(selector, setter))
					{
						[self.selectorCache setObject: SELECTOR_CACHE_DATA(_propertyName, YES) forKey: NSStringFromSelector(selector)];
						cacheHasData = YES;
						isSetter = YES;
						*stop = YES;
					}
					
					free(setterName);
					
					return;
				}
				
				char *getterName = a2_property_copyAttributeValue(_property, "G");
				if (getterName)
				{
					SEL getter = sel_getUid(getterName);
					if (sel_isEqual(selector, getter))
					{
						[self.selectorCache setObject: SELECTOR_CACHE_DATA(_propertyName, NO) forKey: NSStringFromSelector(selector)];
						cacheHasData = YES;
						*stop = YES;
					}
					
					free(getterName);
					
					return;
				}
			}];
			
		}
		
		if (!cacheHasData)
			return NO;
	}
	
	IMP implementation;
	const char *types;
	
	if (isSetter)
	{
		if (&imp_implementationWithBlock)
		{
			implementation = imp_implementationWithBlock(^(A2BlockDelegate *_self, void *block) {
				[_self implementMethod: selector withBlock: block];
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
			implementation = imp_implementationWithBlock(^(A2BlockDelegate *_self) {
				return [_self blockImplementationForMethod: selector];
			});
		}
		else
		{
			implementation = (IMP) a2_blockPropertyGetter;
		}
		
		types = "@?@:";
	}
	
	BOOL success = class_addMethod(self, selector, implementation, types);
	if (!success) success = [self a2_resolveInstanceMethod: selector];
	
	return success;
}

+ (Class) subclassForProtocol: (Protocol *) protocol
{
	NSString *subclassName = [NSString stringWithFormat: @"A2BlockDelegate-%@", NSStringFromProtocol(protocol)];
	Class cls = NSClassFromString(subclassName);
	if (!cls)
	{
		cls = objc_allocateClassPair([A2BlockDelegate class], subclassName.UTF8String, 0);
		NSAssert1(cls, @"Could not allocate A2BlockDelegate subclass for protocol <%s>", protocol_getName(protocol));
		
		objc_registerClassPair(cls);
	}
	
	return cls;
}

+ (NSMutableDictionary *) propertyMap
{
	NSMutableDictionary *propertyMap = objc_getAssociatedObject(self, &A2BlockDelegatePropertyMapKey);
	if (!propertyMap)
	{
		propertyMap = [NSMutableDictionary dictionary];
		objc_setAssociatedObject(self, &A2BlockDelegatePropertyMapKey, propertyMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	return propertyMap;
}
+ (NSMutableDictionary *) selectorCache
{
	if (&imp_implementationWithBlock)
		return nil;
	
	NSMutableDictionary *selectorCache = objc_getAssociatedObject(self, &A2BlockDelegateSelectorCacheKey);
	if (!selectorCache)
	{
		selectorCache = [NSMutableDictionary dictionary];
		objc_setAssociatedObject(self, &A2BlockDelegateSelectorCacheKey, selectorCache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	return selectorCache;
}

@end

@interface NSObject ()

+ (NSMutableDictionary *) propertyMapForDataSource;
+ (NSMutableDictionary *) propertyMapForDelegate;
+ (NSMutableDictionary *) propertyMapForProtocol: (Protocol *) protocol;

@end

@implementation NSObject (A2BlockDelegate)

#pragma mark - Helpers

+ (NSMutableDictionary *) propertyMapForDataSource
{
	Protocol *protocol = [self _dataSourceProtocol];
	return [self propertyMapForProtocol: protocol];
}
+ (NSMutableDictionary *) propertyMapForDelegate
{
	Protocol *protocol = [self _delegateProtocol];
	return [self propertyMapForProtocol: protocol];
}
+ (NSMutableDictionary *) propertyMapForProtocol: (Protocol *) protocol
{
	return [[A2BlockDelegate subclassForProtocol: protocol] propertyMap];
}

#pragma mark - Data Source

+ (void) linkCategoryBlockProperty: (NSString *) propertyName withDataSourceMethod: (SEL) selector
{
	NSDictionary *dictionary = [NSDictionary dictionaryWithObject: NSStringFromSelector(selector) forKey: propertyName];
	[self linkDataSourceMethods: dictionary];
}
+ (void) linkDataSourceMethods: (NSDictionary *) dictionary
{
	[self.propertyMapForDataSource addEntriesFromDictionary: dictionary];
}

#pragma mark - Delegate

+ (void) linkCategoryBlockProperty: (NSString *) propertyName withDelegateMethod: (SEL) selector
{
	NSDictionary *dictionary = [NSDictionary dictionaryWithObject: NSStringFromSelector(selector) forKey: propertyName];
	[self linkDelegateMethods: dictionary];
}
+ (void) linkDelegateMethods: (NSDictionary *) dictionary
{
	[self.propertyMapForDelegate addEntriesFromDictionary: dictionary];
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
static void *a2_blockPropertyGetter(A2BlockDelegate *self, SEL _cmd)
{
	if (&imp_implementationWithBlock)
		return NULL;
	
	NSString *propertyName = [[[self.class selectorCache] objectForKey: NSStringFromSelector(_cmd)] substringFromIndex: 1];
	NSString *selectorName = [[self.class propertyMap] objectForKey: propertyName];
	SEL selector = NSSelectorFromString(selectorName);
	return [self blockImplementationForMethod: selector];
}
static void a2_blockPropertySetter(A2BlockDelegate *self, SEL _cmd, void *block)
{
	if (&imp_implementationWithBlock)
		return;
	
	NSString *propertyName = [[[self.class selectorCache] objectForKey: NSStringFromSelector(_cmd)] substringFromIndex: 1];
	NSString *selectorName = [[self.class propertyMap] objectForKey: propertyName];
	SEL selector = NSSelectorFromString(selectorName);
	[self implementMethod: selector withBlock: block];
}
