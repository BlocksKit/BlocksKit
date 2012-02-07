//
//  A2BlockDelegate+BlocksKit.m
//  BlocksKit
//
//  Created by Zachary Waldowski on 12/17/11.
//  Copyright (c) 2011 Dizzy Technology. All rights reserved.
//

#import "A2BlockDelegate+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"
#import <objc/message.h>
#import <objc/runtime.h>

extern void *A2BlockDelegateProtocolsKey;
extern void *A2BlockDelegateMapKey;

static char BKAccessorsMapKey;
static char BKRealDelegateKey;

static BOOL bk_resolveInstanceMethod(id self, SEL _cmd, SEL selector);

static void bk_blockDelegateSetter(id self, SEL _cmd, id delegate);
static id bk_blockDelegateGetter(id self, SEL _cmd);

// Block Property Setter
static void bk_blockPropertySetter(id self, SEL _cmd, id block);

// Forward Declarations
extern IMP imp_implementationWithBlock(void *block) __attribute__((weak_import));
extern char *a2_property_copyAttributeValue(objc_property_t property, const char *name);

// Helpers
static SEL bk_getterForProperty(Class cls, NSString *propertyName);
static SEL bk_setterForProperty(Class cls, NSString *propertyName);

@interface NSObject ()

+ (Protocol *) a2_dataSourceProtocol;
+ (Protocol *) a2_delegateProtocol;

+ (BOOL) a2_resolveInstanceMethod: (SEL) selector;
+ (BOOL) a2_getProtocol: (Protocol **) _protocol representedSelector: (SEL *) _representedSelector forPropertyAccessor: (SEL) selector __attribute((nonnull));

+ (BOOL) bk_resolveInstanceMethod: (SEL) selector;

@end

@interface NSObject (A2BlockDelegateBlocksKitPrivate)

+ (NSMutableDictionary *) bk_accessorsMap;

@end

@implementation A2DynamicDelegate (A2BlockDelegate)

- (id) forwardingTargetForSelector: (SEL) aSelector
{
	if (![self blockImplementationForMethod: aSelector] && [self.realDelegate respondsToSelector: aSelector])
		return self.realDelegate;
	
	return [super forwardingTargetForSelector: aSelector];
}

- (id) realDelegate
{
	return [self associatedValueForKey: &BKRealDelegateKey];
}
- (void) setRealDelegate: (id) rd
{
	[self associateValue:rd withKey:&BKRealDelegateKey];
}

@end

@implementation NSObject (A2BlockDelegateBlocksKitPrivate)

+ (void) load
{
	Class class = [NSObject class];
	Class metaClass = object_getClass(class);
	
	SEL origSel = @selector(resolveInstanceMethod:);
	SEL newSel = @selector(bk_resolveInstanceMethod:);
	
	Method origMethod = class_getClassMethod(class, origSel);
	
	class_addMethod(metaClass, newSel, (IMP)bk_resolveInstanceMethod, method_getTypeEncoding(origMethod));
	
	Method newMethod = class_getClassMethod(class, newSel);
	
	method_exchangeImplementations(origMethod, newMethod);
}

+ (NSMutableDictionary *) bk_accessorsMap
{
	NSMutableDictionary *accessorsMap = [self associatedValueForKey: &BKAccessorsMapKey];
	
	if (!accessorsMap)
	{
		accessorsMap = [NSMutableDictionary dictionary];
		[self associateValue: accessorsMap withKey: &BKAccessorsMapKey];
	}
	
	return accessorsMap;
}

#pragma mark - Register Dynamic Delegate

+ (void) registerDynamicDataSource
{
	[self registerDynamicDelegateNamed: @"dataSource" forProtocol: [self a2_dataSourceProtocol]];
}
+ (void) registerDynamicDelegate
{
	[self registerDynamicDelegateNamed: @"delegate" forProtocol: [self a2_delegateProtocol]];
}

+ (void) registerDynamicDataSourceNamed: (NSString *) dataSourceName
{
	[self registerDynamicDelegateNamed: dataSourceName forProtocol: [self a2_dataSourceProtocol]];
}
+ (void) registerDynamicDelegateNamed: (NSString *) delegateName
{
	[self registerDynamicDelegateNamed: delegateName forProtocol: [self a2_delegateProtocol]];
}

+ (void) registerDynamicDelegateNamed: (NSString *) delegateName forProtocol: (Protocol *) protocol
{
	NSMutableDictionary *accessorsMap = [self bk_accessorsMap];

	NSString *key = [@"@" stringByAppendingString: delegateName];
	if ([accessorsMap objectForKey: key]) return;
	
	[accessorsMap setObject: (__bridge id) kCFBooleanTrue forKey: key];
	
	SEL getter = bk_getterForProperty(self, delegateName);
	SEL setter = bk_setterForProperty(self, delegateName);
	
	SEL a2_setter = NSSelectorFromString([@"a2_" stringByAppendingString: NSStringFromSelector(setter)]);
	SEL a2_getter = NSSelectorFromString([@"a2_" stringByAppendingString: NSStringFromSelector(getter)]);
	
	NSString *protocolName = NSStringFromProtocol(protocol);
	[accessorsMap setObject: protocolName forKey: NSStringFromSelector(setter)];
	[accessorsMap setObject: protocolName forKey: NSStringFromSelector(getter)];
	
	IMP setterImplementation, getterImplementation;
	
	if (imp_implementationWithBlock != NULL)
	{
		setterImplementation = imp_implementationWithBlock((__bridge void *) [[^(NSObject *self, id delegate) {
			A2DynamicDelegate *dynamicDelegate = [self dynamicDelegateForProtocol: protocol];
			
			if ([self respondsToSelector:a2_setter]) {
				id originalDelegate = [self performSelector:a2_getter];
				if (![originalDelegate isKindOfClass:[A2DynamicDelegate class]])
					[self performSelector:a2_setter withObject:dynamicDelegate];
			}
			
			if ([delegate isEqual: self] || [delegate isEqual: dynamicDelegate]) delegate = nil;
			dynamicDelegate.realDelegate = delegate;
		} copy] autorelease]);
		
		getterImplementation = imp_implementationWithBlock((__bridge void *) [[^id(NSObject *self) {
			A2DynamicDelegate *dynamicDelegate = [self dynamicDelegateForProtocol: protocol];
			return dynamicDelegate.realDelegate;
		} copy] autorelease]);
	}
	else
	{
		setterImplementation = (IMP) bk_blockDelegateSetter;
		getterImplementation = (IMP) bk_blockDelegateGetter;
	}
	
	const char *setterTypes = "v@:@";
	if (!class_addMethod(self, setter, setterImplementation, setterTypes)) {
		class_addMethod(self, a2_setter, setterImplementation, setterTypes);
		Method method = class_getInstanceMethod(self, setter);
		Method a2_method = class_getInstanceMethod(self, a2_setter);
		method_exchangeImplementations(method, a2_method);
	}
	
	const char *getterTypes = "@@:";
	if (!class_addMethod(self, getter, getterImplementation, getterTypes)) {
		class_addMethod(self, a2_getter, getterImplementation, getterTypes);
		Method method = class_getInstanceMethod(self, getter);
		Method a2_method = class_getInstanceMethod(self, a2_getter);
		method_exchangeImplementations(method, a2_method);
	}
}

@end

#pragma mark - Functions

static BOOL bk_resolveInstanceMethod(id self, SEL _cmd, SEL selector)
{
	// Check for existence of `-a2_protocols` and `-a2_mapForProtocol:`, respectively
	if (objc_getAssociatedObject(self, &A2BlockDelegateMapKey) && objc_getAssociatedObject(self, &A2BlockDelegateProtocolsKey))
	{
		Protocol *protocol;
		SEL representedSelector;
		
		NSUInteger argc = [[NSStringFromSelector(selector) componentsSeparatedByString: @":"] count] - 1;
		if (argc == 1 && [self a2_getProtocol: &protocol representedSelector: &representedSelector forPropertyAccessor: selector])
		{
			IMP implementation;
			const char *types = "v@:@?";
			
			if (imp_implementationWithBlock != NULL)
			{
				implementation = imp_implementationWithBlock([[^(NSObject *obj, id block) {
					A2DynamicDelegate *dynamicDelegate = [obj dynamicDelegateForProtocol: protocol];
					[dynamicDelegate implementMethod: representedSelector withBlock: block];
					
					NSMutableDictionary *propertyMap = [obj.class bk_accessorsMap];
					
					__block SEL getter, setter;
					[[propertyMap allKeysForObject: NSStringFromProtocol(protocol)] enumerateObjectsUsingBlock: ^(NSString *selectorName, NSUInteger idx, BOOL *stop) {
						if ([selectorName hasSuffix: @":"])
							setter = NSSelectorFromString(selectorName);
						else
							getter = NSSelectorFromString(selectorName);
					}];
					
					SEL a2_setter = NSSelectorFromString([@"a2_" stringByAppendingString: NSStringFromSelector(setter)]);
					SEL a2_getter = NSSelectorFromString([@"a2_" stringByAppendingString: NSStringFromSelector(getter)]);
					
					if ([obj respondsToSelector:a2_setter]) {
						id originalDelegate = [obj performSelector:a2_getter];
						if (![originalDelegate isKindOfClass:[A2DynamicDelegate class]])
							[obj performSelector:a2_setter withObject:dynamicDelegate];
					}
				} copy] autorelease]);
			}
			else
			{
				implementation = (IMP) bk_blockPropertySetter;
			}
			
			if (class_addMethod(self, selector, implementation, types)) return YES;
		}
	}
	
	return [self bk_resolveInstanceMethod: selector];
}

// Block Delegate Setter (Swizzled)
static void bk_blockDelegateSetter(NSObject *self, SEL _cmd, id delegate)
{
	NSMutableDictionary *propertyMap = [self.class bk_accessorsMap];
	NSString *protocolName = [propertyMap objectForKey: NSStringFromSelector(_cmd)];
	
	A2DynamicDelegate *dynamicDelegate = [self dynamicDelegateForProtocol: NSProtocolFromString(protocolName)];
	
	SEL a2_setter = NSSelectorFromString([@"a2_" stringByAppendingString: NSStringFromSelector(_cmd)]);
	
	NSMutableArray *keys = [[propertyMap allKeysForObject: protocolName] mutableCopy];
	[keys removeObject: NSStringFromSelector(_cmd)];
	SEL getter = NSSelectorFromString([keys lastObject]);
	[keys release];
	
	SEL a2_getter = NSSelectorFromString([@"a2_" stringByAppendingString: NSStringFromSelector(getter)]);
	
	if ([self respondsToSelector:a2_setter]) {
		id originalDelegate = [self performSelector:a2_getter];
		if (![originalDelegate isKindOfClass:[A2DynamicDelegate class]])
			[self performSelector:a2_setter withObject:dynamicDelegate];
	}
	
	if ([delegate isEqual: self] || [delegate isEqual: dynamicDelegate]) delegate = nil;
	dynamicDelegate.realDelegate = delegate;
}

// Block Delegate Getter (Swizzled)
static id bk_blockDelegateGetter(NSObject *self, SEL _cmd)
{
	NSMutableDictionary *propertyMap = [self.class bk_accessorsMap];
	NSString *protocolName = [propertyMap objectForKey: NSStringFromSelector(_cmd)];
	A2DynamicDelegate *dynamicDelegate = [self dynamicDelegateForProtocol: NSProtocolFromString(protocolName)];
	return dynamicDelegate.realDelegate;
}

// Block Property Setter
static void bk_blockPropertySetter(NSObject *self, SEL _cmd, id block)
{
	Protocol *protocol;
	SEL representedSelector;
	if (![self.class a2_getProtocol: &protocol representedSelector: &representedSelector forPropertyAccessor: _cmd])
		return;
	
	A2DynamicDelegate *dynamicDelegate = [self dynamicDelegateForProtocol: protocol];
	[dynamicDelegate implementMethod: representedSelector withBlock: block];
	
	NSMutableDictionary *propertyMap = [self.class bk_accessorsMap];

	__block SEL getter, setter;
	[[propertyMap allKeysForObject: NSStringFromProtocol(protocol)] enumerateObjectsUsingBlock: ^(NSString *selectorName, NSUInteger idx, BOOL *stop) {
		if ([selectorName hasSuffix: @":"])
			setter = NSSelectorFromString(selectorName);
		else
			getter = NSSelectorFromString(selectorName);
	}];
	
	SEL a2_setter = NSSelectorFromString([@"a2_" stringByAppendingString: NSStringFromSelector(setter)]);
	SEL a2_getter = NSSelectorFromString([@"a2_" stringByAppendingString: NSStringFromSelector(getter)]);
	
	if ([self respondsToSelector:a2_setter]) {
		id originalDelegate = [self performSelector:a2_getter];
		if (![originalDelegate isKindOfClass:[A2DynamicDelegate class]])
			[self performSelector:a2_setter withObject:dynamicDelegate];
	}
}

// Helpers
static SEL bk_getterForProperty(Class cls, NSString *propertyName)
{
	SEL getter = NULL;
	objc_property_t property = class_getProperty(cls, propertyName.UTF8String);
	if (property)
	{
		char *getterName = a2_property_copyAttributeValue(property, "G");
		if (getterName) getter = sel_getUid(getterName);
		free(getterName);
	}
	
	if (!getter)
	{
		getter = NSSelectorFromString(propertyName);
	}
	
	return getter;
}
static SEL bk_setterForProperty(Class cls, NSString *propertyName)
{
	SEL setter = NULL;
	objc_property_t property = class_getProperty(cls, propertyName.UTF8String);
	if (property)
	{
		char *setterName = a2_property_copyAttributeValue(property, "S");
		if (setterName) setter = sel_getUid(setterName);
		free(setterName);
	}
	
	if (!setter)
	{
		unichar firstChar = [propertyName characterAtIndex: 0];
		NSString *coda = [propertyName substringFromIndex: 1];
		
		setter = NSSelectorFromString([NSString stringWithFormat: @"set%c%@:", toupper(firstChar), coda]);
	}
	
	return setter;
}
