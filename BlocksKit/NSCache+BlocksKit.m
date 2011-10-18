//
//  NSCache+BlocksKit.m
//  BlocksKit
//

#import "NSCache+BlocksKit.h"
#import "NSObject+BlocksKit.h"
#import "BKDelegate.h"

static char *kDelegateKey = "NSCacheDelegate";
static char *kWillEvictObjectBlockKey = "NSCacheWillEvictObject";

#pragma mark Delegate

@interface BKCacheDelegate : BKDelegate <NSCacheDelegate>

@end

@implementation BKCacheDelegate

+ (Class)targetClass {
    return [NSCache class];
}

- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    if (cache.delegate && [cache.delegate respondsToSelector:@selector(cache:willEvictObject:)])
        [cache.delegate cache:cache willEvictObject:obj];
    
    BKSenderBlock block = cache.willEvictBlock;
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
    return [self willEvictBlock];
}

- (void)setWillEvictObjectHandler:(BKSenderBlock)handler {
    [self setWillEvictBlock:handler];
}

- (BKSenderBlock)willEvictBlock {
    BKSenderBlock block = [self associatedValueForKey:kWillEvictObjectBlockKey];
    return BK_AUTORELEASE([block copy]);
}

- (void)setWillEvictBlock:(BKSenderBlock)handler {
    [self bk_setDelegate:[BKCacheDelegate shared]];
    [self associateCopyOfValue:handler withKey:kWillEvictObjectBlockKey];
}

@end
