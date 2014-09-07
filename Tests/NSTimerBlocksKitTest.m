//
//  NSTimerBlocksKitTest.m
//  BlocksKit Unit Tests
//
//  Contributed by Kai Wu.
//

#import <XCTest/XCTest.h>
#import <BlocksKit/NSTimer+BlocksKit.h>
#import "XCTestCase+BKAsyncTestCase.h"

static const NSTimeInterval BKTimerTestInterval = 0.025;
static const NSTimeInterval BKTimerTestTimeout = 1.0;
static const NSInteger BKTimerTestMinimum = ((NSInteger)(BKTimerTestTimeout / BKTimerTestInterval) - 2);

@interface NSTimerBlocksKitTest : XCTestCase

@end

@implementation NSTimerBlocksKitTest

- (void)testScheduledTimer {
	__block NSInteger total = 0;
	
	void(^timerBlock)(NSTimer *) = ^(NSTimer *timer) {
		total++;
		[self bk_finishRunningAsyncTest];
	};
	
	[self bk_performAsyncTestWithTimeout:BKTimerTestTimeout block:^{
		NSTimer *timer = [NSTimer bk_scheduledTimerWithTimeInterval:BKTimerTestInterval block:timerBlock repeats:NO];
		if (!timer) {
			[self bk_finishRunningAsyncTest];
			XCTFail(@"timer is nil");
		}
	}];
	
	XCTAssertEqual(total, 1, @"total is %ld", (long)total);
}

- (void)testRepeatedScheduledTimer {
	__block NSInteger total = 0;
	
	void(^timerBlock)(NSTimer *) = ^(NSTimer *timer) {
		total++;
		if (total >= BKTimerTestMinimum) {
			[self bk_finishRunningAsyncTest];
			[timer invalidate];
		}
	};
	
	[self bk_performAsyncTestWithTimeout:BKTimerTestTimeout block:^{
		NSTimer *timer = [NSTimer bk_scheduledTimerWithTimeInterval:BKTimerTestInterval block:timerBlock repeats:YES];
		if (!timer) {
			[self bk_finishRunningAsyncTest];
			XCTFail(@"timer is nil");
		}
	}];
}

- (void)testUnscheduledTimer {
	__block NSInteger total = 0;

	void(^timerBlock)(NSTimer *) = ^(NSTimer *timer) {
		total++;
		[self bk_finishRunningAsyncTest];
	};
	
	[self bk_performAsyncTestWithTimeout:BKTimerTestTimeout block:^{
		NSTimer *timer = [NSTimer bk_scheduledTimerWithTimeInterval:BKTimerTestInterval block:timerBlock repeats:NO];
		if (!timer) {
			[self bk_finishRunningAsyncTest];
			XCTFail(@"timer is nil");
		}
		[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	}];
	
	XCTAssertEqual(total, 1, @"total is %ld", (long)total);
}

- (void)testRepeatedUnscheduledTimer {
	__block NSInteger total = 0;
	
	void(^timerBlock)(NSTimer *) = ^(NSTimer *timer) {
		total++;
		if (total >= BKTimerTestMinimum) {
			[self bk_finishRunningAsyncTest];
			[timer invalidate];
		}
	};
	
	[self bk_performAsyncTestWithTimeout:BKTimerTestTimeout block:^{
		NSTimer *timer = [NSTimer bk_timerWithTimeInterval:BKTimerTestInterval block:timerBlock repeats:YES];
		if (!timer) {
			[self bk_finishRunningAsyncTest];
			XCTFail(@"timer is nil");
		}
		[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	}];
}

@end
