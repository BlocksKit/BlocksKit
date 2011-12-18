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

@interface A2DynamicDelegate ()

@property (nonatomic, assign, readwrite) id realDelegate;

@end

static void bk_blockDelegateSetter(id self, SEL _cmd, id delegate);

// Forward Declarations
extern IMP imp_implementationWithBlock(void *block);
extern char *a2_property_copyAttributeValue(objc_property_t property, const char *name);

@interface NSObject (A2DelegateProtocols)

+ (Protocol *) a2_dataSourceProtocol;
+ (Protocol *) a2_delegateProtocol;

@end

@implementation NSObject (A2BlockDelegateBlocksKit)

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
	
	SEL setter = NULL;
	objc_property_t property = class_getProperty(self, delegateName.UTF8String);
	if (property)
	{
		char *setterName = a2_property_copyAttributeValue(property, "S");
		if (setterName) setter = sel_getUid(setterName);
		free(setterName);
	}
	
	if (!setter)
	{
		unichar firstChar = [delegateName characterAtIndex: 0];
		NSString *coda = [delegateName substringFromIndex: 1];
		
		setter = NSSelectorFromString([NSString stringWithFormat: @"set%c%@:", toupper(firstChar), coda]);
	}
	
	[accessorsMap setObject: protocol forKey: NSStringFromSelector(setter)];
	
	IMP implementation;
	
	if (&imp_implementationWithBlock)
	{
		implementation = imp_implementationWithBlock((__bridge void *) ^(NSObject *self, SEL _cmd, id delegate) {
			A2DynamicDelegate *dynamicDelegate = [self dynamicDelegateForProtocol: protocol];
			
			if ([delegate isEqual: self] || [delegate isEqual: dynamicDelegate]) delegate = nil;
			dynamicDelegate.realDelegate = delegate;
		});
	}
	else
	{
		implementation = (IMP) bk_blockDelegateSetter;
	}
	
	const char *types = "v@:@";
	SEL a2_setter = NSSelectorFromString([@"a2_" stringByAppendingString: NSStringFromSelector(setter)]);
	
	class_addMethod(self, a2_setter, implementation, types);
	
	Method method = class_getInstanceMethod(self, setter);
	Method a2_method = class_getInstanceMethod(self, a2_setter);
	
	if (class_addMethod(self, setter, method_getImplementation(a2_method), types))
		class_replaceMethod(self, a2_setter, method_getImplementation(method), types);
	else
		method_exchangeImplementations(method, a2_method);
}

@end

// Block Delegate Setter (Swizzled)
static void bk_blockDelegateSetter(NSObject *self, SEL _cmd, id delegate)
{
	NSMutableDictionary *propertyMap = [self.class bk_accessorsMap];
	Protocol *protocol = [propertyMap objectForKey: NSStringFromSelector(_cmd)];
	
	A2DynamicDelegate *dynamicDelegate = [self dynamicDelegateForProtocol: protocol];
	
	if ([delegate isEqual: self] || [delegate isEqual: dynamicDelegate]) delegate = nil;
	dynamicDelegate.realDelegate = delegate;
}

// Helpers
static SEL bk_fakeAccessor(SEL accessor)
{
	if ([NSStringFromSelector(accessor) hasPrefix: @"bk_"])
		return NSSelectorFromString([NSStringFromSelector(accessor) substringFromIndex: 3]);
	else
		return NSSelectorFromString([NSString stringWithFormat: @"bk_%s", sel_getName(accessor)]);
}
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
