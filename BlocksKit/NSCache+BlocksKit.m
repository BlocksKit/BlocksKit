//
//  NSCache+BlocksKit.m
//  BlocksKit
//

#import "NSCache+BlocksKit.h"
#import "A2BlockDelegate+BlocksKit.h"

@interface NSCache (BKDynamicAccessors)

- (id <NSCacheDelegate>) bk_delegate;
- (void) bk_setDelegate: (id <NSCacheDelegate>) d;

@end

@interface A2DynamicNSCacheDelegate : A2DynamicDelegate

@end

@implementation A2DynamicNSCacheDelegate

- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
	id realDelegate = [cache bk_delegate];
	
	if (realDelegate && [realDelegate respondsToSelector:@selector(cache:willEvictObject:)])
		[realDelegate cache:cache willEvictObject:obj];

	void (^orig)(NSCache *, id) = [self blockImplementationForMethod:_cmd];
	if (orig)
		 orig(cache, obj);
}

@end

#pragma mark Category

@implementation NSCache (BlocksKit)

@dynamic willEvictBlock;

+ (void)load {
	@autoreleasepool {
		[self registerDynamicDelegate];
		[self linkCategoryBlockProperty:@"willEvictBlock" withDelegateMethod:@selector(cache:willEvictObject:)];
	}
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

@end
