//
//  NSObjectBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "NSObjectBlocksKitTest.h"


@implementation NSObjectBlocksKitTest

@synthesize subject=_subject;

- (void)dealloc {
    [_subject release];
    [super dealloc];
}

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
    self.subject = [NSMutableString stringWithString:@"Hello "];
}

- (void)tearDown {
  // Run after each test method
}  

- (void)testPerformBlockAfterDelay {
    BKSenderBlock senderBlock = ^(id sender) {
        [[(NSObjectBlocksKitTest *)sender subject] appendString:@"BlocksKit"];
        [(NSObjectBlocksKitTest *)sender notify:kGHUnitWaitStatusSuccess forSelector:@selector(testPerformBlockAfterDelay)];
    };
    [self prepare];
    id block = [self performBlock:senderBlock afterDelay:0.5];
    GHAssertNotNil(block,@"block is nil");
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
    GHAssertEqualStrings(self.subject,@"Hello BlocksKit",@"subject string is %@",self.subject);
}

- (void)testClassPerformBlockAfterDelay {
    __block NSObjectBlocksKitTest *test = self;
    __block NSMutableString *subject = [NSMutableString stringWithString:@"Hello "];
    BKBlock block = ^(void) {
        [subject appendString:@"BlocksKit"];
        [test notify:kGHUnitWaitStatusSuccess forSelector:@selector(testClassPerformBlockAfterDelay)];
    };
    [self prepare];
    id blk = [NSObject performBlock:block afterDelay:0.5];
    GHAssertNotNil(blk,@"block is nil");
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
    GHAssertEqualStrings(subject,@"Hello BlocksKit",@"subject string is %@",subject);
}

- (void)testCancel {
    BKSenderBlock senderBlock = ^(id sender) {
        [[(NSObjectBlocksKitTest *)sender subject] appendString:@"BlocksKit"];
        [(NSObjectBlocksKitTest *)sender notify:kGHUnitWaitStatusSuccess forSelector:@selector(testCancel)];
    };
    [self prepare];
    id block = [self performBlock:senderBlock afterDelay:0.1];
    GHAssertNotNil(block,@"block is nil");
    [NSObject cancelBlock:block];
    //block is cancelled
    [self waitForTimeout:0.5];
    GHAssertEqualStrings(self.subject,@"Hello ",@"subject string is %@",self.subject);
}

@end
