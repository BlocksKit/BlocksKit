//
//  NSNumberBlocksKitTest.m
//  BlocksKit Unit Tests
//
//  Contributed by Kai Wu.
//

#import <XCTest/XCTest.h>
#import <BlocksKit/NSNumber+BlocksKit.h>

@interface NSNumberBlocksKitTest : XCTestCase

@end

@implementation NSNumberBlocksKitTest {
  NSNumber *_subject;
  NSInteger _total;
}

- (void)setUp {
  _subject = @(6);
  _total = 0;
}

- (void)tearDown {
}

- (void)testEach {
  void (^senderBlock)() = ^{
    _total += 1;
  };
  [_subject bk_times:senderBlock];
  XCTAssertEqual(_total, (NSInteger)6, @"total value of 6 is %ld", (long)_total);
}

@end
