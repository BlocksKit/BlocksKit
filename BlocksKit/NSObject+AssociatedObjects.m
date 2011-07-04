//
//  NSObject+AssociatedObjects.m
//  BlocksKit
//

#import "NSObject+AssociatedObjects.h"
#import <objc/runtime.h>

@implementation NSObject (AssociatedObjects)

- (void)associateValue:(id)value withKey:(void *)key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)associateCopyOfValue:(id)value withKey:(void *)key {
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY);
}

- (void)weaklyAssociateValue:(id)value withKey:(void *)key {
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_ASSIGN);
}

- (id)associatedValueForKey:(void *)key {
	return objc_getAssociatedObject(self, key);
}

@end
