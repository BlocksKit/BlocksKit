//
//  NSMutableIndexSet+BlocksKit.m
//  BlocksKit
//

#import "NSMutableIndexSet+BlocksKit.h"

@implementation NSMutableIndexSet (BlocksKit)

- (void)performSelect:(BKIndexValidationBlock)block {
    NSIndexSet *list = [self indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return !block(idx);
    }];
    
    if (!list.count)
        return;
    
    [self removeIndexes:list];
}

- (void)performReject:(BKIndexValidationBlock)block {
    NSIndexSet *list = [self indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return block(idx);
    }];
    
    if (!list.count)
        return;
    
    [self removeIndexes:list];    
}

- (void)performMap:(BKIndexTransformBlock)block {
    NSIndexSet *list = BK_AUTORELEASE([self copy]);
    [self removeAllIndexes];
    [list enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [self addIndex:block(idx)];
    }];
}

@end