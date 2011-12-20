//
//  NSObject+AssociatedObjects.m
//  BlocksKit
//

#import "NSObject+AssociatedObjects.h"
#import <objc/runtime.h>

@implementation NSObject (AssociatedObjects)

#pragma mark - Instance Methods

- (void)associateValue:(id)value withKey:(const char *)key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)associateCopyOfValue:(id)value withKey:(const char *)key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)weaklyAssociateValue:(id)value withKey:(const char *)key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_ASSIGN);
}

- (id)associatedValueForKey:(const char *)key {
	return objc_getAssociatedObject(self, key);
}

- (void)removeAllAssociatedObjects {
	objc_removeAssociatedObjects(self);
}

#pragma mark - Class Methods

+ (void)associateValue:(id)value withKey:(const char *)key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)associateCopyOfValue:(id)value withKey:(const char *)key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (void)weaklyAssociateValue:(id)value withKey:(const char *)key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_ASSIGN);
}

+ (id)associatedValueForKey:(const char *)key {
	return objc_getAssociatedObject(self, key);
}

+ (void)removeAllAssociatedObjects {
	objc_removeAssociatedObjects(self);
}

@end
