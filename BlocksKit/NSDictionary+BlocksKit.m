//
//  NSDictionary+BlocksKit.m
//  BlocksKit
//

#import "NSDictionary+BlocksKit.h"
#import <dispatch/dispatch.h>

@implementation NSDictionary (BlocksKit)

- (void)each:(BKKeyValueBlock)block {
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        dispatch_async(dispatch_get_main_queue(), ^{ block(key, obj); });
    }];
}

- (NSDictionary *)map:(BKKeyValueTransformBlock)block {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:self.count];

    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [dictionary setObject:block(key, obj) forKey:key];
    }];
    
    NSDictionary *result = [dictionary copy];
    [dictionary release];
    return [result autorelease];
}

@end
