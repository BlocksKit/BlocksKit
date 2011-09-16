//
//  NSMutableSet+BlocksKit.m
//  BlocksKit
//

#import "NSMutableSet+BlocksKit.h"

@implementation NSMutableSet (BlocksKit)

- (void)performSelect:(BKValidationBlock)block {
    NSSet *list = [self objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        return block(obj);
    }];
    
    if (!list.count)
        return;
    
    [self setSet:list];
}

- (void)performReject:(BKValidationBlock)block {
    NSSet *list = [self objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        return !block(obj);
    }];
    
    if (!list.count)
        return;
    
    [self setSet:list];    
}

- (void)performMap:(BKTransformBlock)block {
    NSSet *old = BK_AUTORELEASE([self copy]);
    [self removeAllObjects];
    [old enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [self addObject:block(obj)];
    }];
}

@end
