//
//  BKDelegate.m
//  BlocksKit
//

#import "BKDelegate.h"
#import <objc/runtime.h>

@implementation BKDelegate

static char *kSharedDelegateKey = "BKDelegate";

+ (id)shared {
    id proxyDelegate = objc_getAssociatedObject([self targetClass], kSharedDelegateKey);
    if (!proxyDelegate) {
        proxyDelegate = [[self class] new];
        objc_setAssociatedObject([self targetClass], kSharedDelegateKey, proxyDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return proxyDelegate;
}

+ (Class)targetClass {
    return [NSObject class];
}

@end
