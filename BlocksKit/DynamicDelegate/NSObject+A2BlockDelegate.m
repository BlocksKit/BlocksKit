//
//  NSObject+A2BlockDelegate.m
//  BlocksKit
//

#import "NSObject+A2BlockDelegate.h"
@import ObjectiveC.message;
#import "A2DynamicDelegate.h"
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

static BOOL addMethodWithIMP(Class cls, SEL oldSel, SEL newSel, IMP newIMP, const char *types, BOOL aggressive) {
	if (!class_addMethod(cls, oldSel, newIMP, types)) {
		return NO;
	}

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
			return class_addMethod(cls, newSel, parentIMP, types);
		}

		class_replaceMethod(cls, newSel, newIMP, types);
		class_replaceMethod(cls, oldSel, parentIMP, types);
	}

	return YES;
}

static BOOL swizzleWithIMP(Class cls, SEL oldSel, SEL newSel, IMP newIMP, const char *types, BOOL aggressive) {
    Method origMethod = class_getInstanceMethod(cls, oldSel);

	if (addMethodWithIMP(cls, oldSel, newSel, newIMP, types, aggressive)) {
		return YES;
	}

	// common case, actual swap
	BOOL ret = class_addMethod(cls, newSel, newIMP, types);
	Method newMethod = class_getInstanceMethod(cls, newSel);
	method_exchangeImplementations(origMethod, newMethod);
	return ret;
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

static SEL getterForProperty(objc_property_t property, const char *name)
{
	if (property) {
		char *getterName = property_copyAttributeValue(property, "G");
		if (getterName) {
			SEL getter = sel_getUid(getterName);
			free(getterName);
			if (getter) return getter;
		}
	}

	const char *propertyName = property ? property_getName(property) : name;
	return sel_registerName(propertyName);
}

static SEL setterForProperty(objc_property_t property, const char *name)
{
	if (property) {
		char *setterName = property_copyAttributeValue(property, "S");
		if (setterName) {
			SEL setter = sel_getUid(setterName);
			free(setterName);
			if (setter) return setter;
		}
	}

	const char *propertyName = property ? property_getName(property) : name;
	return selectorWithPattern("set", propertyName, ":");
}

static inline SEL prefixedSelector(SEL original) {
	return selectorWithPattern("a2_", sel_getName(original), NULL);
}

#pragma mark -

typedef struct {
	SEL setter;
	SEL a2_setter;
	SEL getter;
} A2BlockDelegateInfo;

static NSUInteger A2BlockDelegateInfoSize(const void *__unused item) {
	return sizeof(A2BlockDelegateInfo);
}

static NSString *A2BlockDelegateInfoDescribe(const void *__unused item) {
	if (!item) { return nil; }
	const A2BlockDelegateInfo *info = item;
	return [NSString stringWithFormat:@"(setter: %s, getter: %s)", sel_getName(info->setter), sel_getName(info->getter)];
}

static inline A2DynamicDelegate *getDynamicDelegate(NSObject *delegatingObject, Protocol *protocol, const A2BlockDelegateInfo *info, BOOL ensuring) {
	A2DynamicDelegate *dynamicDelegate = [delegatingObject bk_dynamicDelegateForProtocol:a2_protocolForDelegatingObject(delegatingObject, protocol)];

	if (!info || !info->setter || !info->getter) {
		return dynamicDelegate;
	}

	if (!info->a2_setter && !info->setter) { return dynamicDelegate; }

	id (*getterDispatch)(id, SEL) = (id (*)(id, SEL)) objc_msgSend;
	id originalDelegate = getterDispatch(delegatingObject, info->getter);

	if (bk_object_isKindOfClass(originalDelegate, A2DynamicDelegate.class)) { return dynamicDelegate; }

	void (*setterDispatch)(id, SEL, id) = (void (*)(id, SEL, id)) objc_msgSend;
	setterDispatch(delegatingObject, info->a2_setter ?: info->setter, dynamicDelegate);

	return dynamicDelegate;
}

typedef A2DynamicDelegate *(^A2GetDynamicDelegateBlock)(NSObject *, BOOL);

@interface A2DynamicDelegate ()

@property (nonatomic, weak, readwrite) id realDelegate;

@end

#pragma mark -

@implementation NSObject (A2BlockDelegate)

#pragma mark Helpers

+ (NSMapTable *)bk_delegateInfoByProtocol:(BOOL)createIfNeeded
{
	NSMapTable *delegateInfo = objc_getAssociatedObject(self, _cmd);
	if (delegateInfo || !createIfNeeded) { return delegateInfo; }

	NSPointerFunctions *protocols = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsOpaqueMemory|NSPointerFunctionsObjectPointerPersonality];
	NSPointerFunctions *infoStruct = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsMallocMemory|NSPointerFunctionsStructPersonality|NSPointerFunctionsCopyIn];
	infoStruct.sizeFunction = A2BlockDelegateInfoSize;
	infoStruct.descriptionFunction = A2BlockDelegateInfoDescribe;

	delegateInfo = [[NSMapTable alloc] initWithKeyPointerFunctions:protocols valuePointerFunctions:infoStruct capacity:0];
	objc_setAssociatedObject(self, _cmd, delegateInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

	return delegateInfo;
}

+ (const A2BlockDelegateInfo *)bk_delegateInfoForProtocol:(Protocol *)protocol
{
	A2BlockDelegateInfo *infoAsPtr = NULL;
	Class cls = self;
	while ((infoAsPtr == NULL || infoAsPtr->getter == NULL) && cls != nil && cls != NSObject.class) {
		NSMapTable *map = [cls bk_delegateInfoByProtocol:NO];
		infoAsPtr = (__bridge void *)[map objectForKey:protocol];
		cls = [cls superclass];
	}
	NSCAssert(infoAsPtr != NULL, @"Class %@ not assigned dynamic delegate for protocol %@", NSStringFromClass(self), NSStringFromProtocol(protocol));
	return infoAsPtr;
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
		const char *name = propertyName.UTF8String;
		objc_property_t property = class_getProperty(self, name);
		NSCAssert(property, @"Property \"%@\" does not exist on class %s", propertyName, class_getName(self));

		char *dynamic = property_copyAttributeValue(property, "D");
		NSCAssert2(dynamic, @"Property \"%@\" on class %s must be backed with \"@dynamic\"", propertyName, class_getName(self));
		free(dynamic);

		char *copy = property_copyAttributeValue(property, "C");
		NSCAssert2(copy, @"Property \"%@\" on class %s must be defined with the \"copy\" attribute", propertyName, class_getName(self));
		free(copy);

		SEL selector = NSSelectorFromString(selectorName);
		SEL getter = getterForProperty(property, name);
		SEL setter = setterForProperty(property, name);

		if (class_respondsToSelector(self, setter) || class_respondsToSelector(self, getter)) { return; }

		const A2BlockDelegateInfo *info = [self bk_delegateInfoForProtocol:protocol];

		IMP getterImplementation = imp_implementationWithBlock(^(NSObject *delegatingObject) {
			A2DynamicDelegate *delegate = getDynamicDelegate(delegatingObject, protocol, info, NO);
			return [delegate blockImplementationForMethod:selector];
		});

		if (!class_addMethod(self, getter, getterImplementation, "@@:")) {
			NSCAssert(NO, @"Could not implement getter for \"%@\" property.", propertyName);
		}

		IMP setterImplementation = imp_implementationWithBlock(^(NSObject *delegatingObject, id block) {
			A2DynamicDelegate *delegate = getDynamicDelegate(delegatingObject, protocol, info, YES);
			[delegate implementMethod:selector withBlock:block];
		});

		if (!class_addMethod(self, setter, setterImplementation, "v@:@")) {
			NSCAssert(NO, @"Could not implement setter for \"%@\" property.", propertyName);
		}
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
	NSMapTable *propertyMap = [self bk_delegateInfoByProtocol:YES];
	A2BlockDelegateInfo *infoAsPtr = (__bridge void *)[propertyMap objectForKey:protocol];
	if (infoAsPtr != NULL) { return; }

	const char *name = delegateName.UTF8String;
	objc_property_t property = class_getProperty(self, name);
	SEL setter = setterForProperty(property, name);
	SEL a2_setter = prefixedSelector(setter);
	SEL getter = getterForProperty(property, name);

	A2BlockDelegateInfo info = {
		setter, a2_setter, getter
	};

	[propertyMap setObject:(__bridge id)&info forKey:protocol];
	infoAsPtr = (__bridge void *)[propertyMap objectForKey:protocol];

	IMP setterImplementation = imp_implementationWithBlock(^(NSObject *delegatingObject, id delegate) {
		A2DynamicDelegate *dynamicDelegate = getDynamicDelegate(delegatingObject, protocol, infoAsPtr, YES);
		if ([delegate isEqual:dynamicDelegate]) {
			delegate = nil;
		}
		dynamicDelegate.realDelegate = delegate;
	});

	if (!swizzleWithIMP(self, setter, a2_setter, setterImplementation, "v@:@", YES)) {
		bzero(infoAsPtr, sizeof(A2BlockDelegateInfo));
		return;
	}

	if (![self instancesRespondToSelector:getter]) {
		IMP getterImplementation = imp_implementationWithBlock(^(NSObject *delegatingObject) {
			return [delegatingObject bk_dynamicDelegateForProtocol:a2_protocolForDelegatingObject(delegatingObject, protocol)];
		});

		addMethodWithIMP(self, getter, NULL, getterImplementation, "@@:", NO);
	}
}

- (id)bk_ensuredDynamicDelegate
{
	Protocol *protocol = a2_delegateProtocol(self.class);
	return [self bk_ensuredDynamicDelegateForProtocol:protocol];
}

- (id)bk_ensuredDynamicDelegateForProtocol:(Protocol *)protocol
{
	const A2BlockDelegateInfo *info = [self.class bk_delegateInfoForProtocol:protocol];
	return getDynamicDelegate(self, protocol, info, YES);
}

@end
