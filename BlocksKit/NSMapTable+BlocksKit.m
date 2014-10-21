//
//  NSMapTable+BlocksKit.h
//  BlocksKit
//

#import "NSMapTable+BlocksKit.h"

@implementation NSMapTable (BlocksKit)

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block {
    BOOL stop = NO;
    for(id key in self) {
        id obj = [self objectForKey:key];
        block(key, obj, &stop);
        if(stop) {
            break;
        }
    }
}

- (void)each:(BKKeyValueBlock)block {
    NSParameterAssert(block != nil);

    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        block(key, obj);
    }];
}

- (void)apply:(BKKeyValueBlock)block {
    NSParameterAssert(block != nil);

    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        block(key, obj);
    }];
}

- (id)match:(BKKeyValueValidationBlock)block {
    NSParameterAssert(block != nil);

    __block id match = nil;
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if(block(key, obj)) {
            match = obj;
            *stop = YES;
        }
    }];
    return match;
}

- (NSMapTable *)select:(BKKeyValueValidationBlock)block {
    NSParameterAssert(block != nil);

    NSMapTable *result = [[NSMapTable alloc] initWithKeyPointerFunctions:self.keyPointerFunctions valuePointerFunctions:self.valuePointerFunctions capacity:self.count];

    [self each:^(id key, id obj) {
        if(block(key, obj)) {
            [result setObject:obj forKey:key];
        }
    }];

    return result;
}

- (NSMapTable *)reject:(BKKeyValueValidationBlock)block {
    return [self select:^BOOL(id key, id obj) {
        return !block(key, obj);
    }];
}

- (NSMapTable *)map:(BKKeyValueTransformBlock)block {
    NSParameterAssert(block != nil);

    NSMapTable *result = [[NSMapTable alloc] initWithKeyPointerFunctions:self.keyPointerFunctions valuePointerFunctions:self.valuePointerFunctions capacity:self.count];

    [self each:^(id key, id obj) {
        id value = block(key, obj);
        if (!value)
            value = [NSNull null];

        [result setObject:value forKey:key];
    }];

    return result;
}

- (BOOL)any:(BKKeyValueValidationBlock)block {
    return [self match: block] != nil;
}

- (BOOL)none:(BKKeyValueValidationBlock)block {
    return [self match: block] == nil;
}

- (BOOL)all:(BKKeyValueValidationBlock)block {
    NSParameterAssert(block != nil);

    __block BOOL result = YES;

    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (!block(key, obj)) {
            result = NO;
            *stop = YES;
        }
    }];
    
    return result;
}

@end
