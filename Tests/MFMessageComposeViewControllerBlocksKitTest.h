//
//  MFMessageComposeViewControllerBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <SenTestingKit/SenTestingKit.h>
#import <MessageUI/MessageUI.h>

@interface MFMessageComposeViewControllerBlocksKitTest : SenTestCase <MFMessageComposeViewControllerDelegate>

- (void)testCompletionBlock;

@end
