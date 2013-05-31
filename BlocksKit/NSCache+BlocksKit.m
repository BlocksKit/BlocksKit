//
//  NSCache+BlocksKit.m
//  BlocksKit
//

#import "NSCache+BlocksKit.h"

#pragma mark Custom delegate

@interface A2DynamicNSCacheDelegate : A2DynamicDelegate

@end

@implementation A2DynamicNSCacheDelegate

- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
	id realDelegate = self.realDelegate;
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
		[self linkDelegateMethods: @{ @"willEvictBlock": @"cache:willEvictObject:" }];
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
