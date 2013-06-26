//
//  NSObject+AssociatedObjects.m
//  BlocksKit
//

#import "NSObject+AssociatedObjects.h"
#import <objc/runtime.h>

@implementation NSObject (BKAssociatedObjects)

#pragma mark - Instance Methods

- (void)bk_associateValue:(id)value withKey:(const void *)key
{
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)bk_atomicallyAssociateValue:(id)value withKey:(const void *)key
{
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN);
}

- (void)bk_associateCopyOfValue:(id)value withKey:(const void *)key
{
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)bk_atomicallyAssociateCopyOfValue:(id)value withKey:(const void *)key
{
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY);
}

- (void)bk_weaklyAssociateValue:(id)value withKey:(const void *)key
{
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_ASSIGN);
}

- (id)bk_associatedValueForKey:(const void *)key
{
	return objc_getAssociatedObject(self, key);
}

- (void)bk_removeAllAssociatedObjects
{
	objc_removeAssociatedObjects(self);
}

#pragma mark - Class Methods

+ (void)bk_associateValue:(id)value withKey:(const void *)key
{
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)bk_atomicallyAssociateValue:(id)value withKey:(const void *)key
{
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN);
}

+ (void)bk_associateCopyOfValue:(id)value withKey:(const void *)key
{
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (void)bk_atomicallyAssociateCopyOfValue:(id)value withKey:(const void *)key
{
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY);
}

+ (void)bk_weaklyAssociateValue:(id)value withKey:(const void *)key
{
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_ASSIGN);
}

+ (id)bk_associatedValueForKey:(const void *)key
{
	return objc_getAssociatedObject(self, key);
}

+ (void)bk_removeAllAssociatedObjects
{
	objc_removeAssociatedObjects(self);
}

@end
