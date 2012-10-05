//
//  UIControlBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <SenTestingKit/SenTestingKit.h>
#import <BlocksKit/UIControl+BlocksKit.h>

@interface UIControlBlocksKitTest : SenTestCase

- (void)testAddEventHandler;
- (void)testHasEventHandler;
- (void)testRemoveEventHandler;

@end
