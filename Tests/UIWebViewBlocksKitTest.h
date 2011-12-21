//
//  UIWebViewBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <GHUnitIOS/GHUnit.h>
#import "BlocksKit/BlocksKit.h"

@interface UIWebViewBlocksKitTest : GHTestCase <UIWebViewDelegate>

- (void)testShouldStartLoad;
- (void)testDidStartLoad;
- (void)testDidFinishLoad;
- (void)testDidFinishWithError;

@end
