//
//  MFMessageComposeViewControllerBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <SenTestingKit/SenTestingKit.h>
#import <BlocksKit/MFMessageComposeViewController+BlocksKit.h>

@interface MFMessageComposeViewControllerBlocksKitTest : SenTestCase <MFMessageComposeViewControllerDelegate>

- (void)testCompletionBlock;

@end
