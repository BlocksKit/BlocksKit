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
#import <dlfcn.h>
#import "blockimp.h"
#import "NSArray+BlocksKit.h"

extern void *A2BlockDelegateProtocolsKey;
extern void *A2BlockDelegateMapKey;

static char BKAccessorsMapKey;

extern SEL a2_getterForProperty(Class cls, NSString *propertyName);
extern SEL a2_setterForProperty(Class cls, NSString *propertyName);

#pragma mark -

@interface NSObject ()

+ (Protocol *) a2_dataSourceProtocol;
+ (Protocol *) a2_delegateProtocol;

@end

@interface NSObject (A2BlockDelegateBlocksKitPrivate)

+ (NSMutableDictionary *) bk_accessorsMap;

- (void) a2_checkRegisteredProtocol:(Protocol *)protocol;

@end

#pragma mark -

@implementation A2DynamicDelegate (A2BlockDelegate)

- (id) forwardingTargetForSelector: (SEL) aSelector
{
	if (![self blockImplementationForMethod: aSelector] && [self.realDelegate respondsToSelector: aSelector])
		return self.realDelegate;
	
	return [super forwardingTargetForSelector: aSelector];
}

- (NSMutableDictionary *)bk_realDelegates {
	static char BKRealDelegatesKey;
	NSMutableDictionary *dict = [self associatedValueForKey:&BKRealDelegatesKey];
	if (!dict) {
		dict = [NSMutableDictionary dictionary];
		[self associateValue:dict withKey:&BKRealDelegatesKey];
	}
	return dict;
}

- (id) realDelegate
{
	return [self realDelegateNamed: @"delegate"];
}

- (id) realDataSource
{
	return [self realDelegateNamed: @"dataSource"];
}

- (id)realDelegateNamed: (NSString *) delegateName
{
	id object = [[self bk_realDelegates] objectForKey: delegateName];
	if ([object isKindOfClass:[NSValue class]])
		object = [object nonretainedObjectValue];
	return object;
}

@end

#pragma mark -

@implementation NSObject (A2BlockDelegateBlocksKitPrivate)

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

- (void) a2_checkRegisteredProtocol:(Protocol *)protocol {
	__block SEL getter = NULL, setter = NULL;
	[[[[self class] bk_accessorsMap] allKeysForObject: NSStringFromProtocol(protocol)] each:^(NSString *selectorName) {
		if ([selectorName hasSuffix: @":"])
			setter = NSSelectorFromString(selectorName);
		else
			getter = NSSelectorFromString(selectorName);
	}];
	
	if (!getter || !setter)
		return;
	
	SEL a2_setter = NSSelectorFromString([@"a2_" stringByAppendingString: NSStringFromSelector(setter) ?: @""]);
	SEL a2_getter = NSSelectorFromString([@"a2_" stringByAppendingString: NSStringFromSelector(getter) ?: @""]);
	
	A2DynamicDelegate *dynamicDelegate = [self dynamicDelegateForProtocol: protocol];
	if ([self respondsToSelector:a2_setter]) {
		id originalDelegate = [self performSelector:a2_getter];
		if (![originalDelegate isKindOfClass:[A2DynamicDelegate class]])
			[self performSelector:a2_setter withObject:dynamicDelegate];
	}
}

#pragma mark Register Dynamic Delegate

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
	[accessorsMap setObject: (id) kCFBooleanTrue forKey: key];
	
	SEL getter = a2_getterForProperty(self, delegateName);
	SEL a2_getter = NSSelectorFromString([@"a2_" stringByAppendingString: NSStringFromSelector(getter)]);
	IMP getterImplementation = pl_imp_implementationWithBlock(^id(NSObject *obj) {
		return [[obj dynamicDelegateForProtocol: protocol] realDelegate];
	});
	const char *getterTypes = "@@:";
	
	if (!class_addMethod(self, getter, getterImplementation, getterTypes)) {
		class_addMethod(self, a2_getter, getterImplementation, getterTypes);
		Method method = class_getInstanceMethod(self, getter);
		Method a2_method = class_getInstanceMethod(self, a2_getter);
		method_exchangeImplementations(method, a2_method);
	}

	SEL setter = a2_setterForProperty(self, delegateName);
	SEL a2_setter = NSSelectorFromString([@"a2_" stringByAppendingString: NSStringFromSelector(setter)]);
	IMP setterImplementation = pl_imp_implementationWithBlock(^(NSObject *obj, id delegate) {
		A2DynamicDelegate *dynamicDelegate = [obj dynamicDelegateForProtocol: protocol];
		
		if ([obj respondsToSelector:a2_setter]) {
			id originalDelegate = [obj performSelector:a2_getter];
			if (![originalDelegate isKindOfClass:[A2DynamicDelegate class]])
				[obj performSelector:a2_setter withObject:dynamicDelegate];
		}
		
		if ([delegate isEqual: obj]) {
			[[dynamicDelegate bk_realDelegates] setObject: [NSValue valueWithNonretainedObject: delegate] forKey: delegateName];
			return;
		}
		
		if ([delegate isEqual: dynamicDelegate]) delegate = nil;
		[[dynamicDelegate bk_realDelegates] setObject: delegate forKey: delegateName];
	});
	const char *setterTypes = "v@:@";
	
	if (!class_addMethod(self, setter, setterImplementation, setterTypes)) {
		class_addMethod(self, a2_setter, setterImplementation, setterTypes);
		Method method = class_getInstanceMethod(self, setter);
		Method a2_method = class_getInstanceMethod(self, a2_setter);
		method_exchangeImplementations(method, a2_method);
	}
	
	NSString *protocolName = NSStringFromProtocol(protocol);
	[accessorsMap setObject: protocolName forKey: NSStringFromSelector(setter)];
	[accessorsMap setObject: protocolName forKey: NSStringFromSelector(getter)];
}

@end

BK_MAKE_CATEGORY_LOADABLE(NSObject_A2BlockDelegateBlocksKit)