//
//  UIAlertViewBlocksKitTest.m
//  BlocksKit
//
//  Created by Zachary Waldowski on 12/20/11.
//  Copyright (c) 2011 Dizzy Technology. All rights reserved.
//

#import "UIAlertViewBlocksKitTest.h"

@implementation UIAlertViewBlocksKitTest {
	UIAlertView *_subject;
}

- (BOOL)shouldRunOnMainThread {
	return YES;
}

- (void)setUp {
	_subject = [[UIAlertView alloc] initWithTitle:@"Hello BlocksKit" message:@"This is a message."];
}

- (void)tearDown {
	[_subject release];
}

- (void)testInit {
	GHAssertTrue([_subject isKindOfClass:[UIAlertView class]],@"subject is UIAlertView");
	GHAssertEqualObjects(_subject.delegate,_subject.dynamicDelegate,@"the delegate is dynamic");
	GHAssertEqualStrings(_subject.title,@"Hello BlocksKit",@"the UIAlertView title is %@",_subject.title);
	GHAssertEquals(_subject.numberOfButtons,0,@"the action sheet has %d buttons",_subject.numberOfButtons);
	GHAssertFalse(_subject.isVisible,@"the action sheet is not visible");
}

- (void)testAddButtonWithHandler {
	__block NSInteger total = 0;
	
	NSInteger index1 = [_subject addButtonWithTitle:@"Button 1" handler:^{ total++; }];
	NSInteger index2 = [_subject addButtonWithTitle:@"Button 2" handler:^{ total += 2; }];
	
	GHAssertEquals(_subject.numberOfButtons,2,@"the alert view has %d buttons",_subject.numberOfButtons);
	
	NSString *title = @"Button";
	title = [_subject buttonTitleAtIndex:index1];
	GHAssertEqualStrings(title,@"Button 1",@"the UIActionSheet adds a button with title %@",title);
	
	title = [_subject buttonTitleAtIndex:index2];
	GHAssertEqualStrings(title,@"Button 2",@"the UIActionSheet adds a button with title %@",title);
	
	[_subject.delegate alertView:_subject clickedButtonAtIndex:index1];
	[_subject.delegate alertView:_subject clickedButtonAtIndex:index2];
	
	GHAssertEquals(total, 3, @"Not all block handlers were called.");
}

- (void)testSetCancelButtonWithHandler {
	__block BOOL blockCalled = NO;
	
	NSInteger index = [_subject setCancelButtonWithTitle:@"Cancel" handler:^{ blockCalled = YES; }];
	GHAssertEquals(_subject.numberOfButtons,1,@"the alert view has %d buttons",_subject.numberOfButtons);
	GHAssertEquals(_subject.cancelButtonIndex,index,@"the alert view cancel button index is %d",_subject.cancelButtonIndex);
	
	NSString *title = [_subject buttonTitleAtIndex:index];
	GHAssertEqualStrings(title,@"Cancel",@"the UIActionSheet adds a button with title %@",title);
	
	[_subject.delegate alertViewCancel:_subject];
	
	GHAssertTrue(blockCalled, @"Block handler was not called.");
}

- (void)testDelegationBlocks {
	__block BOOL willShow = NO;
	__block BOOL didShow = NO;
	
	_subject.willShowBlock = ^(UIAlertView *view) { willShow = YES; };
	_subject.didShowBlock = ^(UIAlertView *view) { didShow = YES; };
	
	[_subject.delegate willPresentAlertView:_subject];
	[_subject.delegate didPresentAlertView:_subject];
	
	GHAssertTrue(willShow, @"willShowBlock not fired.");
	GHAssertTrue(didShow, @"didShowblock not fired.");
}

@end
