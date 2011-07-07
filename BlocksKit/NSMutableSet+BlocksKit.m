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
    [self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        id value = block(obj);
        
        if (!value)
            value = [NSNull null];
        
        if ([value isEqual:obj])
            return;
        
        [self addObject:value];
        [self removeObject:obj];
    }];
}

@end