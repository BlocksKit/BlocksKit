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

// Data Source Accessors
static id bk_dataSourceGetter(id self, SEL _cmd);
static void bk_dataSourceSetter(id self, SEL _cmd, id dataSource);

// Delegate Accessors
static id bk_delegateGetter(id self, SEL _cmd);
static void bk_delegateSetter(id self, SEL _cmd, id delegate);

// Helpers
static SEL bk_fakeAccessor(SEL accessor);
static SEL bk_getterForProperty(Class cls, NSString *propertyName);
static SEL bk_setterForProperty(Class cls, NSString *propertyName);

extern char *a2_property_copyAttributeValue(objc_property_t property, const char *name);

@implementation NSObject (A2BlockDelegateBlocksKit)

+ (NSMutableDictionary *) bk_propertyMap
{
	static char propertyMapKey;
	NSMutableDictionary *propertyMap = [self associatedValueForKey: &propertyMapKey];
	
	if (!propertyMap)
	{
		propertyMap = [NSMutableDictionary dictionary];
		[self associateValue: propertyMap withKey: &propertyMapKey];
	}
	
	return propertyMap;
}

+ (void) swizzleDataSourceProperty
{
	[self swizzleDataSourcePropertyNamed: @"dataSource"];
}
+ (void) swizzleDataSourcePropertyNamed: (NSString *) dataSourceName
{
	SEL getter = bk_getterForProperty(self, dataSourceName);
	SEL setter = bk_setterForProperty(self, dataSourceName);
	
	SEL bk_getter = bk_fakeAccessor(getter);
	SEL bk_setter = bk_fakeAccessor(setter);
	
	[[self bk_propertyMap] setObject: dataSourceName forKey: NSStringFromSelector(bk_getter)];
	[[self bk_propertyMap] setObject: dataSourceName forKey: NSStringFromSelector(bk_setter)];
	
	class_addMethod(self, bk_getter, (IMP) bk_dataSourceGetter, "@@:");
	class_addMethod(self, bk_setter, (IMP) bk_dataSourceSetter, "v@:@");
	
	[self swizzleSelector: getter withSelector: bk_getter];
	[self swizzleSelector: setter withSelector: bk_setter];
	
}

+ (void)swizzleDelegateProperty
{
	[self swizzleDelegatePropertyNamed: @"delegate"];
}
+ (void)swizzleDelegatePropertyNamed: (NSString *) delegateName
{
	SEL getter = bk_getterForProperty(self, delegateName);
	SEL setter = bk_setterForProperty(self, delegateName);
	
	SEL bk_getter = bk_fakeAccessor(getter);
	SEL bk_setter = bk_fakeAccessor(setter);
	
	[[self bk_propertyMap] setObject: delegateName forKey: NSStringFromSelector(bk_getter)];
	[[self bk_propertyMap] setObject: delegateName forKey: NSStringFromSelector(bk_setter)];
	
	class_addMethod(self, bk_getter, (IMP) bk_delegateGetter, "@@:");
	class_addMethod(self, bk_setter, (IMP) bk_delegateSetter, "v@:@");
	
	[self swizzleSelector: getter withSelector: bk_getter];
	[self swizzleSelector: setter withSelector: bk_setter];
}

@end

// Data Source Accessors
static id bk_dataSourceGetter(id self, SEL _cmd)
{
	NSString *propertyName = [[[self class] bk_propertyMap] objectForKey: NSStringFromSelector(_cmd)];
	return [[self dynamicDataSource] associatedValueForKey: propertyName.UTF8String];
}
static void bk_dataSourceSetter(id self, SEL _cmd, id dataSource)
{
	id dynamicDataSource = [self dynamicDataSource];
	((void (*)(id, SEL, id)) objc_msgSend)(self, bk_fakeAccessor(_cmd), dynamicDataSource);

	if ([dataSource isEqual: self] || [dataSource isEqual: dynamicDataSource])
		dataSource = nil;
	
	NSString *propertyName = [[[self class] bk_propertyMap] objectForKey: NSStringFromSelector(_cmd)];
	[dynamicDataSource weaklyAssociateValue: dataSource withKey: propertyName.UTF8String];
}

// Delegate Accessors
static id bk_delegateGetter(id self, SEL _cmd)
{
	NSString *propertyName = [[[self class] bk_propertyMap] objectForKey: NSStringFromSelector(_cmd)];
	return [[self dynamicDelegate] associatedValueForKey: propertyName.UTF8String];
}
static void bk_delegateSetter(id self, SEL _cmd, id delegate)
{
	id dynamicDelegate = [self dynamicDelegate];
	((void (*)(id, SEL, id)) objc_msgSend)(self, bk_fakeAccessor(_cmd), dynamicDelegate);
	
	if ([delegate isEqual: self] || [delegate isEqual: dynamicDelegate])
		delegate = nil;
	
	NSString *propertyName = [[[self class] bk_propertyMap] objectForKey: NSStringFromSelector(_cmd)];
	[dynamicDelegate weaklyAssociateValue: delegate withKey: propertyName.UTF8String];
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
