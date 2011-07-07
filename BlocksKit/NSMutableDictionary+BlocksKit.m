//
//  NSMutableDictionary+BlocksKit.m
//  BlocksKit
//

#import "NSMutableDictionary+BlocksKit.h"

@implementation NSMutableDictionary (BlocksKit)

- (void)performSelect:(BKKeyValueValidationBlock)block {
    NSMutableArray *keys = [NSMutableArray arrayWithCapacity:self.count];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (!block(key, obj))
            [keys addObject:key];
    }];

    [self removeObjectsForKeys:keys];
}

- (void)performReject:(BKKeyValueValidationBlock)block {
    NSMutableArray *keys = [NSMutableArray arrayWithCapacity:self.count];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (block(key, obj))
            [keys addObject:key];
    }];
    
    [self removeObjectsForKeys:keys];    
}

- (void)performMap:(BKKeyValueTransformBlock)block {
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id value = block(key, value);
        
        if (!value)
            value = [NSNull null];
        
        if ([value isEqual:obj])
            return;

        [self setObject:value forKey:key];
    }];
}

@end
