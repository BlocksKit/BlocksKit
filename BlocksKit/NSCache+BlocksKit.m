//
//  NSCache+BlocksKit.m
//  BlocksKit
//

#import "NSCache+BlocksKit.h"
#import "NSObject+BlocksKit.h"

static char *kDelegateKey = "NSCacheDelegate";
static char *kWillEvictObjectHandlerKey = "NSCacheWillEvictObject";

#pragma mark Delegate

@interface BKCacheDelegate : NSObject <NSCacheDelegate>

+ (id)shared;

@end

@implementation BKCacheDelegate

+ (id)shared {
    static id __strong proxyDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        proxyDelegate = [BKCacheDelegate new];
    });
    return proxyDelegate;
}

- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    if (cache.delegate && [cache.delegate respondsToSelector:@selector(cache:willEvictObject:)])
        [cache.delegate cache:cache willEvictObject:obj];
    
    BKSenderBlock block = cache.willEvictObjectHandler;
    if (block)
        block(obj);
}

@end

#pragma mark Category

@implementation NSCache (BlocksKit)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSelector:@selector(delegate) withSelector:@selector(bk_delegate)];
        [self swizzleSelector:@selector(setDelegate:) withSelector:@selector(bk_setDelegate:)];
    });
}

#pragma mark Methods

- (id)objectForKey:(id)key withGetter:(BKReturnBlock)block {
    id object = [self objectForKey:key];
    if (object)
        return object;
    
    if (block) {
        object = block();
        [self setObject:object forKey:key];
    }
    
    return object;
}

#pragma mark Properties

- (id)bk_delegate {
    return [self associatedValueForKey:kDelegateKey];
}

- (void)bk_setDelegate:(id)delegate {
    [self weaklyAssociateValue:delegate withKey:kDelegateKey];
    [self bk_setDelegate:[BKCacheDelegate shared]];
}

- (BKSenderBlock)willEvictObjectHandler {
    return [self associatedValueForKey:kWillEvictObjectHandlerKey];
}

- (void)setWillEvictObjectHandler:(BKSenderBlock)handler {
    // in case of using only blocks we still need to point our delegate
    // to proxy class
    [self bk_setDelegate:[BKCacheDelegate shared]];
    [self associateCopyOfValue:handler withKey:kWillEvictObjectHandlerKey];
}

@end
