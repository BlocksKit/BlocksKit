//
//  NSMutableDictionary+BlocksKit.m
//  BlocksKit
//

#import "NSMutableDictionary+BlocksKit.h"

@implementation NSMutableDictionary (BlocksKit)

- (void)bk_performSelect:(BOOL (^)(id key, id obj))block
{
	NSParameterAssert(block != nil);

	NSArray *keys = [[self keysOfEntriesWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id key, id obj, BOOL *stop) {
		return !block(key, obj);
	}] allObjects];

	[self removeObjectsForKeys:keys];
}

- (void)bk_performReject:(BOOL (^)(id key, id obj))block
{
	NSParameterAssert(block != nil);
	[self bk_performSelect:^BOOL(id key, id obj) {
		return !block(key, obj);
	}];
}

- (void)bk_performMap:(id (^)(id key, id obj))block
{
	NSParameterAssert(block != nil);

	NSMutableDictionary *new = [self mutableCopy];

	[self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		id value = block(key, obj) ?: [NSNull null];
		if ([value isEqual:obj]) return;
		new[key] = value;
	}];

	[self setDictionary:new];
}

@end
