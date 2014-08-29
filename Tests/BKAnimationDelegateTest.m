//
//  BKAnimationDelegateTest.m
//  BlocksKit Unit Tests
//
//  Contributed by Sergio Padrino
//

#import <XCTest/XCTest.h>

#import <BlocksKit/BKAnimationDelegate.h>

@interface BKAnimationDelegateTest : XCTestCase

@end

@implementation BKAnimationDelegateTest

- (void)testAnimationDidStart
{
	__block BOOL startBlockInvoked = NO;
	
	BKAnimationDelegate *subject = [BKAnimationDelegate
									animationDelegateWithStartBlock:^(CAAnimation *anim) {
										
										startBlockInvoked = YES;
									}
									stopBlock:nil];
	
	[subject animationDidStart:nil];
	
	XCTAssertTrue(startBlockInvoked, @"Start block should have been invoked");
}

- (void)testAnimationDidStopFinishedYes
{
	__block BOOL stopBlockInvoked = NO;
	__block BOOL animationFinished = NO;
	
	BKAnimationDelegate *subject = [BKAnimationDelegate
									animationDelegateWithStartBlock:nil
									stopBlock:^(CAAnimation *anim, BOOL finished) {
										
										stopBlockInvoked = YES;
										animationFinished = finished;
									}];
	
	[subject animationDidStop:nil finished:YES];
	
	XCTAssertTrue(stopBlockInvoked, @"Stop block should have been invoked");
	XCTAssertTrue(animationFinished, @"finished should be YES");
}

- (void)testAnimationDidStopFinishedNo
{
	__block BOOL stopBlockInvoked = NO;
	__block BOOL animationFinished = YES;
	
	BKAnimationDelegate *subject = [BKAnimationDelegate
									animationDelegateWithStartBlock:nil
									stopBlock:^(CAAnimation *anim, BOOL finished) {
										
										stopBlockInvoked = YES;
										animationFinished = finished;
									}];
	
	[subject animationDidStop:nil finished:NO];
	
	XCTAssertTrue(stopBlockInvoked, @"Stop block should have been invoked");
	XCTAssertFalse(animationFinished, @"finished should be NO");
}

@end
