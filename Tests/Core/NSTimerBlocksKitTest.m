//
//  NSTimerBlocksKitTest.m
//  BlocksKit Unit Tests
//
//  Contributed by Kai Wu.
//

@import XCTest;
@import BlocksKit;

static const NSTimeInterval BKTimerTestLeniency = 10;
static const NSTimeInterval BKTimerTestInterval = 0.025;

static inline NSTimeInterval Timeout(NSInteger count) {
    return count * BKTimerTestLeniency * BKTimerTestInterval;
}

@interface NSTimerBlocksKitTest : XCTestCase

@end

@implementation NSTimerBlocksKitTest

- (void)commonTestTimerRepeating:(BOOL)repeats expectation:(NSInteger)count
{
    NSString *description = [NSString stringWithFormat:@"Timer x%ld", (long)count];
    XCTestExpectation *expectation = [self expectationWithDescription:description];
    const NSTimeInterval timeout = Timeout(count);
    __block NSInteger total = 0;

    NSTimer *timer = [NSTimer bk_scheduleTimerWithTimeInterval:BKTimerTestInterval repeats:repeats usingBlock:^(NSTimer *timer) {
        if (++total >= count) {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *__unused err) {
        [timer invalidate];
        XCTAssertEqual(total, count);
    }];
}

- (void)testTimer {
    [self commonTestTimerRepeating:NO expectation:1];
}

- (void)testRepeatedTimer {
    [self commonTestTimerRepeating:YES expectation:5];
}

@end
