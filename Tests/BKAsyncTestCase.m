//
//  BKAsyncTestCase.m
//  BlocksKit Unit Tests
//
//  Created by Zachary Waldowski on 10/5/12.
//  Copyright (c) 2012 Pandamonia LLC. All rights reserved.
//

#import "BKAsyncTestCase.h"

@interface BKAsyncTestCase ()

@property (nonatomic, strong) NSDate *loopUntil;
@property (nonatomic) BOOL notified;
@property (nonatomic) SenAsyncTestCaseStatus notifiedStatus;
@property (nonatomic) SenAsyncTestCaseStatus expectedStatus;

@end

@implementation BKAsyncTestCase

- (void)waitForStatus:(SenAsyncTestCaseStatus)status timeout:(NSTimeInterval)timeout {
    self.notified = NO;
    self.expectedStatus = status;
    self.loopUntil = [NSDate dateWithTimeIntervalSinceNow:timeout];
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow: 0.1];
    while (!self.notified && self.loopUntil.timeIntervalSinceNow) {
        [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: date];
        date = [NSDate dateWithTimeIntervalSinceNow: 0.1];
    }
    
    if (self.notified) {
        STAssertEquals(self.notifiedStatus, self.expectedStatus, @"Notified status does not match the expected status.");
    } else {
        STFail(@"Async test timed out.");
    }
}

- (void)waitForTimeout:(NSTimeInterval)timeout {
    self.notified = NO;
    self.expectedStatus = SenAsyncTestCaseStatusUnknown;
    self.loopUntil = [NSDate dateWithTimeIntervalSinceNow:timeout];
    
    NSDate *dt = [NSDate dateWithTimeIntervalSinceNow:0.1];
    while (!self.notified && [self.loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:dt];
        dt = [NSDate dateWithTimeIntervalSinceNow:0.1];
    }
}

- (void)notify:(SenAsyncTestCaseStatus)status {
    self.notifiedStatus = status;
    self.notified = YES;
}

@end
