//
//  NSCache+BlocksKit.m
//  BlocksKit
//

#import "NSObject+A2BlockDelegate.h"
#import "A2DynamicDelegate.h"
#import "NSCache+BlocksKit.h"

#pragma mark Custom delegate

@interface A2DynamicNSCacheDelegate : A2DynamicDelegate

@end

@implementation A2DynamicNSCacheDelegate

- (void)cache:(NSCache *)cache willEvictObject:(id)obj
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(cache:willEvictObject:)])
		[realDelegate cache:cache willEvictObject:obj];

	void (^orig)(NSCache *, id) = [self blockImplementationForMethod:_cmd];
	if (orig) orig(cache, obj);
}

@end

#pragma mark Category

@implementation NSCache (BlocksKit)

@dynamic bk_willEvictBlock;

+ (void)load
{
	@autoreleasepool {
		[self bk_registerDynamicDelegate];
		[self bk_linkDelegateMethods:@{ @"bk_willEvictBlock": @"cache:willEvictObject:" }];
	}
}

#pragma mark Methods

- (id)bk_objectForKey:(id)key withGetter:(id (^)(void))block
{
	id object = [self objectForKey:key];
	if (object) return object;
	
	if (block) {
		object = block();
		[self setObject:object forKey:key];
	}
	
	return object;
}

@end
