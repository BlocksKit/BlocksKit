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
