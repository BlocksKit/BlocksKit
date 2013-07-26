//
//  UIAlertViewBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "UIAlertViewBlocksKitTest.h"
#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/A2DynamicDelegate.h>

@implementation UIAlertViewBlocksKitTest {
	UIAlertView *_subject;
}

- (void)setUp {
	_subject = [[UIAlertView alloc] bk_initWithTitle:@"Hello BlocksKit" message:@"This is a message."];
}

- (void)testInit {
	STAssertTrue([_subject isKindOfClass:[UIAlertView class]],@"subject is UIAlertView");
	STAssertFalse([_subject.delegate isEqual:_subject.bk_dynamicDelegate], @"the delegate is not dynamic");
	STAssertEqualObjects(_subject.title,@"Hello BlocksKit",@"the UIAlertView title is %@",_subject.title);
	STAssertEquals(_subject.numberOfButtons, (NSInteger)0,@"the action sheet has %d buttons",_subject.numberOfButtons);
	STAssertFalse(_subject.isVisible,@"the action sheet is not visible");
}

- (void)testAddButtonWithHandler {
	__block NSInteger total = 0;
	
	NSInteger index1 = [_subject bk_addButtonWithTitle:@"Button 1" handler:^{ total++; }];
	NSInteger index2 = [_subject bk_addButtonWithTitle:@"Button 2" handler:^{ total += 2; }];
	
	STAssertEquals(_subject.numberOfButtons,(NSInteger)2,@"the alert view has %d buttons",_subject.numberOfButtons);
	
	NSString *title = @"Button";
	title = [_subject buttonTitleAtIndex:index1];
	STAssertEqualObjects(title,@"Button 1",@"the UIActionSheet adds a button with title %@",title);
	
	title = [_subject buttonTitleAtIndex:index2];
	STAssertEqualObjects(title,@"Button 2",@"the UIActionSheet adds a button with title %@",title);
	
	[_subject.bk_dynamicDelegate alertView:_subject clickedButtonAtIndex:index1];
	[_subject.bk_dynamicDelegate alertView:_subject clickedButtonAtIndex:index2];
	
	STAssertEquals(total, 3, @"Not all block handlers were called.");
}

- (void)testSetCancelButtonWithHandler {
	__block BOOL blockCalled = NO;
	
	NSInteger index = [_subject bk_setCancelButtonWithTitle:@"Cancel" handler:^{ blockCalled = YES; }];
	STAssertEquals(_subject.numberOfButtons,1,@"the alert view has %d buttons",_subject.numberOfButtons);
	STAssertEquals(_subject.cancelButtonIndex,index,@"the alert view cancel button index is %d",_subject.cancelButtonIndex);
	
	NSString *title = [_subject buttonTitleAtIndex:index];
	STAssertEqualObjects(title,@"Cancel",@"the UIActionSheet adds a button with title %@",title);
	
	[_subject.bk_dynamicDelegate alertViewCancel:_subject];
	
	STAssertTrue(blockCalled, @"Block handler was not called.");
}

- (void)testDelegationBlocks {
	__block BOOL willShow = NO;
	__block BOOL didShow = NO;
	
	_subject.bk_willShowBlock = ^(UIAlertView *view) { willShow = YES; };
	_subject.bk_didShowBlock = ^(UIAlertView *view) { didShow = YES; };
	
	[_subject.bk_dynamicDelegate willPresentAlertView:_subject];
	[_subject.bk_dynamicDelegate didPresentAlertView:_subject];
	
	STAssertTrue(willShow, @"willShowBlock not fired.");
	STAssertTrue(didShow, @"didShowblock not fired.");
}

@end
