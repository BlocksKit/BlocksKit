//
//  A2BlockDelegate.m
//  A2DynamicDelegate
//
//  Created by Alexsander Akers on 11/30/11.
//  Copyright (c) 2011 Pandamonia LLC. All rights reserved.
//

#import "A2BlockDelegate.h"
#import "A2DynamicDelegate.h"
#import "NSObject+AssociatedObjects.h"
#import "NSDictionary+BlocksKit.h"
#import <objc/message.h>

#pragma mark - Declarations and macros

extern Protocol *a2_dataSourceProtocol(Class cls);
extern Protocol *a2_delegateProtocol(Class cls);

static BOOL bk_object_isKindOfClass(id obj, Class testClass)
{
	BOOL isKindOfClass = NO;
	Class cls = object_getClass(obj);
	while (cls && !isKindOfClass)
	{
		isKindOfClass = (cls == testClass);
		cls = class_getSuperclass(cls);
	}
	
	return isKindOfClass;
}

@interface A2DynamicDelegate ()

@property (nonatomic, weak, readwrite) id realDelegate;

@end

#pragma mark - Functions

static SEL getterForProperty(Class cls, NSString *propertyName)
{
	SEL getter = NULL;

	objc_property_t property = class_getProperty(cls, propertyName.UTF8String);
	if (property)
	{
		char *getterName = property_copyAttributeValue(property, "G");
		if (getterName) getter = sel_getUid(getterName);
		free(getterName);
	}

	if (!getter)
	{
		getter = NSSelectorFromString(propertyName);
	}

	return getter;
}

static SEL setterForProperty(Class cls, NSString *propertyName)
{
	SEL setter = NULL;

	objc_property_t property = class_getProperty(cls, propertyName.UTF8String);
	if (property)
	{
		char *setterName = property_copyAttributeValue(property, "S");
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

static inline SEL prefixedSelector(SEL selector) {
	return NSSelectorFromString([@"a2_" stringByAppendingString: NSStringFromSelector(selector)]);
}

#pragma mark -

@implementation NSObject (A2BlockDelegate)

#pragma mark Helper

+ (NSMutableDictionary *) bk_delegateNameMap
{
	NSMutableDictionary *propertyMap = [self associatedValueForKey: _cmd];

	if (!propertyMap)
	{
		propertyMap = [NSMutableDictionary dictionary];
		[self associateValue: propertyMap withKey: _cmd];
	}

	return propertyMap;
}

#pragma mark Linking block properties

+ (void) linkDataSourceMethods: (NSDictionary *) dictionary
{
	[self linkProtocol: a2_dataSourceProtocol(self) methods: dictionary];
}

+ (void) linkDelegateMethods: (NSDictionary *) dictionary
{
	[self linkProtocol: a2_delegateProtocol(self) methods: dictionary];
}

+ (void) linkProtocol: (Protocol *) protocol methods: (NSDictionary *) dictionary
{
	[dictionary each:^(NSString *propertyName, NSString *selectorName) {
		objc_property_t property = class_getProperty(self, propertyName.UTF8String);
		NSCAssert2(property, @"Property \"%@\" does not exist on class %s", propertyName, class_getName(self));

		char *dynamic = property_copyAttributeValue(property, "D");
		NSCAssert2(dynamic, @"Property \"%@\" on class %s must be backed with \"@dynamic\"", propertyName, class_getName(self));
		free(dynamic);

		char *copy = property_copyAttributeValue(property, "C");
		NSCAssert2(copy, @"Property \"%@\" on class %s must be defined with the \"copy\" attribute", propertyName, class_getName(self));
		free(copy);

		SEL selector = NSSelectorFromString(selectorName);
		SEL getter = getterForProperty(self, propertyName);
		SEL setter = setterForProperty(self, propertyName);

		if (class_respondsToSelector(self, setter) || class_respondsToSelector(self, getter))
			return;

		NSString *delegateProperty = nil;
		Class cls = self;
		while (!delegateProperty.length && cls != [NSObject class]) {
			delegateProperty = [cls bk_delegateNameMap][NSStringFromProtocol(protocol)];
			cls = [cls superclass];
		}

		IMP getterImplementation = imp_implementationWithBlock(^(NSObject *delegatingObject){
			return [[delegatingObject dynamicDelegateForProtocol: protocol] blockImplementationForMethod: selector];
		});
		IMP setterImplementation = imp_implementationWithBlock(^(NSObject *delegatingObject, id block){
			A2DynamicDelegate *dynamicDelegate = [delegatingObject dynamicDelegateForProtocol: protocol];

			if (delegateProperty.length) {
				SEL a2_setter = prefixedSelector(setterForProperty(delegatingObject.class, delegateProperty));
				SEL a2_getter = prefixedSelector(getterForProperty(delegatingObject.class, delegateProperty));

				if ([delegatingObject respondsToSelector:a2_setter]) {
					id originalDelegate = objc_msgSend(delegatingObject, a2_getter);
					if (!bk_object_isKindOfClass(originalDelegate, [A2DynamicDelegate class]))
						objc_msgSend(delegatingObject, a2_setter, dynamicDelegate);
				}
			}
			
			[dynamicDelegate implementMethod: selector withBlock: block];
		});


		const char *getterTypes = "@@:";
		BOOL success = class_addMethod(self, getter, getterImplementation, getterTypes);
		NSCAssert1(success, @"Could not implement getter for \"%@\" property.", propertyName);

		const char *setterTypes = "v@:@";
		success = class_addMethod(self, setter, setterImplementation, setterTypes);
		NSCAssert1(success, @"Could not implement setter for \"%@\" property.", propertyName);
	}];
}

#pragma mark Dynamic Delegate Replacement

+ (void) registerDynamicDataSource
{
	[self registerDynamicDelegateNamed: @"dataSource" forProtocol: a2_dataSourceProtocol(self)];
}
+ (void) registerDynamicDelegate
{
	[self registerDynamicDelegateNamed: @"delegate" forProtocol: a2_delegateProtocol(self)];
}

+ (void) registerDynamicDataSourceNamed: (NSString *) dataSourceName
{
	[self registerDynamicDelegateNamed: dataSourceName forProtocol: a2_dataSourceProtocol(self)];
}
+ (void) registerDynamicDelegateNamed: (NSString *) delegateName
{
	[self registerDynamicDelegateNamed: delegateName forProtocol: a2_delegateProtocol(self)];
}

+ (void) registerDynamicDelegateNamed: (NSString *) delegateName forProtocol: (Protocol *) protocol
{
	NSString *protocolName = NSStringFromProtocol(protocol);
	NSMutableDictionary *propertyMap = [self bk_delegateNameMap];
	if (propertyMap[protocolName])
		return;

	SEL getter = getterForProperty(self, delegateName);
	SEL a2_getter = prefixedSelector(getter);
	SEL setter = setterForProperty(self, delegateName);
	SEL a2_setter = prefixedSelector(setter);

	IMP getterImplementation = imp_implementationWithBlock(^(NSObject *delegatingObject){
		return [[delegatingObject dynamicDelegateForProtocol: protocol] realDelegate];
	});

	IMP setterImplementation = imp_implementationWithBlock(^(NSObject *delegatingObject, id delegate){
		A2DynamicDelegate *dynamicDelegate = [delegatingObject dynamicDelegateForProtocol: protocol];

		if ([delegatingObject respondsToSelector:a2_setter]) {
			id originalDelegate = objc_msgSend(delegatingObject, a2_getter, delegate);
			if (!bk_object_isKindOfClass(originalDelegate, [A2DynamicDelegate class]))
				objc_msgSend(delegatingObject, a2_setter, dynamicDelegate);
		}

		if ([delegate isEqual: dynamicDelegate])
			delegate = nil;

		dynamicDelegate.realDelegate = delegate;
	});
	
	const char *getterTypes = "@@:";
	const char *setterTypes = "v@:@";

	if (!class_addMethod(self, getter, getterImplementation, getterTypes)) {
		class_addMethod(self, a2_getter, getterImplementation, getterTypes);
		Method method = class_getInstanceMethod(self, getter);
		Method a2_method = class_getInstanceMethod(self, a2_getter);
		method_exchangeImplementations(method, a2_method);
	}

	if (!class_addMethod(self, setter, setterImplementation, setterTypes)) {
		class_addMethod(self, a2_setter, setterImplementation, setterTypes);
		Method method = class_getInstanceMethod(self, setter);
		Method a2_method = class_getInstanceMethod(self, a2_setter);
		method_exchangeImplementations(method, a2_method);
	}
	
	propertyMap[protocolName] = delegateName;
}

@end
