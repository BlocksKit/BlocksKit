//
//  MFMailComposeViewControllerBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <SenTestingKit/SenTestingKit.h>
#import <MessageUI/MessageUI.h>

@interface MFMailComposeViewControllerBlocksKitTest : SenTestCase <MFMailComposeViewControllerDelegate>

- (void)testCompletionBlock;

@end
