//
//  NSMutableSet+BlocksKit.m
//  BlocksKit
//

#import "NSMutableSet+BlocksKit.h"

@implementation NSMutableSet (BlocksKit)

- (void)bk_performSelect:(BOOL (^)(id obj))block {
	NSParameterAssert(block != nil);

	NSSet *list = [self objectsPassingTest:^BOOL(id obj, BOOL *stop) {
		return block(obj);
	}];

	[self setSet:list];
}

- (void)bk_performReject:(BOOL (^)(id obj))block {
	NSParameterAssert(block != nil);
	[self bk_performSelect:^BOOL(id obj) {
		return !block(obj);
	}];
}

- (void)bk_performMap:(id (^)(id obj))block {
	NSParameterAssert(block != nil);

	NSMutableSet *new = [NSMutableSet setWithCapacity:self.count];

	[self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
		id value = block(obj);
		if (!value) return;
		[new addObject:value];
	}];

	[self setSet:new];
}

@end
