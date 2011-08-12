//
//  NSCache+BlocksKit.m
//  BlocksKit
//

#import "NSCache+BlocksKit.h"
#import "NSObject+BlocksKit.h"
#import "BKDelegateProxy.h"

static char *kWillEvictObjectHandlerKey = "willEvictObjectHandler";
static char *kBKDelegateKey = "BKDelegate";

#pragma mark Delegate

@interface BKCacheDelegate : BKDelegateProxy <NSCacheDelegate>
@end

@implementation BKCacheDelegate

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
    [NSCache swizzleSelector:@selector(delegate) withSelector:@selector(bk_delegate)];
    [NSCache swizzleSelector:@selector(setDelegate:) withSelector:@selector(bk_setDelegate:)];
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

- (BKSenderBlock)willEvictObjectHandler {
    return [self associatedValueForKey:kWillEvictObjectHandlerKey];
}

- (void)setWillEvictObjectHandler:(BKSenderBlock)handler {
    [self associateCopyOfValue:handler withKey:kWillEvictObjectHandlerKey];
}

- (id)bk_delegate {
    return [self associatedValueForKey:kBKDelegateKey];
}

- (void)bk_setDelegate:(id)delegate {
    [self weaklyAssociateValue:delegate withKey:kBKDelegateKey];
    
    [self bk_setDelegate:[BKCacheDelegate shared]];
}

@end
