//
//  BKAsyncTestCase.h
//  BlocksKit Unit Tests
//

#import <SenTestingKit/SenTestingKit.h>

enum {
	SenAsyncTestCaseStatusUnknown = 0,
	SenAsyncTestCaseStatusWaiting,
	SenAsyncTestCaseStatusSucceeded,
	SenAsyncTestCaseStatusFailed,
	SenAsyncTestCaseStatusCancelled,
};
typedef NSUInteger SenAsyncTestCaseStatus;

@interface BKAsyncTestCase : SenTestCase

- (void)waitForStatus:(SenAsyncTestCaseStatus)status timeout:(NSTimeInterval)timeout;
- (void)waitForTimeout:(NSTimeInterval)timeout;
- (void)notify:(SenAsyncTestCaseStatus)status;

@end
