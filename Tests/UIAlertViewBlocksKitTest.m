//
//  UIAlertViewBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import <XCTest/XCTest.h>
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import <BlocksKit/A2DynamicDelegate.h>

@interface UIAlertViewBlocksKitTest : XCTestCase

@end

@implementation UIAlertViewBlocksKitTest {
	UIAlertView *_subject;
}

- (void)setUp {
	_subject = [[UIAlertView alloc] bk_initWithTitle:@"Hello BlocksKit" message:@"This is a message."];
}

- (void)testInit {
	XCTAssertTrue([_subject isKindOfClass:[UIAlertView class]],@"subject is UIAlertView");
	XCTAssertTrue([_subject.delegate isEqual:_subject.bk_dynamicDelegate], @"the delegate is not dynamic");
	XCTAssertEqualObjects(_subject.title,@"Hello BlocksKit",@"the UIAlertView title is %@",_subject.title);
	XCTAssertEqual(_subject.numberOfButtons, (NSInteger)0,@"the action sheet has %ld buttons", (long)_subject.numberOfButtons);
	XCTAssertFalse(_subject.isVisible,@"the action sheet is not visible");
}

- (void)testAddButtonWithHandler {
	__block NSInteger total = 0;
	
	NSInteger index1 = [_subject bk_addButtonWithTitle:@"Button 1" handler:^{ total++; }];
	NSInteger index2 = [_subject bk_addButtonWithTitle:@"Button 2" handler:^{ total += 2; }];
	
	XCTAssertEqual(_subject.numberOfButtons,(NSInteger)2,@"the alert view has %ld buttons", (long)_subject.numberOfButtons);
	
	NSString *title = @"Button";
	title = [_subject buttonTitleAtIndex:index1];
	XCTAssertEqualObjects(title,@"Button 1",@"the UIActionSheet adds a button with title %@",title);
	
	title = [_subject buttonTitleAtIndex:index2];
	XCTAssertEqualObjects(title,@"Button 2",@"the UIActionSheet adds a button with title %@",title);
	
	[_subject.bk_dynamicDelegate alertView:_subject clickedButtonAtIndex:index1];
	[_subject.bk_dynamicDelegate alertView:_subject clickedButtonAtIndex:index2];
	
	XCTAssertEqual(total, (NSInteger)3, @"Not all block handlers were called.");
}

- (void)testSetCancelButtonWithHandler {
	__block BOOL blockCalled = NO;
	
	NSInteger index = [_subject bk_setCancelButtonWithTitle:@"Cancel" handler:^{ blockCalled = YES; }];
	XCTAssertEqual(_subject.numberOfButtons,(NSInteger)1,@"the alert view has %ld buttons", (long)_subject.numberOfButtons);
	XCTAssertEqual(_subject.cancelButtonIndex,(NSInteger)index,@"the alert view cancel button index is %ld", (long)_subject.cancelButtonIndex);
	
	NSString *title = [_subject buttonTitleAtIndex:index];
	XCTAssertEqualObjects(title,@"Cancel",@"the UIActionSheet adds a button with title %@",title);
	
	[_subject.bk_dynamicDelegate alertViewCancel:_subject];
	
	XCTAssertTrue(blockCalled, @"Block handler was not called.");
}

- (void)testDelegationBlocks {
	__block BOOL willShow = NO;
	__block BOOL didShow = NO;
	
	_subject.bk_willShowBlock = ^(UIAlertView *view) { willShow = YES; };
	_subject.bk_didShowBlock = ^(UIAlertView *view) { didShow = YES; };
	
	[_subject.bk_dynamicDelegate willPresentAlertView:_subject];
	[_subject.bk_dynamicDelegate didPresentAlertView:_subject];
	
	XCTAssertTrue(willShow, @"willShowBlock not fired.");
	XCTAssertTrue(didShow, @"didShowblock not fired.");
}

@end
