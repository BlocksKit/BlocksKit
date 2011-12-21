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

static void bk_blockDelegateSetter(id self, SEL _cmd, id delegate);

// Block Property Setter
static void bk_blockPropertySetter(id self, SEL _cmd, id block);

// Forward Declarations
extern IMP imp_implementationWithBlock(void *block);
extern char *a2_property_copyAttributeValue(objc_property_t property, const char *name);

// Helpers
static SEL bk_getterForProperty(Class cls, NSString *propertyName);
static SEL bk_setterForProperty(Class cls, NSString *propertyName);
static void bk_lazySwizzle(void) __attribute__((constructor));

@implementation A2DynamicDelegate (A2BlockDelegate)

- (id) realDelegate
{
	return [self associatedValueForKey: &BKRealDelegateKey];
}

- (void) setRealDelegate: (id) rd
{
	[self weaklyAssociateValue: rd withKey: &BKRealDelegateKey];
}

@end

@interface NSObject (A2DelegateProtocols)

+ (Protocol *) a2_dataSourceProtocol;
+ (Protocol *) a2_delegateProtocol;

@end

@interface NSObject (A2BlockDelegatePrivate)

+ (BOOL) a2_resolveInstanceMethod: (SEL) selector;
+ (BOOL) a2_getProtocol: (Protocol **) _protocol representedSelector: (SEL *) _representedSelector forPropertyAccessor: (SEL) selector __attribute((nonnull));

@end

@interface NSObject (A2BlockDelegateBlocksKitPrivate)

+ (BOOL) bk_resolveInstanceMethod: (SEL) selector;

+ (NSMutableDictionary *) bk_accessorsMap;

@end

@implementation NSObject (A2BlockDelegateBlocksKit)

+ (BOOL) bk_resolveInstanceMethod: (SEL) selector
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
			
			if (&imp_implementationWithBlock)
			{
				implementation = imp_implementationWithBlock(^(NSObject *obj, id block) {
					A2DynamicDelegate *dynamicDelegate = [obj dynamicDelegateForProtocol: protocol];
					[dynamicDelegate implementMethod: representedSelector withBlock: block];
					
					NSMutableDictionary *propertyMap = [obj.class bk_accessorsMap];
					
					__block SEL getter, setter;
					[[propertyMap allKeysForObject: protocol] enumerateObjectsUsingBlock: ^(NSString *selectorName, NSUInteger idx, BOOL *stop) {
						if ([selectorName hasSuffix: @":"])
							setter = NSSelectorFromString(selectorName);
						else
							getter = NSSelectorFromString(selectorName);
					}];
					
					SEL a2_setter = NSSelectorFromString([@"a2_" stringByAppendingString: NSStringFromSelector(setter)]);
					
					if ([obj respondsToSelector:a2_setter]) {
						id originalDelegate = [obj performSelector:getter];
						if (![originalDelegate isKindOfClass:[A2DynamicDelegate class]])
							[obj performSelector:a2_setter withObject:dynamicDelegate];
					}
				});
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

	[accessorsMap setObject: protocol forKey: NSStringFromSelector(setter)];
	[accessorsMap setObject: protocol forKey: NSStringFromSelector(getter)];
	
	IMP implementation;
	
	if (&imp_implementationWithBlock)
	{
		implementation = imp_implementationWithBlock((__bridge void *) ^(NSObject *self, id delegate) {
			A2DynamicDelegate *dynamicDelegate = [self dynamicDelegateForProtocol: protocol];
			
			if ([self respondsToSelector:a2_setter]) {
				id originalDelegate = [self performSelector:getter];
				if (![originalDelegate isKindOfClass:[A2DynamicDelegate class]])
					[self performSelector:a2_setter withObject:dynamicDelegate];
			}
				
			if ([delegate isEqual: self] || [delegate isEqual: dynamicDelegate]) delegate = nil;
			dynamicDelegate.realDelegate = delegate;
		});
	}
	else
	{
		implementation = (IMP) bk_blockDelegateSetter;
	}
	
	const char *types = "v@:@";
	if (!class_addMethod(self, setter, implementation, types)) {
		class_addMethod(self, a2_setter, implementation, types);
		Method method = class_getInstanceMethod(self, setter);
		Method a2_method = class_getInstanceMethod(self, a2_setter);
		method_exchangeImplementations(method, a2_method);
	}
}

@end

// Block Delegate Setter (Swizzled)
static void bk_blockDelegateSetter(NSObject *self, SEL _cmd, id delegate)
{
	NSMutableDictionary *propertyMap = [self.class bk_accessorsMap];
	Protocol *protocol = [propertyMap objectForKey: NSStringFromSelector(_cmd)];
	
	A2DynamicDelegate *dynamicDelegate = [self dynamicDelegateForProtocol: protocol];
	
	SEL a2_setter = NSSelectorFromString([@"a2_" stringByAppendingString: NSStringFromSelector(_cmd)]);
	
	NSMutableArray *keys = [[propertyMap allKeysForObject: protocol] mutableCopy];
	[keys removeObject: NSStringFromSelector(_cmd)];
	SEL getter = NSSelectorFromString([keys lastObject]);
	[keys release];
	
	if ([self respondsToSelector:a2_setter]) {
		id originalDelegate = [self performSelector:getter];
		if (![originalDelegate isKindOfClass:[A2DynamicDelegate class]])
			[self performSelector:a2_setter withObject:dynamicDelegate];
	}
	
	if ([delegate isEqual: self] || [delegate isEqual: dynamicDelegate]) delegate = nil;
	dynamicDelegate.realDelegate = delegate;
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
	[[propertyMap allKeysForObject: protocol] enumerateObjectsUsingBlock: ^(NSString *selectorName, NSUInteger idx, BOOL *stop) {
		if ([selectorName hasSuffix: @":"])
			setter = NSSelectorFromString(selectorName);
		else
			getter = NSSelectorFromString(selectorName);
	}];
	
	SEL a2_setter = NSSelectorFromString([@"a2_" stringByAppendingString: NSStringFromSelector(setter)]);
	
	if ([self respondsToSelector:a2_setter]) {
		id originalDelegate = [self performSelector:getter];
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
static void bk_lazySwizzle(void)
{
	Class class = [NSObject class];
	Class metaClass = object_getClass(class);
	
	SEL origSel = @selector(resolveInstanceMethod:);
	SEL newSel = @selector(bk_resolveInstanceMethod:);
	
	Method origMethod = class_getClassMethod(class, origSel);
	Method newMethod = class_getClassMethod(class, newSel);
	
	if (class_addMethod(metaClass, origSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
		class_replaceMethod(metaClass, newSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
	else
		method_exchangeImplementations(origMethod, newMethod);
}
