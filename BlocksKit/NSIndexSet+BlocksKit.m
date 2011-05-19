//
//  NSIndexSet+BlocksKit.m
//  BlocksKit
//

#import "NSIndexSet+BlocksKit.h"

@implementation NSIndexSet (BlocksKit)

- (void)each:(BKIndexBlock)block {
    __block BKIndexBlock theBlock = block;
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        dispatch_async(dispatch_get_main_queue(), ^{ theBlock(idx); });
    }];
}

- (NSUInteger)match:(BKIndexValidationBlock)block {
    __block BKIndexValidationBlock theBlock = block;
    return [self indexPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        if (theBlock(idx)) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
}

- (NSIndexSet *)select:(BKIndexValidationBlock)block {
    __block BKIndexValidationBlock theBlock = block;
    __block NSMutableIndexSet *list = [[NSMutableIndexSet alloc] initWithCapacity:self.count];
    
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if (theBlock(idx))
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
    __block BKIndexValidationBlock theBlock = block;
    __block NSMutableIndexSet *list = [[NSMutableIndexSet alloc] initWithCapacity:self.count];
    
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if (!theBlock(idx))
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
