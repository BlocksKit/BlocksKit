//
//  MFMailComposeViewControllerBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <GHUnitIOS/GHUnit.h>
#import "BlocksKit/BlocksKit.h"

@interface MFMailComposeViewControllerBlocksKitTest : GHTestCase

@property (nonatomic, retain) MFMailComposeViewController *subject;

- (void)testCompletionBlock;

@end
