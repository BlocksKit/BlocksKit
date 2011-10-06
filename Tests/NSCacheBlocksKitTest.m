//
//  NSCacheBlocksKitTest.m
//  BlocksKit
//
//  Created by Zachary Waldowski on 10/5/11.
//  Copyright (c) 2011 Dizzy Technology. All rights reserved.
//

#import "NSCacheBlocksKitTest.h"
#import "NSTimer+BlocksKit.h"

@implementation NSCacheBlocksKitTest

@synthesize subject;

- (BOOL)shouldRunOnMainThread {
    // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
    return NO;
}

- (void)setUpClass {
    // Run at start of all tests in the class
    self.subject = [[[NSCache alloc] init] autorelease];
}

- (void)tearDownClass {
    // Run at end of all tests in the class
    self.subject = nil;
}

- (void)setUp {
    total = 0;
}

- (void)testEvictionDelegate {
    self.subject.willEvictObjectHandler = ^(id obj){
        total--;
    };
    
    for (NSUInteger i = 0; i < 300; i++) {
        NSString *obj = [NSString stringWithFormat:@"%i", i];
        NSIndexPath *key = [NSIndexPath indexPathWithIndex:i];
        [self.subject setObject:obj forKey:key];
        total++;
    }
    
    // force an eviction
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"UISimulatedMemoryWarningNotification", NULL, NULL, true);
    
    [self prepare];
    
    [self performSelector:@selector(_succeed) withObject:nil afterDelay:4];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
}

- (void)_succeed {
    GHAssertEquals(total, 2, @"The cache should have been emptied!");
    [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testEvictionDelegate)];
    self.subject.willEvictObjectHandler = nil;
}

@end
