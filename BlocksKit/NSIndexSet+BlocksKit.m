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
    NSMutableIndexSet *list = [[NSMutableIndexSet alloc] initWithCapacity:self.count];
    
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if (block(idx))
            [list addIndex:idx];
    }];
    
    if (!list.count) {
        [list release];
        return nil;
    }
    
    NSIndexSet *result = [list copy];
    [list release];
    return [result autorelease];    
}

- (NSIndexSet *)reject:(BKIndexValidationBlock)block {    
    NSMutableIndexSet *list = [[NSMutableIndexSet alloc] initWithCapacity:self.count];
    
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if (!block(idx))
            [list addIndex:idx];
    }];
    
    if (!list.count) {
        [list release];
        return nil;
    }
    
    NSIndexSet *result = [list copy];
    [list release];
    return [result autorelease];     
}

@end
