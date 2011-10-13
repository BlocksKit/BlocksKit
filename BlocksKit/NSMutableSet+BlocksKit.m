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
    
    [self setSet:list];
}

- (void)performReject:(BKValidationBlock)block {
    NSSet *list = [self objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        return !block(obj);
    }];
    
    [self setSet:list];    
}

- (void)performMap:(BKTransformBlock)block {
    NSMutableSet *new = [NSMutableSet setWithCapacity:self.count];

    [self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [new addObject:block(obj)];
    }];
    
    [self setSet:new];
}

@end
