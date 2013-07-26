//
//  UIActionSheetBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "UIActionSheetBlocksKitTest.h"
#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/A2DynamicDelegate.h>

@implementation UIActionSheetBlocksKitTest {
	UIActionSheet *_subject;
}

- (void)setUp {
	_subject = [[UIActionSheet alloc] bk_initWithTitle:@"Hello BlocksKit"];
}

- (void)testInit {
	STAssertTrue([_subject isKindOfClass:[UIActionSheet class]],@"subject is UIActionSheet");
	STAssertFalse([_subject.delegate isEqual:_subject.bk_dynamicDelegate], @"the delegate is not the dynamic delegate");
	STAssertEqualObjects(_subject.title,@"Hello BlocksKit",@"the UIActionSheet title is %@",_subject.title);
	STAssertEquals(_subject.numberOfButtons,0,@"the action sheet has %d buttons",_subject.numberOfButtons);
	STAssertFalse(_subject.isVisible,@"the action sheet is not visible");
}

- (void)testAddButtonWithHandler {
	__block NSInteger total = 0;

	NSInteger index1 = [_subject bk_addButtonWithTitle:@"Button 1" handler:^{ total++; }];
	NSInteger index2 = [_subject bk_addButtonWithTitle:@"Button 2" handler:^{ total += 2; }];
	
	STAssertEquals(_subject.numberOfButtons,2,@"the action sheet has %d buttons",_subject.numberOfButtons);

	NSString *title = @"Button";
	title = [_subject buttonTitleAtIndex:index1];
	STAssertEqualObjects(title,@"Button 1",@"the UIActionSheet adds a button with title %@",title);

	title = [_subject buttonTitleAtIndex:index2];
	STAssertEqualObjects(title,@"Button 2",@"the UIActionSheet adds a button with title %@",title);
	
	[_subject.bk_dynamicDelegate actionSheet:_subject clickedButtonAtIndex:index1];
	[_subject.bk_dynamicDelegate actionSheet:_subject clickedButtonAtIndex:index2];
	
	STAssertEquals(total, 3, @"Not all block handlers were called.");
}
 
- (void)testSetDestructiveButtonWithHandler {
	__block BOOL blockCalled = NO;
	
	NSInteger index = [_subject bk_setDestructiveButtonWithTitle:@"Delete" handler:^{ blockCalled = YES; }];
	STAssertEquals(_subject.numberOfButtons,1,@"the action sheet has %d buttons",_subject.numberOfButtons);
	STAssertEquals(_subject.destructiveButtonIndex,index,@"the action sheet destructive button index is %d",_subject.destructiveButtonIndex);

	NSString *title = [_subject buttonTitleAtIndex:index];
	STAssertEqualObjects(title,@"Delete",@"the UIActionSheet adds a button with title %@",title);
	
	[_subject.bk_dynamicDelegate actionSheet:_subject clickedButtonAtIndex:index];

	STAssertTrue(blockCalled, @"Block handler was not called.");
}

- (void)testSetCancelButtonWithHandler {
	__block BOOL blockCalled = NO;
	
	NSInteger index = [_subject bk_setCancelButtonWithTitle:@"Cancel" handler:^{ blockCalled = YES; }];
	STAssertEquals(_subject.numberOfButtons,1,@"the action sheet has %d buttons",_subject.numberOfButtons);
	STAssertEquals(_subject.cancelButtonIndex,index,@"the action sheet cancel button index is %d",_subject.cancelButtonIndex);

	NSString *title = [_subject buttonTitleAtIndex:index];
	STAssertEqualObjects(title,@"Cancel",@"the UIActionSheet adds a button with title %@",title);
	
	[_subject.bk_dynamicDelegate actionSheetCancel:_subject];
	
	STAssertTrue(blockCalled, @"Block handler was not called.");
}

- (void)testDelegationBlocks {
	__block BOOL willShow = NO;
	__block BOOL didShow = NO;
	
	_subject.bk_willShowBlock = ^(UIActionSheet *sheet) { willShow = YES; };
	_subject.bk_didShowBlock = ^(UIActionSheet *sheet) { didShow = YES; };
	
	[_subject.bk_dynamicDelegate willPresentActionSheet:_subject];
	[_subject.bk_dynamicDelegate didPresentActionSheet:_subject];
	
	STAssertTrue(willShow, @"willShowBlock not fired.");
	STAssertTrue(didShow, @"didShowblock not fired.");
}

@end
