//
//  XCTestCase+BKAsyncTestCase.h
//  BlocksKit Unit Tests
//

#import <XCTest/XCTest.h>

typedef NS_ENUM(NSUInteger, SenTestCaseWaitStatus) {
	SenTestCaseWaitStatusUnknown = 0,
	SenTestCaseWaitStatusSuccess,
	SenTestCaseWaitStatusFailure,
	SenTestCaseWaitStatusCancelled
};

@interface XCTestCase (BKAsyncTestCase)

- (void)bk_performAsyncTestWithTimeout:(NSTimeInterval)timeout block:(void (^)(void))asynchronousTest;
- (void)bk_finishRunningAsyncTest;

@end
