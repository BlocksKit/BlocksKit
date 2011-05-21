//
//  NSArray+BlocksKit.m
//  BlocksKit
//

#import "NSArray+BlocksKit.h"

@implementation NSArray (BlocksKit)

- (void)each:(BKSenderBlock)block {
    for (id obj in self) {
        dispatch_async(dispatch_get_main_queue(), ^{ block(obj); });
    }
}

- (id)match:(BKValidationBlock)block {
    for (id obj in self) {
        if (block(obj))
            return obj;
    }
    return nil;
}

- (NSArray *)select:(BKValidationBlock)block {
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (id obj in self) {
        if (block(obj))
            [list addObject:obj];
    }
    
    if (!list.count) {
        [list release];
        return nil;
    }
    
    NSArray *result = [list copy];
    [list release];
    return [result autorelease];
}

- (NSArray *)reject:(BKValidationBlock)block {
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (id obj in self) {
        if (!block(obj))
            [list addObject:obj];
    }
    
    if (!list.count) {
        [list release];
        return nil;
    }
    
    NSArray *result = [list copy];
    [list release];
    return [result autorelease];    
}

- (NSArray *)map:(BKTransformBlock)block {
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (id obj in self) {
        [list addObject:block(obj)];
    }
    NSArray *result = [list copy];
    [list release];
    return [result autorelease];
}

- (id)reduce:(id)initial withBlock:(BKAccumulationBlock)block {
    id result = initial;
    for (id obj in self) {
        result = block(result, obj);
    }
    return result;
}

@end
