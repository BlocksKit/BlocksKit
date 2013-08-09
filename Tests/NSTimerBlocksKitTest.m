//
//  NSTimerBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "NSTimerBlocksKitTest.h"

@implementation NSTimerBlocksKitTest {
	NSInteger _total;
}

- (void)setUp {
	_total = 0;
}

- (void)testScheduledTimer {
	void(^timerBlock)(NSTimer *) = ^(NSTimer *timer) {
		_total++;
		NSLog(@"total is %lu", (unsigned long)_total);
	};
	[self prepare];
	NSTimer *timer = [NSTimer bk_scheduledTimerWithTimeInterval:0.1 block:timerBlock repeats:NO];
	STAssertNotNil(timer,@"timer is nil");
	[self waitForTimeout:1];
	STAssertEquals(_total, (NSInteger)1, @"total is %d", _total);
}

- (void)testRepeatedlyScheduledTimer {
	void(^timerBlock)(NSTimer *) = ^(NSTimer *timer) {
		_total++;
		NSLog(@"total is %lu", (unsigned long)_total);
	};
	[self prepare];
	NSTimer *timer = [NSTimer bk_scheduledTimerWithTimeInterval:0.1 block:timerBlock repeats:YES];
	STAssertNotNil(timer,@"timer is nil");
	[self waitForTimeout:1];
	[timer invalidate];
	STAssertTrue(_total > 3, @"total is %d", _total);
}

- (void)testUnscheduledTimer {
	void(^timerBlock)(NSTimer *) = ^(NSTimer *timer) {
		_total++;
		NSLog(@"total is %lu", (unsigned long)_total);
	};
	[self prepare];
	NSTimer *timer = [NSTimer bk_timerWithTimeInterval:0.1 block:timerBlock repeats:NO];
	STAssertNotNil(timer,@"timer is nil");
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	[self waitForTimeout:1];
	STAssertEquals(_total, (NSInteger)1, @"total is %d", _total);
}

- (void)testRepeatableUnscheduledTimer {
	void(^timerBlock)(NSTimer *) = ^(NSTimer *timer) {
		_total += 1;
		NSLog(@"total is %lu", (unsigned long)_total);
	};
	[self prepare];
	NSTimer *timer = [NSTimer bk_timerWithTimeInterval:0.1 block:timerBlock repeats:YES];
	STAssertNotNil(timer,@"timer is nil");
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	[self waitForTimeout:1];
	[timer invalidate];
	STAssertTrue(_total > 3, @"total is %d", _total);
}

@end
