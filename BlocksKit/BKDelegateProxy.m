//
//  BKDelegateProxy.m
//  BlocksKit
//
//  Created by Zachary Waldowski on 8/12/11.
//  Copyright 2011 Dizzy Technology. All rights reserved.
//

#import "BKDelegateProxy.h"

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
