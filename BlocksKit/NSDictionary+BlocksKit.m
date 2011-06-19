//
//  NSDictionary+BlocksKit.m
//  BlocksKit
//

#import "NSDictionary+BlocksKit.h"
#import <dispatch/dispatch.h>

@implementation NSDictionary (BlocksKit)

- (void)each:(BKKeyValueBlock)block {
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        block(key, obj);
    }];
}

- (NSDictionary *)map:(BKKeyValueTransformBlock)block {
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:self.count];

    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [result setObject:block(key, obj) forKey:key];
    }];
    
    return result;
}

@end
