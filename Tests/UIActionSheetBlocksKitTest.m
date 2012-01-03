//
//  UIActionSheetBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "UIActionSheetBlocksKitTest.h"

@implementation UIActionSheetBlocksKitTest {
	UIActionSheet *_subject;
}

- (BOOL)shouldRunOnMainThread {
	return YES;
}

- (void)setUp {
	_subject = [[UIActionSheet alloc] initWithTitle:@"Hello BlocksKit"];
}

- (void)tearDown {
	[_subject release];
}

- (void)testInit {
	GHAssertTrue([_subject isKindOfClass:[UIActionSheet class]],@"subject is UIActionSheet");
	GHAssertNotEqualObjects(_subject.delegate,_subject.dynamicDelegate,@"the delegate is not the dynamic delegate");
	GHAssertEqualStrings(_subject.title,@"Hello BlocksKit",@"the UIActionSheet title is %@",_subject.title);
	GHAssertEquals(_subject.numberOfButtons,0,@"the action sheet has %d buttons",_subject.numberOfButtons);
	GHAssertFalse(_subject.isVisible,@"the action sheet is not visible");
}

- (void)testAddButtonWithHandler {
	__block NSInteger total = 0;

	NSInteger index1 = [_subject addButtonWithTitle:@"Button 1" handler:^{ total++; }];
	NSInteger index2 = [_subject addButtonWithTitle:@"Button 2" handler:^{ total += 2; }];
	
	GHAssertEquals(_subject.numberOfButtons,2,@"the action sheet has %d buttons",_subject.numberOfButtons);

	NSString *title = @"Button";
	title = [_subject buttonTitleAtIndex:index1];
	GHAssertEqualStrings(title,@"Button 1",@"the UIActionSheet adds a button with title %@",title);

	title = [_subject buttonTitleAtIndex:index2];
	GHAssertEqualStrings(title,@"Button 2",@"the UIActionSheet adds a button with title %@",title);
	
	[[_subject.dynamicDelegate realDelegate] actionSheet:_subject clickedButtonAtIndex:index1];
	[[_subject.dynamicDelegate realDelegate] actionSheet:_subject clickedButtonAtIndex:index2];
	
	GHAssertEquals(total, 3, @"Not all block handlers were called.");
}
 
- (void)testSetDestructiveButtonWithHandler {
	__block BOOL blockCalled = NO;
	
	NSInteger index = [_subject setDestructiveButtonWithTitle:@"Delete" handler:^{ blockCalled = YES; }];
	GHAssertEquals(_subject.numberOfButtons,1,@"the action sheet has %d buttons",_subject.numberOfButtons);
	GHAssertEquals(_subject.destructiveButtonIndex,index,@"the action sheet destructive button index is %d",_subject.destructiveButtonIndex);

	NSString *title = [_subject buttonTitleAtIndex:index];
	GHAssertEqualStrings(title,@"Delete",@"the UIActionSheet adds a button with title %@",title);
	
	[[_subject.dynamicDelegate realDelegate] actionSheet:_subject clickedButtonAtIndex:index];
	
	GHAssertTrue(blockCalled, @"Block handler was not called.");
}

- (void)testSetCancelButtonWithHandler {
	__block BOOL blockCalled = NO;
	
	NSInteger index = [_subject setCancelButtonWithTitle:@"Cancel" handler:^{ blockCalled = YES; }];
	GHAssertEquals(_subject.numberOfButtons,1,@"the action sheet has %d buttons",_subject.numberOfButtons);
	GHAssertEquals(_subject.cancelButtonIndex,index,@"the action sheet cancel button index is %d",_subject.cancelButtonIndex);

	NSString *title = [_subject buttonTitleAtIndex:index];
	GHAssertEqualStrings(title,@"Cancel",@"the UIActionSheet adds a button with title %@",title);
	
	[[_subject.dynamicDelegate realDelegate] actionSheetCancel:_subject];
	
	GHAssertTrue(blockCalled, @"Block handler was not called.");
}

- (void)testDelegationBlocks {
	__block BOOL willShow = NO;
	__block BOOL didShow = NO;
	
	_subject.willShowBlock = ^(UIActionSheet *sheet) { willShow = YES; };
	_subject.didShowBlock = ^(UIActionSheet *sheet) { didShow = YES; };
	
	[[_subject.dynamicDelegate realDelegate] willPresentActionSheet:_subject];
	[[_subject.dynamicDelegate realDelegate] didPresentActionSheet:_subject];
	
	GHAssertTrue(willShow, @"willShowBlock not fired.");
	GHAssertTrue(didShow, @"didShowblock not fired.");
}

@end
