//
//  NSObject+AssociatedObjects.m
//  BlocksKit
//

#import "NSObject+AssociatedObjects.h"
#import <objc/runtime.h>

@implementation NSObject (BKAssociatedObjects)

#pragma mark - Instance Methods

- (void)associateValue:(id)value withKey:(const void *)key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)atomicallyAssociateValue:(id)value withKey:(const void *)key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN);
}

- (void)associateCopyOfValue:(id)value withKey:(const void *)key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)atomicallyAssociateCopyOfValue:(id)value withKey:(const void *)key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY);
}

- (void)weaklyAssociateValue:(id)value withKey:(const void *)key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_ASSIGN);
}

- (id)associatedValueForKey:(const void *)key {
	return objc_getAssociatedObject(self, key);
}

- (void)removeAllAssociatedObjects {
	objc_removeAssociatedObjects(self);
}

#pragma mark - Class Methods

+ (void)associateValue:(id)value withKey:(const void *)key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)atomicallyAssociateValue:(id)value withKey:(const void *)key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN);
}

+ (void)associateCopyOfValue:(id)value withKey:(const void *)key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (void)atomicallyAssociateCopyOfValue:(id)value withKey:(const void *)key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY);
}

+ (void)weaklyAssociateValue:(id)value withKey:(const void *)key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_ASSIGN);
}

+ (id)associatedValueForKey:(const void *)key {
	return objc_getAssociatedObject(self, key);
}

+ (void)removeAllAssociatedObjects {
	objc_removeAssociatedObjects(self);
}

@end
