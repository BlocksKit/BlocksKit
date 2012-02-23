//
//  NSSet+BlocksKit.m
//  BlocksKit
//

#import "NSSet+BlocksKit.h"

@implementation NSSet (BlocksKit)

- (void)each:(BKSenderBlock)block {
	NSParameterAssert(block != nil);
	
	[self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
		block(obj);
	}];
}

- (void)apply:(BKSenderBlock)block {
	NSParameterAssert(block != nil);
	
	[self enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, BOOL *stop) {
		block(obj);
	}];
}

- (id)match:(BKValidationBlock)block {
	NSParameterAssert(block != nil);
	
	return [[self objectsPassingTest:^BOOL(id obj, BOOL *stop) {
		if (block(obj)) {
			*stop = YES;
			return YES;
		}
		return NO;
	}] anyObject];
}

- (NSSet *)select:(BKValidationBlock)block {  
	NSParameterAssert(block != nil);
	
	return [self objectsPassingTest:^BOOL(id obj, BOOL *stop) {
		return (block(obj));
	}];
}

- (NSSet *)reject:(BKValidationBlock)block {
	NSParameterAssert(block != nil);
	
	return [self objectsPassingTest:^BOOL(id obj, BOOL *stop) {
		return (!block(obj));
	}];
}

- (NSSet *)map:(BKTransformBlock)block {
	NSParameterAssert(block != nil);
	
	NSMutableSet *result = [[NSMutableSet alloc] initWithCapacity:self.count];
	
	[self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
		id value = block(obj);
		if (!value)
			value = [NSNull null];
		
		[result addObject:value];
	}];

	return [result autorelease];
}

- (id)reduce:(id)initial withBlock:(BKAccumulationBlock)block {
	NSParameterAssert(block != nil);
	
	__block id result = [initial retain];
	
	[self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
		id new = block(result, obj);
		[result release];
		result = [new retain];
	}];
	
	return [result autorelease];
}

@end
