//
//  XCTestCase+BKAsyncTestCase.m
//  BlocksKit Unit Tests
//

#import "XCTestCase+BKAsyncTestCase.h"
#import <objc/runtime.h>

static void *BKAsyncRestCaseWaitingKey = &BKAsyncRestCaseWaitingKey;

@interface XCTestCase (BKAsyncTestCasePrivate)

@property (nonatomic) BOOL bk_waitingForAsyncTest;

@end

@implementation XCTestCase (BKAsyncTestCasePrivate)

- (void)setBk_waitingForAsyncTest:(BOOL)isWaiting
{
	static const void *waitingValue = &waitingValue;
	objc_setAssociatedObject(self, BKAsyncRestCaseWaitingKey, isWaiting ? @YES : nil, OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)bk_waitingForAsyncTest
{
	return !!objc_getAssociatedObject(self, BKAsyncRestCaseWaitingKey);
}

@end

@implementation XCTestCase (BKAsyncTestCase)

- (void)bk_performAsyncTestWithTimeout:(NSTimeInterval)timeout block:(void (^)(void))asynchronousTest
{
	self.bk_waitingForAsyncTest = YES;
	asynchronousTest();
	
	NSTimeInterval timeoutTime = [[NSDate dateWithTimeIntervalSinceNow:timeout] timeIntervalSinceReferenceDate];
	while (self.bk_waitingForAsyncTest)  {
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05f]];
		if ([NSDate timeIntervalSinceReferenceDate] > timeoutTime && self.bk_waitingForAsyncTest) {
			XCTFail(@"Test timed out! Did you forget to call -mn_finishRunningAsynchronousTest");
			self.bk_waitingForAsyncTest = NO;
		}
	}
}

- (void)bk_finishRunningAsyncTest
{
	self.bk_waitingForAsyncTest = NO;
}

@end
