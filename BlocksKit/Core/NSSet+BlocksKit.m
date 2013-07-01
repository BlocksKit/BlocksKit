//
//  NSSet+BlocksKit.m
//  BlocksKit
//

#import "NSSet+BlocksKit.h"

@implementation NSSet (BlocksKit)

- (void)bk_each:(void (^)(id obj))block
{
	NSParameterAssert(block != nil);

	[self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
		block(obj);
	}];
}

- (void)bk_apply:(void (^)(id obj))block
{
	NSParameterAssert(block != nil);

	[self enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, BOOL *stop) {
		block(obj);
	}];
}

- (id)bk_match:(BOOL (^)(id obj))block
{
	NSParameterAssert(block != nil);

	return [[self objectsPassingTest:^BOOL(id obj, BOOL *stop) {
		if (block(obj)) {
			*stop = YES;
			return YES;
		}

		return NO;
	}] anyObject];
}

- (NSSet *)bk_select:(BOOL (^)(id obj))block
{
	NSParameterAssert(block != nil);

	return [self objectsPassingTest:^BOOL(id obj, BOOL *stop) {
		return block(obj);
	}];
}

- (NSSet *)bk_reject:(BOOL (^)(id obj))block
{
	NSParameterAssert(block != nil);

	return [self objectsPassingTest:^BOOL(id obj, BOOL *stop) {
		return !block(obj);
	}];
}

- (NSSet *)bk_map:(id (^)(id obj))block
{
	NSParameterAssert(block != nil);

	NSMutableSet *result = [NSMutableSet setWithCapacity:self.count];

	[self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
		id value = block(obj) ?:[NSNull null];
		[result addObject:value];
	}];

	return result;
}

- (id)bk_reduce:(id)initial withBlock:(id (^)(id sum, id obj))block
{
	NSParameterAssert(block != nil);

	__block id result = initial;

	[self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
		result = block(result, obj);
	}];

	return result;
}

- (BOOL)bk_any:(BOOL (^)(id obj))block
{
	return [self bk_match:block] != nil;
}

- (BOOL)bk_none:(BOOL (^)(id obj))block
{
	return [self bk_match:block] == nil;
}

- (BOOL)bk_all:(BOOL (^)(id obj))block
{
	NSParameterAssert(block != nil);

	__block BOOL result = YES;

	[self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
		if (!block(obj)) {
			result = NO;
			*stop = YES;
		}
	}];

	return result;
}

@end
