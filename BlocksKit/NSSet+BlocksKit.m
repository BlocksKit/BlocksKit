//
//  NSSet+BlocksKit.m
//  BlocksKit
//

#import "NSSet+BlocksKit.h"

@implementation NSSet (BlocksKit)

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

- (NSSet *)select:(BKValidationBlock)block {
    NSMutableSet *list = [[NSMutableSet alloc] initWithCapacity:self.count];
    for (id obj in self) {
        if (block(obj))
            [list addObject:obj];
    }
    
    if (!list.count) {
        [list release];
        return nil;
    }
    
    NSSet *result = [list copy];
    [list release];
    return [result autorelease];
}

- (NSSet *)reject:(BKValidationBlock)block {
    NSMutableSet *list = [[NSMutableSet alloc] initWithCapacity:self.count];
    for (id obj in self) {
        if (!block(obj))
            [list addObject:obj];
    }
    
    if (!list.count) {
        [list release];
        return nil;
    }
    
    NSSet *result = [list copy];
    [list release];
    return [result autorelease];
}

- (NSSet *)map:(BKTransformBlock)block {
    NSMutableSet *list = [[NSMutableSet alloc] initWithCapacity:self.count];
    for (id obj in self) {
        [list addObject:block(obj)];
    }
    NSSet *result = [list copy];
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
