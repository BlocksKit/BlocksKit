//
//  NSObject+BKAssociatedObjects.m
//  BlocksKit
//

#import "NSObject+BKAssociatedObjects.h"
@import ObjectiveC.runtime;

#pragma mark - Weak support

@interface _BKWeakAssociatedObject : NSObject

@property (nonatomic, weak) id value;

@end

@implementation _BKWeakAssociatedObject

@end

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

- (void)bk_weaklyAssociateValue:(__autoreleasing id)value withKey:(const void *)key
{
	_BKWeakAssociatedObject *assoc = objc_getAssociatedObject(self, key);
	if (!assoc) {
		assoc = [_BKWeakAssociatedObject new];
		[self bk_associateValue:assoc withKey:key];
	}
	assoc.value = value;
}

- (id)bk_associatedValueForKey:(const void *)key
{
	id value = objc_getAssociatedObject(self, key);
	if (value && [value isKindOfClass:[_BKWeakAssociatedObject class]]) {
		return [(_BKWeakAssociatedObject *)value value];
	}
	return value;
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

+ (void)bk_weaklyAssociateValue:(__autoreleasing id)value withKey:(const void *)key
{
	_BKWeakAssociatedObject *assoc = objc_getAssociatedObject(self, key);
	if (!assoc) {
		assoc = [_BKWeakAssociatedObject new];
		[self bk_associateValue:assoc withKey:key];
	}
	assoc.value = value;
}

+ (id)bk_associatedValueForKey:(const void *)key
{
	id value = objc_getAssociatedObject(self, key);
	if (value && [value isKindOfClass:[_BKWeakAssociatedObject class]]) {
		return [(_BKWeakAssociatedObject *)value value];
	}
	return value;
}

+ (void)bk_removeAllAssociatedObjects
{
	objc_removeAssociatedObjects(self);
}

@end
