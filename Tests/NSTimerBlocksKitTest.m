//
//  NSTimerBlocksKitTest.m
//  BlocksKit Unit Tests
//
//  Contributed by Kai Wu.
//

#import <XCTest/XCTest.h>
#import <BlocksKit/NSTimer+BlocksKit.h>
#import "BKAsyncTestCase.h"

static const NSTimeInterval BKTimerTestInterval = 0.025;
static const NSTimeInterval BKTimerTestTimeout = 0.25;
static const NSTimeInterval BKTimerTestMinimum = ((BKTimerTestTimeout / BKTimerTestInterval) - 2);

@interface NSTimerBlocksKitTest : BKAsyncTestCase

@end

@implementation NSTimerBlocksKitTest {
	NSInteger _total;
}

- (void)setUp {
	_total = 0;
}

- (void)testScheduledTimer {
	void(^timerBlock)(NSTimer *) = ^(NSTimer *timer) {
		_total++;
	};
	[self prepare];
	NSTimer *timer = [NSTimer bk_scheduledTimerWithTimeInterval:BKTimerTestInterval block:timerBlock repeats:NO];
	XCTAssertNotNil(timer,@"timer is nil");
	[self waitForTimeout:BKTimerTestTimeout];
	XCTAssertEqual(_total, 1, @"total is %ld", (long)_total);
}

- (void)testRepeatedScheduledTimer {
	void(^timerBlock)(NSTimer *) = ^(NSTimer *timer) {
		_total++;
	};
	[self prepare];
	NSTimer *timer = [NSTimer bk_scheduledTimerWithTimeInterval:BKTimerTestInterval block:timerBlock repeats:YES];
	XCTAssertNotNil(timer,@"timer is nil");
	[self waitForTimeout:BKTimerTestTimeout];
	[timer invalidate];
	XCTAssertTrue(_total >= BKTimerTestMinimum, @"total is %ld", (long)_total);
}

- (void)testUnscheduledTimer {
	void(^timerBlock)(NSTimer *) = ^(NSTimer *timer) {
		_total++;
	};
	[self prepare];
	NSTimer *timer = [NSTimer bk_timerWithTimeInterval:BKTimerTestInterval block:timerBlock repeats:NO];
	XCTAssertNotNil(timer,@"timer is nil");
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	[self waitForTimeout:BKTimerTestTimeout];
	XCTAssertEqual(_total, 1, @"total is %ld", (long)_total);
}

- (void)testRepeatableUnscheduledTimer {
	void(^timerBlock)(NSTimer *) = ^(NSTimer *timer) {
		_total += 1;
	};
	[self prepare];
	NSTimer *timer = [NSTimer bk_timerWithTimeInterval:BKTimerTestInterval block:timerBlock repeats:YES];
	XCTAssertNotNil(timer,@"timer is nil");
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	[self waitForTimeout:BKTimerTestTimeout];
	[timer invalidate];
	XCTAssertTrue(_total >= BKTimerTestMinimum, @"total is %ld", (long)_total);
}

@end
