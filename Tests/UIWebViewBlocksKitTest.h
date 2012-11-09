//
//  UIWebViewBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <SenTestingKit/SenTestingKit.h>
#import <BlocksKit/UIWebView+BlocksKit.h>

@interface UIWebViewBlocksKitTest : SenTestCase <UIWebViewDelegate>

- (void)testShouldStartLoad;
- (void)testDidStartLoad;
- (void)testDidFinishLoad;
- (void)testDidFinishWithError;

@end
