//
//  NSMapTable+BlocksKit.h
//  BlocksKit
//

#import "NSMapTable+BlocksKit.h"

@implementation NSMapTable (BlocksKit)

- (void)bk_enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block {
    BOOL stop = NO;
    for(id key in self) {
        id obj = [self objectForKey:key];
        block(key, obj, &stop);
        if(stop) {
            break;
        }
    }
}

- (void)bk_each:(void (^)(id key, id obj))block
{
    NSParameterAssert(block != nil);

    [self bk_enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        block(key, obj);
    }];
}

- (id)bk_match:(BOOL (^)(id key, id obj))block
{
    NSParameterAssert(block != nil);

    __block id match = nil;
    [self bk_enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if(block(key, obj)) {
            match = obj;
            *stop = YES;
        }
    }];
    return match;
}

- (NSMapTable *)bk_select:(BOOL (^)(id key, id obj))block
{
    NSParameterAssert(block != nil);

    NSMapTable *result = [[NSMapTable alloc] initWithKeyPointerFunctions:self.keyPointerFunctions valuePointerFunctions:self.valuePointerFunctions capacity:self.count];

    [self bk_each:^(id key, id obj) {
        if(block(key, obj)) {
            [result setObject:obj forKey:key];
        }
    }];

    return result;
}

- (NSMapTable *)bk_reject:(BOOL (^)(id key, id obj))block
{
    return [self bk_select:^BOOL(id key, id obj) {
        return !block(key, obj);
    }];
}

- (NSMapTable *)bk_map:(id (^)(id key, id obj))block
{
    NSParameterAssert(block != nil);

    NSMapTable *result = [[NSMapTable alloc] initWithKeyPointerFunctions:self.keyPointerFunctions valuePointerFunctions:self.valuePointerFunctions capacity:self.count];

    [self bk_each:^(id key, id obj) {
        id value = block(key, obj);
        if (!value)
            value = [NSNull null];

        [result setObject:value forKey:key];
    }];

    return result;
}

- (BOOL)bk_any:(BOOL (^)(id key, id obj))block
{
    return [self bk_match:block] != nil;
}

- (BOOL)bk_none:(BOOL (^)(id key, id obj))block
{
    return [self bk_match:block] == nil;
}

- (BOOL)bk_all:(BOOL (^)(id key, id obj))block
{
    NSParameterAssert(block != nil);

    __block BOOL result = YES;

    [self bk_enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (!block(key, obj)) {
            result = NO;
            *stop = YES;
        }
    }];
    
    return result;
}

- (void)bk_performSelect:(BOOL (^)(id key, id obj))block
{
	NSParameterAssert(block != nil);

	NSMutableArray *keys = [NSMutableArray arrayWithCapacity:self.count];

	[self bk_each:^(id key, id obj) {
		if(!block(key, obj)) {
			[keys addObject:key];
		}
	}];

	for(id key in keys) {
		[self removeObjectForKey:key];
	}
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

	NSMutableDictionary *mapped = [NSMutableDictionary dictionaryWithCapacity:self.count];

	[self bk_each:^(id key, id obj) {
		mapped[key] = block(key, obj);
	}];

	[mapped enumerateKeysAndObjectsUsingBlock:^(id key, id mappedObject, BOOL *stop) {
		[self setObject:mappedObject forKey:key];
	}];
}

@end
