//
//  NSMutableDictionary+BlocksKit.m
//  BlocksKit
//

#import "NSMutableDictionary+BlocksKit.h"

@implementation NSMutableDictionary (BlocksKit)

- (void)performSelect:(BKKeyValueValidationBlock)block {
	NSParameterAssert(block != nil);
	
	NSMutableArray *keys = [NSMutableArray arrayWithCapacity:self.count];
	
	[self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if (!block(key, obj))
			[keys addObject:key];
	}];

	[self removeObjectsForKeys:keys];
}

- (void)performReject:(BKKeyValueValidationBlock)block {
	[self performSelect:^BOOL(id key, id obj) {
		return !block(key, obj);
	}];
}

- (void)performMap:(BKKeyValueTransformBlock)block {
	NSParameterAssert(block != nil);
	
	NSMutableDictionary *new = [self mutableCopy];
	
	[self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		id value = block(key, obj);
		
		if (!value)
			value = [NSNull null];
		
		if ([value isEqual:obj])
			return;

		[new setObject:value forKey:key];
	}];
	
	[self setDictionary:[new autorelease]];
}

@end
