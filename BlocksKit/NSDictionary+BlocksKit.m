//
//  NSDictionary+BlocksKit.m
//  BlocksKit
//

#import "NSDictionary+BlocksKit.h"

@implementation NSDictionary (BlocksKit)

- (void)each:(BKKeyValueBlock)block {
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        block(key, obj);
    }];
}

- (NSDictionary *)select:(BKKeyValueValidationBlock)block {
    NSMutableDictionary *list = [NSMutableDictionary dictionaryWithCapacity:self.count];
    
    [self each:^(id key, id obj) {
        if (block(key, obj))
            [list setObject:obj forKey:key];
    }];
    
    if (!list.count)
        return nil;
    
    return list;
}

- (NSDictionary *)reject:(BKKeyValueValidationBlock)block {
    NSMutableDictionary *list = [NSMutableDictionary dictionaryWithCapacity:self.count];
    
    [self each:^(id key, id obj) {
        if (!block(key, obj))
            [list setObject:obj forKey:key];
    }];
    
    if (!list.count)
        return nil;
    
    return list;    
}

- (NSDictionary *)map:(BKKeyValueTransformBlock)block {
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:self.count];

    [self each:^(id key, id obj) {
        id value = block(key, obj);
        if (!value)
            value = [NSNull null];
        
        [result setObject:value forKey:key];
    }];
    
    return result;
}

@end
