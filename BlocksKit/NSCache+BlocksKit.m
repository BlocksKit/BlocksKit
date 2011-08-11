//
//  NSCache+BlocksKit.m
//  BlocksKit
//
//  Created by Evsukov Igor on 11.08.11.
//  Copyright 2011 Dizzy Technology. All rights reserved.
//

#import "NSCache+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"
#import <objc/runtime.h>

#pragma mark - constants
static char *kWillEvictObjectHandlerKey = "willEvictObjectHandler";
static char *kBKDelegateKey = "BKDelegate";

#pragma mark - Delegate proxy
@interface BKCacheDelegateProxy : NSObject<NSCacheDelegate>
+ (id)shared;
@end

@implementation BKCacheDelegateProxy

+ (id)shared {
    static BKCacheDelegateProxy *proxyDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        proxyDelegate = [[BKCacheDelegateProxy alloc] init];
    });
    
    return proxyDelegate;
}

- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    if (cache.delegate && [cache.delegate respondsToSelector:@selector(cache:willEvictObject:)]) {
        [cache.delegate cache:cache willEvictObject:obj];
    }
    
    if (cache.willEvictObjectHandler) {
        cache.willEvictObjectHandler(obj);
    }
}

@end


#pragma mark - category implementation
@implementation NSCache (BlocksKit)

#pragma mark - monkeypatching
+ (void)load {
    Class myClass = [self class];
    
    Method originalDelegateGetterMethod = class_getInstanceMethod(myClass, @selector(delegate));
    Method categoryDelegateGetterMethod = class_getInstanceMethod(myClass, @selector(bk_delegate));
    method_exchangeImplementations(originalDelegateGetterMethod, categoryDelegateGetterMethod);

    Method originalDelegateSetterMethod = class_getInstanceMethod(myClass, @selector(setDelegate:));
    Method categoryDelegateSetterMethod = class_getInstanceMethod(myClass, @selector(bk_setDelegate:));
    method_exchangeImplementations(originalDelegateSetterMethod, categoryDelegateSetterMethod);
}

#pragma mark - properties
@dynamic willEvictObjectHandler;


#pragma mark - methods
- (id)objectForKey:(id)key withGetter:(BKReturnBlock)getterBlock {
    id object = [self objectForKey:key];
    if (object) return object;
    
    if (getterBlock) {
        object = getterBlock();
        [self setObject:object forKey:key];
    }
    
    return object;
}


#pragma mark - getters & setters
- (BKSenderBlock)willEvictObjectHandler {
    return [self associatedValueForKey:kWillEvictObjectHandlerKey];
}
- (void)setWillEvictObjectHandler:(BKSenderBlock)willEvictObjectHandler {
    [self associateCopyOfValue:willEvictObjectHandler withKey:kWillEvictObjectHandlerKey];
}

- (id)bk_delegate {
    return [self associatedValueForKey:kBKDelegateKey];
}
- (void)bk_setDelegate:(id)delegate {
    [self weaklyAssociateValue:delegate withKey:kBKDelegateKey];
    
    [self bk_setDelegate:[BKCacheDelegateProxy shared]];
}

@end
