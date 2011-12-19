//
//  A2BlockDelegate+BlocksKit.m
//  BlocksKit
//
//  Created by Zachary Waldowski on 12/17/11.
//  Copyright (c) 2011 Dizzy Technology. All rights reserved.
//

#import <objc/message.h>
#import <objc/runtime.h>

#import "A2BlockDelegate+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"
#import "NSObject+BlocksKit.h"

static char kRealDelegateKey;
static void bk_blockDelegateSetter(id self, SEL _cmd, id delegate);

// Forward Declarations
extern IMP imp_implementationWithBlock(void *block);
extern char *a2_property_copyAttributeValue(objc_property_t property, const char *name);

// Helpers
static SEL bk_getterForProperty(Class cls, NSString *propertyName);
static SEL bk_setterForProperty(Class cls, NSString *propertyName);
static SEL bk_getterForSetter(SEL setter);

@implementation A2DynamicDelegate (A2BlockDelegate)

- (id) realDelegate
{
	return [self associatedValueForKey: &kRealDelegateKey];
}

- (void) setRealDelegate: (id) rd
{
	[self weaklyAssociateValue: rd withKey: &kRealDelegateKey];
}

@end

@interface NSObject (A2DelegateProtocols)

+ (Protocol *) a2_dataSourceProtocol;
+ (Protocol *) a2_delegateProtocol;

@end

@interface NSObject (A2BlockDelegateBlocksKitPrivate)

+ (NSMutableDictionary *) bk_accessorsMap;

@end

@implementation NSObject (A2BlockDelegateBlocksKitPrivate)

+ (NSMutableDictionary *) bk_accessorsMap
{
	static char accessorsMapKey;
	NSMutableDictionary *accessorsMap = [self associatedValueForKey: &accessorsMapKey];
	
	if (!accessorsMap)
	{
		accessorsMap = [NSMutableDictionary dictionary];
		[self associateValue: accessorsMap withKey: &accessorsMapKey];
	}
	
	return accessorsMap;
}

@end

@implementation NSObject (A2BlockDelegateBlocksKit)

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
	if ([accessorsMap objectForKey: delegateName]) return;
	
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
	SEL getter = bk_getterForSetter(_cmd);
	
	if ([self respondsToSelector:a2_setter]) {
		id originalDelegate = [self performSelector:getter];
		if (![originalDelegate isKindOfClass:[A2DynamicDelegate class]])
			[self performSelector:a2_setter withObject:dynamicDelegate];
	}
	
	if ([delegate isEqual: self] || [delegate isEqual: dynamicDelegate]) delegate = nil;
	dynamicDelegate.realDelegate = delegate;
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
static SEL bk_getterForSetter(SEL setter)
{
	NSString *setterString = NSStringFromSelector(setter);
	if ([setterString hasPrefix:@"a2_"])
		setterString = [setterString substringFromIndex:2];
	
	// get rid of set, last colon
	setterString = [setterString substringWithRange:NSMakeRange(2, setterString.length-4)];
	
	unichar firstChar = [setterString characterAtIndex: 0];
	NSString *coda = [setterString substringFromIndex: 1];
	
	return NSSelectorFromString([NSString stringWithFormat:@"%c%@", tolower(firstChar), coda]);
}