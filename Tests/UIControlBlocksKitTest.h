//
//  UIControlBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <SenTestingKit/SenTestingKit.h>
#import <BlocksKit/UIControl+BlocksKit.h>

@interface UIControlBlocksKitTest : SenTestCase

- (void)testHasEventHandler;
- (void)testInvokeEventHandler;
- (void)testRemoveEventHandler;

@end
