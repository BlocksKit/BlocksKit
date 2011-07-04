//
//  NSIndexSet+BlocksKit.m
//  BlocksKit
//

#import "NSIndexSet+BlocksKit.h"

@implementation NSIndexSet (BlocksKit)

- (void)each:(BKIndexBlock)block {
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        block(idx);
    }];
}

- (NSUInteger)match:(BKIndexValidationBlock)block {
    return [self indexPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        if (block(idx)) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
}

- (NSIndexSet *)select:(BKIndexValidationBlock)block {
    NSIndexSet *list = [self indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return (block(idx));
    }];
    
    if (!list.count)
        return nil;
    
    return list;
}

- (NSIndexSet *)reject:(BKIndexValidationBlock)block {    
    NSIndexSet *list = [self indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return (!block(idx));
    }];
    
    if (!list.count)
        return nil;
    
    return list;     
}

@end
