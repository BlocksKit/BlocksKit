//
//  NSObject+A2BlockDelegate.m
//  BlocksKit
//

#import <objc/message.h>
#import "NSObject+A2BlockDelegate.h"
#import "NSObject+A2DynamicDelegate.h"

#pragma mark - Declarations and macros

extern Protocol *a2_dataSourceProtocol(Class cls);
extern Protocol *a2_delegateProtocol(Class cls);

#pragma mark - Functions

static BOOL bk_object_isKindOfClass(id obj, Class testClass)
{
	BOOL isKindOfClass = NO;
	Class cls = object_getClass(obj);
	while (cls && !isKindOfClass) {
		isKindOfClass = (cls == testClass);
		cls = class_getSuperclass(cls);
	}

	return isKindOfClass;
}

static Protocol *a2_protocolForDelegatingObject(id obj, Protocol *protocol)
{
	NSString *protocolName = NSStringFromProtocol(protocol);
	if ([protocolName hasSuffix:@"Delegate"]) {
		Protocol *p = a2_delegateProtocol([obj class]);
		if (p) return p;
	} else if ([protocolName hasSuffix:@"DataSource"]) {
		Protocol *p = a2_dataSourceProtocol([obj class]);
		if (p) return p;
	}

	return protocol;
}

static inline BOOL isValidIMP(IMP impl) {
#if defined(__arm64__)
    if (impl == NULL || impl == _objc_msgForward) return NO;
#else
    if (impl == NULL || impl == _objc_msgForward || impl == (IMP)_objc_msgForward_stret) return NO;
#endif
    return YES;
}

static void swizzleWithIMP(Class cls, SEL oldSel, SEL newSel, IMP newIMP, const char *types, BOOL aggressive) {
    Method origMethod = class_getInstanceMethod(cls, oldSel);

    if (class_addMethod(cls, oldSel, newIMP, types)) {
        // We just ended up implementing a method that doesn't exist
        // (-[NSURLConnection setDelegate:]) or overrode a superclass
        // version (-[UIImagePickerController setDelegate:]).
        IMP parentIMP = NULL;
        Class superclass = class_getSuperclass(cls);
        while (superclass && !isValidIMP(parentIMP)) {
            parentIMP = class_getMethodImplementation(superclass, oldSel);
            if (isValidIMP(parentIMP)) {
                break;
            } else {
                parentIMP = NULL;
            }

            superclass = class_getSuperclass(superclass);
        }

        if (parentIMP) {
            if (aggressive) {
                class_addMethod(cls, newSel, parentIMP, types);
            } else {
                class_replaceMethod(cls, newSel, newIMP, types);
                class_replaceMethod(cls, oldSel, parentIMP, types);
            }
        }
    } else {
        // common case, actual swap
        class_addMethod(cls, newSel, newIMP, types);
        Method newMethod = class_getInstanceMethod(cls, newSel);
        method_exchangeImplementations(origMethod, newMethod);
    }
}

static SEL selectorWithPattern(const char *prefix, const char *key, const char *suffix) {
	size_t prefixLength = prefix ? strlen(prefix) : 0;
	size_t suffixLength = suffix ? strlen(suffix) : 0;

	char initial = key[0];
	if (prefixLength) initial = (char)toupper(initial);
	size_t initialLength = 1;

	const char *rest = key + initialLength;
	size_t restLength = strlen(rest);

	char selector[prefixLength + initialLength + restLength + suffixLength + 1];
	memcpy(selector, prefix, prefixLength);
	selector[prefixLength] = initial;
	memcpy(selector + prefixLength + initialLength, rest, restLength);
	memcpy(selector + prefixLength + initialLength + restLength, suffix, suffixLength);
	selector[prefixLength + initialLength + restLength + suffixLength] = '\0';

	return sel_registerName(selector);
}

static SEL getterForProperty(Class cls, NSString *propertyName)
{
	objc_property_t property = class_getProperty(cls, propertyName.UTF8String);
	if (property) {
		char *getterName = property_copyAttributeValue(property, "G");
		if (getterName) {
			SEL getter = sel_getUid(getterName);
			free(getterName);
			if (getter) return getter;
		}
	}

	return sel_registerName(propertyName.UTF8String);
}

static SEL setterForProperty(Class cls, NSString *propertyName)
{
	objc_property_t property = class_getProperty(cls, propertyName.UTF8String);
	if (property) {
		char *setterName = property_copyAttributeValue(property, "S");
		if (setterName) {
			SEL setter = sel_getUid(setterName);
			free(setterName);
			if (setter) return setter;
		}
	}

	return selectorWithPattern("set", propertyName.UTF8String, ":");
}

static inline SEL prefixedSelector(SEL original) {
	return selectorWithPattern("a2_", sel_getName(original), NULL);
}

#pragma mark -

@interface A2DynamicDelegate ()

@property (nonatomic, weak, readwrite) id realDelegate;

@end

#pragma mark -

@implementation NSObject (A2BlockDelegate)

#pragma mark Helper

+ (NSMutableDictionary *)bk_delegateNameMap
{
	NSMutableDictionary *propertyMap = objc_getAssociatedObject(self, _cmd);
	if (!propertyMap) {
		propertyMap = [NSMutableDictionary dictionary];
		objc_setAssociatedObject(self, _cmd, propertyMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}

	return propertyMap;
}

#pragma mark Linking block properties

+ (void)bk_linkDataSourceMethods:(NSDictionary *)dictionary
{
	[self bk_linkProtocol:a2_dataSourceProtocol(self) methods:dictionary];
}

+ (void)bk_linkDelegateMethods:(NSDictionary *)dictionary
{
	[self bk_linkProtocol:a2_delegateProtocol(self) methods:dictionary];
}

+ (void)bk_linkProtocol:(Protocol *)protocol methods:(NSDictionary *)dictionary
{
	[dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, NSString *selectorName, BOOL *stop) {
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

		IMP getterImplementation = imp_implementationWithBlock(^(NSObject *delegatingObject) {
			return [[delegatingObject bk_dynamicDelegateForProtocol:a2_protocolForDelegatingObject(delegatingObject, protocol)] blockImplementationForMethod:selector];
		});
		IMP setterImplementation = imp_implementationWithBlock(^(NSObject *delegatingObject, id block) {
			A2DynamicDelegate *dynamicDelegate = [delegatingObject bk_dynamicDelegateForProtocol:a2_protocolForDelegatingObject(delegatingObject, protocol)];

			if (delegateProperty.length) {
				SEL a2_setter = prefixedSelector(setterForProperty(delegatingObject.class, delegateProperty));
				SEL a2_getter = prefixedSelector(getterForProperty(delegatingObject.class, delegateProperty));

				if ([delegatingObject respondsToSelector:a2_setter]) {
					id (*getterDispatch)(id, SEL) = (id (*)(id, SEL)) objc_msgSend;
					id originalDelegate = getterDispatch(delegatingObject, a2_getter);
					if (!bk_object_isKindOfClass(originalDelegate, [A2DynamicDelegate class])) {
						void (*setterDispatch)(id, SEL, id) = (void (*)(id, SEL, id)) objc_msgSend;
						setterDispatch(delegatingObject, a2_setter, dynamicDelegate);
					}
				}
			}

			[dynamicDelegate implementMethod:selector withBlock:block];
		});

		const char *getterTypes = "@@:";
#if !defined(NS_BLOCK_ASSERTIONS)
		BOOL success =
#endif
		class_addMethod(self, getter, getterImplementation, getterTypes);
		NSCAssert(success, @"Could not implement getter for \"%@\" property.", propertyName);

		const char *setterTypes = "v@:@";
#if !defined(NS_BLOCK_ASSERTIONS)
		success =
#endif
		class_addMethod(self, setter, setterImplementation, setterTypes);
		NSCAssert(success, @"Could not implement setter for \"%@\" property.", propertyName);
	}];
}

#pragma mark Dynamic Delegate Replacement

+ (void)bk_registerDynamicDataSource
{
	[self bk_registerDynamicDelegateNamed:@"dataSource" forProtocol:a2_dataSourceProtocol(self)];
}
+ (void)bk_registerDynamicDelegate
{
	[self bk_registerDynamicDelegateNamed:@"delegate" forProtocol:a2_delegateProtocol(self)];
}

+ (void)bk_registerDynamicDataSourceNamed:(NSString *)dataSourceName
{
	[self bk_registerDynamicDelegateNamed:dataSourceName forProtocol:a2_dataSourceProtocol(self)];
}
+ (void)bk_registerDynamicDelegateNamed:(NSString *)delegateName
{
	[self bk_registerDynamicDelegateNamed:delegateName forProtocol:a2_delegateProtocol(self)];
}

+ (void)bk_registerDynamicDelegateNamed:(NSString *)delegateName forProtocol:(Protocol *)protocol
{
	NSString *protocolName = NSStringFromProtocol(protocol);
	NSMutableDictionary *propertyMap = [self bk_delegateNameMap];
	if (propertyMap[protocolName]) return;

	SEL getter = getterForProperty(self, delegateName);
	SEL a2_getter = prefixedSelector(getter);
	SEL setter = setterForProperty(self, delegateName);
	SEL a2_setter = prefixedSelector(setter);

	IMP getterImplementation = imp_implementationWithBlock(^(NSObject *delegatingObject) {
		return [[delegatingObject bk_dynamicDelegateForProtocol:a2_protocolForDelegatingObject(delegatingObject, protocol)] realDelegate];
	});

	IMP setterImplementation = imp_implementationWithBlock(^(NSObject *delegatingObject, id delegate) {
		A2DynamicDelegate *dynamicDelegate = [delegatingObject bk_dynamicDelegateForProtocol:a2_protocolForDelegatingObject(delegatingObject, protocol)];

		if ([delegatingObject respondsToSelector:a2_setter]) {
			id (*getterDispatch)(id, SEL) = (id (*)(id, SEL)) objc_msgSend;
			id originalDelegate = getterDispatch(delegatingObject, a2_getter);
			if (!bk_object_isKindOfClass(originalDelegate, [A2DynamicDelegate class])) {
				void (*setterDispatch)(id, SEL, id) = (void (*)(id, SEL, id)) objc_msgSend;
				setterDispatch(delegatingObject, a2_setter, dynamicDelegate);
			}
		}

		if ([delegate isEqual:dynamicDelegate]) {
			delegate = nil;
		}

		dynamicDelegate.realDelegate = delegate;
	});

    swizzleWithIMP(self, getter, a2_getter, getterImplementation, "@@:", NO);
    swizzleWithIMP(self, setter, a2_setter, setterImplementation, "v@:@", YES);

	propertyMap[protocolName] = delegateName;
}

@end
