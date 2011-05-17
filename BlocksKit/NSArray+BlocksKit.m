//
//  NSArray+BlocksKit.m
//  BlocksKit
//

#import "NSArray+BlocksKit.h"

@implementation NSArray (BlocksKit)

- (void)each:(void (^)(id obj))block {
    for (id obj in self) {
        block(obj);
    }
}

- (id)match:(BOOL (^)(id obj))block {
    for (id obj in self) {
        if (block(obj))
            return obj;
    }
    return nil;
}

- (NSArray *)select:(BOOL (^)(id obj))block {
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

- (NSArray *)map:(id (^)(id obj))block {
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (id obj in self) {
        [list addObject:block(obj)];
    }
    NSArray *result = [list copy];
    [list release];
    return [result autorelease];
}

- (id)reduce:(id)initial withBlock:(id (^)(id sum, id obj))block {
    id result = initial;
    for (id obj in self) {
        result = block(result, obj);
    }
    return result;
}

@end
