//
//  NSTimerBlocksKitTest.m
//  %PROJECT
//
//  Created by WU Kai on 7/5/11.
//

#import "NSTimerBlocksKitTest.h"


@implementation NSTimerBlocksKitTest

- (BOOL)shouldRunOnMainThread {
  // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
  return NO;
}

- (void)setUpClass {
    // Run at start of all tests in the class
}

- (void)tearDownClass {
    // Run at end of all tests in the class
}

- (void)setUp {
    // Run before each test method
    _total = 0;
}

- (void)tearDown {
    // Run after each test method
}

- (void)testScheduledTimer {
    BKTimerBlock timerBlock = ^(NSTimeInterval time) {
        _total += 1;
        NSLog(@"total is %d",_total);
    };
    [self prepare];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1 block:timerBlock repeats:NO];
    GHAssertNotNil(timer,@"timer is nil");
    [self waitForTimeout:0.5];
    GHAssertEquals(_total,1,@"total is %d",_total);
}

- (void)testRepeatedlyScheduledTimer {
    BKTimerBlock timerBlock = ^(NSTimeInterval time) {
        _total += 1;
        NSLog(@"total is %d",_total);
    };
    [self prepare];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1 block:timerBlock repeats:YES];
    GHAssertNotNil(timer,@"timer is nil");
    [self waitForTimeout:0.5];
    [timer invalidate];
    GHAssertGreaterThan(_total,3,@"total is %d",_total);
}

- (void)testUnscheduledTimer {
    BKTimerBlock timerBlock = ^(NSTimeInterval time) {
        _total += 1;
        NSLog(@"total is %d",_total);
    };
    [self prepare];
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.1 block:timerBlock repeats:NO];
    GHAssertNotNil(timer,@"timer is nil");
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [self waitForTimeout:0.5];
    GHAssertEquals(_total,1,@"total is %d",_total);
}

- (void)testRepeatableUnscheduledTimer {
    BKTimerBlock timerBlock = ^(NSTimeInterval time) {
        _total += 1;
        NSLog(@"total is %d",_total);
    };
    [self prepare];
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.1 block:timerBlock repeats:YES];
    GHAssertNotNil(timer,@"timer is nil");
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [self waitForTimeout:0.5];
    [timer invalidate];
    GHAssertGreaterThan(_total,3,@"total is %d",_total);
}

@end
