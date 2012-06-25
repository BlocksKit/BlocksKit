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
#import "NSArray+BlocksKit.h"

// Function Declarations
extern SEL a2_getterForProperty(Class cls, NSString *propertyName);
extern SEL a2_setterForProperty(Class cls, NSString *propertyName);
extern NSString *a2_nameForPropertyAccessor(Class cls, SEL selector);
extern Protocol *a2_dataSourceProtocol(Class cls);
extern Protocol *a2_delegateProtocol(Class cls);

static inline SEL a2_selector(SEL selector) {
    return NSSelectorFromString([@"a2_" stringByAppendingString: NSStringFromSelector(selector)]);
}

// Delegate replacement selectors
static void bk_blockDelegateSetter(id self, SEL _cmd, id delegate);
static id bk_blockDelegateGetter(id self, SEL _cmd);

static void *BKRealDelegateKey;

#pragma mark -

@interface NSObject (A2BlockDelegateBlocksKitPrivate)

+ (NSMutableDictionary *) bk_propertyMap;

@end

#pragma mark -

@implementation A2DynamicDelegate (A2BlockDelegate)

+ (void)load {
	@autoreleasepool {
		Method oldMethod = class_getInstanceMethod(self, @selector(respondsToSelector:));
		Method newMethod = class_getInstanceMethod(self, @selector(bk_respondsToSelector:));
		method_exchangeImplementations(oldMethod, newMethod);
	}
}

- (BOOL)bk_respondsToSelector:(SEL)aSelector
{
	return [self bk_respondsToSelector: aSelector] || [self.realDelegate respondsToSelector: aSelector];
}

- (id) forwardingTargetForSelector: (SEL) aSelector
{
	return self.realDelegate;
}

- (id) realDelegate
{
	id obj = objc_getAssociatedObject(self, &BKRealDelegateKey);
	if ([obj isKindOfClass: [NSValue class]])
		obj = [obj nonretainedObjectValue];
    return obj;
}

@end

#pragma mark -

@implementation NSObject (A2BlockDelegateBlocksKitPrivate)

+ (NSMutableDictionary *) bk_propertyMap
{
	NSMutableDictionary *propertyMap = objc_getAssociatedObject(self, _cmd);
	
	if (!propertyMap)
	{
		propertyMap = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, _cmd, propertyMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	return propertyMap;
}

- (void) a2_checkRegisteredProtocol:(Protocol *)protocol {
	NSString *propertyName = nil;
	Class cls = [self class];
	while (!propertyName.length && cls != [NSObject class]) {
		propertyName = [[[cls bk_propertyMap] allKeysForObject: NSStringFromProtocol(protocol)] lastObject];
		cls = [cls superclass];
	}
    
	SEL a2_setter = a2_selector(a2_setterForProperty(self.class, propertyName));
	SEL a2_getter = a2_selector(a2_getterForProperty(self.class, propertyName));
	
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
	NSMutableDictionary *propertyMap = [self bk_propertyMap];
	if ([propertyMap objectForKey: delegateName])
        return;
	[propertyMap setObject: NSStringFromProtocol(protocol) forKey: delegateName];
	
	SEL getter = a2_getterForProperty(self, delegateName);
	SEL a2_getter = a2_selector(getter);
    IMP getterImplementation = (IMP)bk_blockDelegateGetter;
	const char *getterTypes = "@@:";
	
	if (!class_addMethod(self, getter, getterImplementation, getterTypes)) {
		class_addMethod(self, a2_getter, getterImplementation, getterTypes);
		Method method = class_getInstanceMethod(self, getter);
		Method a2_method = class_getInstanceMethod(self, a2_getter);
		method_exchangeImplementations(method, a2_method);
	}

	SEL setter = a2_setterForProperty(self, delegateName);
	SEL a2_setter = a2_selector(setter);
    IMP setterImplementation = (IMP)bk_blockDelegateSetter;
	const char *setterTypes = "v@:@";
	
	if (!class_addMethod(self, setter, setterImplementation, setterTypes)) {
		class_addMethod(self, a2_setter, setterImplementation, setterTypes);
		Method method = class_getInstanceMethod(self, setter);
		Method a2_method = class_getInstanceMethod(self, a2_setter);
		method_exchangeImplementations(method, a2_method);
	}
}

@end

#pragma mark - Functions

static void bk_blockDelegateSetter(NSObject *self, SEL _cmd, id delegate)
{
    NSString *delegateName = a2_nameForPropertyAccessor(self.class, _cmd);
	NSString *protocolName = nil;
	Class cls = [self class];
	while (!protocolName.length && cls != [NSObject class]) {
		protocolName = [[cls bk_propertyMap] objectForKey: delegateName];
		cls = [cls superclass];
	}
	
	A2DynamicDelegate *dynamicDelegate = [self dynamicDelegateForProtocol: NSProtocolFromString(protocolName)];
    
	SEL a2_setter = NSSelectorFromString([@"a2_" stringByAppendingString: NSStringFromSelector(_cmd)]);
    SEL getter = a2_getterForProperty(self.class, delegateName);
	SEL a2_getter = NSSelectorFromString([@"a2_" stringByAppendingString: NSStringFromSelector(getter)]);
    
    if ([self respondsToSelector:a2_setter]) {
		id originalDelegate = [self performSelector:a2_getter];
		if (![originalDelegate isKindOfClass:[A2DynamicDelegate class]])
			[self performSelector:a2_setter withObject:dynamicDelegate];
	}
	
	if ([delegate isEqual: dynamicDelegate])
        delegate = nil;
    else if ([delegate isEqual:self] || [self isEqual:dynamicDelegate.delegatingObject])
        delegate = [NSValue valueWithNonretainedObject: delegate];
	
	objc_setAssociatedObject(dynamicDelegate, &BKRealDelegateKey, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static id bk_blockDelegateGetter(NSObject *self, SEL _cmd)
{
    NSString *delegateName = a2_nameForPropertyAccessor(self.class, _cmd);
	NSString *protocolName = nil;
	Class cls = [self class];
	while (!protocolName.length && cls != [NSObject class]) {
		protocolName = [[cls bk_propertyMap] objectForKey: delegateName];
		cls = [cls superclass];
	}
	A2DynamicDelegate *dynamicDelegate = [self dynamicDelegateForProtocol: NSProtocolFromString(protocolName)];
    
	return dynamicDelegate.realDelegate;
}

BK_MAKE_CATEGORY_LOADABLE(NSObject_A2BlockDelegateBlocksKit)