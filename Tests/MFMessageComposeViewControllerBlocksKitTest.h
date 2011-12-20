//
//  MFMessageComposeViewControllerBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <GHUnitIOS/GHUnit.h>
#import "BlocksKit/BlocksKit.h"

@interface MFMessageComposeViewControllerBlocksKitTest : GHTestCase

@property (nonatomic, retain) MFMessageComposeViewController *subject;

- (void)testCompletionBlock;

@end
