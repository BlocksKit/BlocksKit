//
//  BKDelegateProxy.m
//  BlocksKit
//

#import "BKDelegateProxy.h"

static char *kBKDelegateKey = "BlocksKitCustomDelegate";

@implementation BKDelegateProxy

#pragma mark - Initialization

+ (id)shared {
    static id proxyDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        proxyDelegate = [[[self class] alloc] init];
    });
    
    return proxyDelegate;
}

@end
