//
//  MFMailComposeViewControllerBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <SenTestingKit/SenTestingKit.h>
#import <BlocksKit/MFMailComposeViewController+BlocksKit.h>

@interface MFMailComposeViewControllerBlocksKitTest : SenTestCase <MFMailComposeViewControllerDelegate>

- (void)testCompletionBlock;

@end
