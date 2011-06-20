//
//  NSSet+BlocksKit.m
//  BlocksKit
//

#import "NSSet+BlocksKit.h"

@implementation NSSet (BlocksKit)

- (void)each:(BKSenderBlock)block {
    [self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        block(obj);
    }];
}

- (id)match:(BKValidationBlock)block {
    return [[self objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        if (block(obj)) {
            *stop = YES;
            return YES;
        }
        return NO;
    }] anyObject];
}

- (NSSet *)select:(BKValidationBlock)block {    
    NSSet *list = [self objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        return (block(obj));
    }];
    
    if (!list.count)
        return nil;
    
    return list;
}

- (NSSet *)reject:(BKValidationBlock)block {
    NSSet *list = [self objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        return (!block(obj));
    }];
    
    if (!list.count)
        return nil;
    
    return list;
}

- (NSSet *)map:(BKTransformBlock)block {
    NSMutableSet *result = [NSMutableSet setWithCapacity:self.count];
    
    [self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        id value = block(obj);
        if (!value)
            value = [NSNull null];
        
        [result addObject:value];
    }];

    return result;
}

- (id)reduce:(id)initial withBlock:(BKAccumulationBlock)block {
    __block id result = initial;
    
    [self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        result = block(result, obj);
    }];
    
    return result;
}

@end
