//
//  UIActionSheetBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "UIActionSheetBlocksKitTest.h"

@implementation UIActionSheetBlocksKitTest

@synthesize subject;

- (void)setUp {
	self.subject = [UIActionSheet actionSheetWithTitle:@"Hello BlocksKit"];
}

- (void)tearDown {
	self.subject = nil;
}

- (void)testInit {
	GHAssertTrue([self.subject isKindOfClass:[UIActionSheet class]],@"subject is UIActionSheet");
	GHAssertEqualObjects(self.subject.delegate,self.subject.dynamicDelegate,@"the delegate is the dynamice delegate");
	GHAssertEqualStrings(self.subject.title,@"Hello BlocksKit",@"the UIActionSheet title is %@",self.subject.title);
	GHAssertEquals(self.subject.numberOfButtons,0,@"the action sheet has %d buttons",self.subject.numberOfButtons);
	GHAssertFalse(self.subject.isVisible,@"the action sheet is not visible");
}

- (void)testAddButtonWithHandler {
	__block NSUInteger total = 0;

	NSInteger index1 = [self.subject addButtonWithTitle:@"Button 1" handler:^{ total++; }];
	NSInteger index2 = [self.subject addButtonWithTitle:@"Button 2" handler:^{ total += 2; }];
	
	GHAssertEquals(self.subject.numberOfButtons,2,@"the action sheet has %d buttons",self.subject.numberOfButtons);

	NSString *title = @"Button";
	title = [self.subject buttonTitleAtIndex:index1];
	GHAssertEqualStrings(title,@"Button 1",@"the UIActionSheet adds a button with title %@",title);

	title = [self.subject buttonTitleAtIndex:index2];
	GHAssertEqualStrings(title,@"Button 2",@"the UIActionSheet adds a button with title %@",title);
	
	[self.subject.delegate actionSheet:self.subject clickedButtonAtIndex:index1];
	[self.subject.delegate actionSheet:self.subject clickedButtonAtIndex:index2];
	
	GHAssertEquals(total, 3, @"Not all block handlers were called.");
}
 
- (void)testSetDestructiveButtonWithHandler {
	__block BOOL blockCalled = NO;
	
	NSInteger index = [self.subject setDestructiveButtonWithTitle:@"Delete" handler:^{ blockCalled = YES; }];
	GHAssertEquals(self.subject.numberOfButtons,1,@"the action sheet has %d buttons",self.subject.numberOfButtons);
	GHAssertEquals(self.subject.destructiveButtonIndex,index,@"the action sheet destructive button index is %d",self.subject.destructiveButtonIndex);

	NSString *title = [self.subject buttonTitleAtIndex:index];
	GHAssertEqualStrings(title,@"Delete",@"the UIActionSheet adds a button with title %@",title);
	
	[self.subject.delegate actionSheet:self.subject clickedButtonAtIndex:index];
	
	GHAssertTrue(blockCalled, @"Block handler was not called.");
}

- (void)testSetCancelButtonWithHandler {
	__block BOOL blockCalled = NO;
	
	NSInteger index = [self.subject setCancelButtonWithTitle:@"Cancel" handler:^{ blockCalled = YES; }];
	GHAssertEquals(self.subject.numberOfButtons,1,@"the action sheet has %d buttons",self.subject.numberOfButtons);
	GHAssertEquals(self.subject.cancelButtonIndex,index,@"the action sheet cancel button index is %d",self.subject.cancelButtonIndex);

	NSString *title = [self.subject buttonTitleAtIndex:index];
	GHAssertEqualStrings(title,@"Cancel",@"the UIActionSheet adds a button with title %@",title);
	
	[self.subject.delegate actionSheet:self.subject clickedButtonAtIndex:index];
	
	GHAssertTrue(blockCalled, @"Block handler was not called.");
}

- (void)testDelegationBlocks {
	__block BOOL willShow = NO;
	__block BOOL didShow = NO;
	
	self.subject.willShowBlock = ^(UIActionSheet *sheet) { willShow = YES; };
	self.subject.didShowBlock = ^(UIActionSheet *sheet) { didShow = YES; };
	
	[self.subject.delegate willPresentActionSheet:self.subject];
	[self.subject.delegate didPresentActionSheet:self.subject];
	
	GHAssertTrue(willShow, @"willShowBlock not fired.");
	GHAssertTrue(didShow, @"didShowblock not fired.");
}

@end
