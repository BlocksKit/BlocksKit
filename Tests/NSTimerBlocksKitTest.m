//
//  NSTimerBlocksKitTest.m
//  BlocksKit Unit Tests
//
//  Contributed by Kai Wu.
//

#import <XCTest/XCTest.h>
#import <BlocksKit/NSTimer+BlocksKit.h>
#import "BKAsyncTestCase.h"

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
		NSLog(@"total is %lu", (unsigned long)_total);
	};
	[self prepare];
	NSTimer *timer = [NSTimer bk_scheduledTimerWithTimeInterval:0.1 block:timerBlock repeats:NO];
	XCTAssertNotNil(timer,@"timer is nil");
	[self waitForTimeout:1];
	XCTAssertEqual(_total, (NSInteger)1, @"total is %ld", (long)_total);
}

- (void)testRepeatedlyScheduledTimer {
	void(^timerBlock)(NSTimer *) = ^(NSTimer *timer) {
		_total++;
		NSLog(@"total is %lu", (unsigned long)_total);
	};
	[self prepare];
	NSTimer *timer = [NSTimer bk_scheduledTimerWithTimeInterval:0.1 block:timerBlock repeats:YES];
	XCTAssertNotNil(timer,@"timer is nil");
	[self waitForTimeout:1];
	[timer invalidate];
	XCTAssertTrue(_total > 3, @"total is %ld", (long)_total);
}

- (void)testUnscheduledTimer {
	void(^timerBlock)(NSTimer *) = ^(NSTimer *timer) {
		_total++;
		NSLog(@"total is %lu", (unsigned long)_total);
	};
	[self prepare];
	NSTimer *timer = [NSTimer bk_timerWithTimeInterval:0.1 block:timerBlock repeats:NO];
	XCTAssertNotNil(timer,@"timer is nil");
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	[self waitForTimeout:1];
	XCTAssertEqual(_total, (NSInteger)1, @"total is %ld", (long)_total);
}

- (void)testRepeatableUnscheduledTimer {
	void(^timerBlock)(NSTimer *) = ^(NSTimer *timer) {
		_total += 1;
		NSLog(@"total is %lu", (unsigned long)_total);
	};
	[self prepare];
	NSTimer *timer = [NSTimer bk_timerWithTimeInterval:0.1 block:timerBlock repeats:YES];
	XCTAssertNotNil(timer,@"timer is nil");
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	[self waitForTimeout:1];
	[timer invalidate];
	XCTAssertTrue(_total > 3, @"total is %ld", (long)_total);
}

@end
