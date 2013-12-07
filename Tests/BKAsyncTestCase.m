//
//  BKAsyncTestCase.m
//  BlocksKit Unit Tests
//

#import "BKAsyncTestCase.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSUInteger, SenTestCaseError) {
	SenTestCaseErrorNone,
	SenTestCaseErrorUnprepared,
	SenTestCaseErrorTimedOut,
	SenTestCaseErrorInvalidStatus
};

@interface BKAsyncTestCase () {
	SenTestCaseWaitStatus waitForStatus_;
	SenTestCaseWaitStatus notifiedStatus_;

	BOOL prepared_; // Whether prepared was called before waitForStatus:timeout:
	NSRecursiveLock *lock_; // Lock to synchronize on
	SEL waitSelector_; // The selector we are waiting on
}

@end

@implementation BKAsyncTestCase

- (void)_setUp {
	lock_ = [[NSRecursiveLock alloc] init];
	prepared_ = NO;
	notifiedStatus_ = SenTestCaseWaitStatusUnknown;
}

// Internal GHUnit tear down
- (void)_tearDown {
	waitSelector_ = NULL;
	if (prepared_) [lock_ unlock]; // If we prepared but never waited we need to unlock
	lock_ = nil;
}

- (void)prepare {
	[self prepare:[self selector]];
}

- (void)prepare:(SEL)selector {
	[lock_ lock];
	prepared_ = YES;
	waitSelector_ = selector;
	notifiedStatus_ = SenTestCaseWaitStatusUnknown;
}

- (SenTestCaseError)_waitFor:(NSInteger)status timeout:(NSTimeInterval)timeout {
	if (!prepared_) {
		return SenTestCaseErrorUnprepared;
	}
	prepared_ = NO;

	waitForStatus_ = status;

	if (!_runLoopModes)
		_runLoopModes = [NSArray arrayWithObjects:NSDefaultRunLoopMode, NSRunLoopCommonModes, nil];

	NSTimeInterval checkEveryInterval = 0.05;
	NSDate *runUntilDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
	BOOL timedOut = NO;
	NSInteger runIndex = 0;
	while(notifiedStatus_ == SenTestCaseWaitStatusUnknown) {
		NSString *mode = [_runLoopModes objectAtIndex:(runIndex++ % [_runLoopModes count])];

		[lock_ unlock];
		@autoreleasepool {
			if (!mode || ![[NSRunLoop currentRunLoop] runMode:mode beforeDate:[NSDate dateWithTimeIntervalSinceNow:checkEveryInterval]])
				// If there were no run loop sources or timers then we should sleep for the interval
				[NSThread sleepForTimeInterval:checkEveryInterval];
		}
		[lock_ lock];

		// If current date is after the run until date
		if ([runUntilDate compare:[NSDate date]] == NSOrderedAscending) {
			timedOut = YES;
			break;
		}
	}
	[lock_ unlock];

	if (timedOut) {
		return SenTestCaseErrorTimedOut;
	} else if (waitForStatus_ != notifiedStatus_) {
		return SenTestCaseErrorInvalidStatus;
	}

	return SenTestCaseErrorNone;
}

- (void)waitFor:(NSInteger)status timeout:(NSTimeInterval)timeout {
	[NSException raise:NSDestinationInvalidException format:@"Deprecated; Use waitForStatus:timeout:"];
}

- (void)waitForStatus:(NSInteger)status timeout:(NSTimeInterval)timeout {
	SenTestCaseError error = [self _waitFor:status timeout:timeout];
	if (error == SenTestCaseErrorTimedOut) {
		XCTFail(@"Request timed out");
	} else if (error == SenTestCaseErrorInvalidStatus) {
		XCTFail(@"Request finished with the wrong status: %ld != %ld", (long)status, (long)notifiedStatus_);
	} else if (error == SenTestCaseErrorUnprepared) {
		XCTFail(@"Call prepare before calling asynchronous method and waitForStatus:timeout:");
	}
}

- (void)waitForTimeout:(NSTimeInterval)timeout {
	SenTestCaseError error = [self _waitFor:-1 timeout:timeout];
	if (error != SenTestCaseErrorTimedOut) {
		XCTFail(@"Request should have timed out");
	}
}

- (void)runForInterval:(NSTimeInterval)interval {
	NSTimeInterval checkEveryInterval = 0.05;
	NSDate *runUntilDate = [NSDate dateWithTimeIntervalSinceNow:interval];

	if (!_runLoopModes)
		_runLoopModes = [NSArray arrayWithObjects:NSDefaultRunLoopMode, NSRunLoopCommonModes, nil];

	NSInteger runIndex = 0;

	while ([runUntilDate compare:[NSDate dateWithTimeIntervalSinceNow:0]] == NSOrderedDescending) {
		NSString *mode = [_runLoopModes objectAtIndex:(runIndex++ % [_runLoopModes count])];

		[lock_ unlock];
		@autoreleasepool {
			if (!mode || ![[NSRunLoop currentRunLoop] runMode:mode beforeDate:[NSDate dateWithTimeIntervalSinceNow:checkEveryInterval]])
				// If there were no run loop sources or timers then we should sleep for the interval
				[NSThread sleepForTimeInterval:checkEveryInterval];
		}
		[lock_ lock];
	}
}

- (void)notify:(NSInteger)status {
	[self notify:status forSelector:NULL];
}

- (void)notify:(NSInteger)status forSelector:(SEL)selector {
	@autoreleasepool {

		// Make sure the notify is for the currently waiting test
		if (selector != NULL && !sel_isEqual(waitSelector_, selector)) {
			NSLog(@"Warning: Notified from %@ but we were waiting for %@", NSStringFromSelector(selector), NSStringFromSelector(waitSelector_));
		}  else {
			[lock_ lock];
			notifiedStatus_ = status;
			[lock_ unlock];
		}

	}
}

@end
