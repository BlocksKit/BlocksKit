//
//  UIActionSheetBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "UIActionSheetBlocksKitTest.h"


@implementation UIActionSheetBlocksKitTest
@synthesize subject=_subject;

- (BOOL)shouldRunOnMainThread {
  // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
  return NO;
}

- (void)setUpClass {
    // Run at start of all tests in the class
}

- (void)tearDownClass {
    // Run at end of all tests in the class
}

- (void)setUp {
    // Run before each test method
    self.subject = [UIActionSheet actionSheetWithTitle:@"Hello BlocksKit"];
}

- (void)tearDown {
    // Run after each test method
}


- (void)testInit {
    GHAssertTrue([self.subject isKindOfClass:[UIActionSheet class]],@"subject is UIActionSheet");
    GHAssertEqualObjects(self.subject.delegate,self.subject,@"the delegate is itself");
    GHAssertEqualStrings(self.subject.title,@"Hello BlocksKit",@"the UIActionSheet title is %@",self.subject.title);
    GHAssertEquals(self.subject.numberOfButtons,0,@"the action sheet has %d buttons",self.subject.numberOfButtons);
    GHAssertFalse(self.subject.isVisible,@"the action sheet is not visible");
}

//TODO trigger the block
- (void)testAddButtonWithHandler {
    BKBlock block = ^(void) {
    };
    NSInteger index1 = [self.subject addButtonWithTitle:@"Button 1" handler:block];
    NSInteger index2 = [self.subject addButtonWithTitle:@"Button 2" handler:block];
    GHAssertEquals(self.subject.numberOfButtons,2,@"the action sheet has %d buttons",self.subject.numberOfButtons);

    NSString *title = @"Button";
    title = [self.subject buttonTitleAtIndex:index1];
    GHAssertEqualStrings(title,@"Button 1",@"the UIActionSheet adds a button with title %@",title);

    title = [self.subject buttonTitleAtIndex:index2];
    GHAssertEqualStrings(title,@"Button 2",@"the UIActionSheet adds a button with title %@",title);
}
 
//TODO trigger the block
- (void)testSetDestructiveButtonWithHandler {
    BKBlock block = ^(void) {
    };
    NSInteger index = [self.subject setDestructiveButtonWithTitle:@"Delete" handler:block];
    GHAssertEquals(self.subject.numberOfButtons,1,@"the action sheet has %d buttons",self.subject.numberOfButtons);
    GHAssertEquals(self.subject.destructiveButtonIndex,index,@"the action sheet destructive button index is %d",self.subject.destructiveButtonIndex);

    NSString *title = [self.subject buttonTitleAtIndex:index];
    GHAssertEqualStrings(title,@"Delete",@"the UIActionSheet adds a button with title %@",title);
}

//TODO trigger the block
- (void)testSetCancelButtonWithHandler {
    BKBlock block = ^(void) {
    };
    NSInteger index = [self.subject setCancelButtonWithTitle:@"Cancel" handler:block];
    GHAssertEquals(self.subject.numberOfButtons,1,@"the action sheet has %d buttons",self.subject.numberOfButtons);
    GHAssertEquals(self.subject.cancelButtonIndex,index,@"the action sheet cancel button index is %d",self.subject.cancelButtonIndex);

    NSString *title = [self.subject buttonTitleAtIndex:index];
    GHAssertEqualStrings(title,@"Cancel",@"the UIActionSheet adds a button with title %@",title);
}

//TODO trigger the block
- (void)testDelegationBlocks {
    self.subject.willShowBlock = ^(UIActionSheet *sheet) {
    };
    self.subject.didShowBlock = ^(UIActionSheet *sheet) {
    };
}

@end
