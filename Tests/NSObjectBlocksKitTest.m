//
//  NSObjectBlocksKitTest.m
//  BlocksKit Unit Tests
//
//  Contributed by Kai Wu.
//

#import <XCTest/XCTest.h>
#import <BlocksKit/NSObject+BKBlockExecution.h>

static const NSTimeInterval BKObjectTestInterval = 0.025;
static const NSTimeInterval BKObjectTestTimeout = 1.0;

static const void *BKObjectTestIsOnQueueKey = &BKObjectTestIsOnQueueKey;
NS_INLINE BOOL BKObjectTestIsOnQueue(void) {
    return dispatch_get_specific(BKObjectTestIsOnQueueKey) != NULL;
}

NS_INLINE BOOL BKObjectTestIsOnMainQueue(void) {
    return NSThread.isMainThread;
}

NS_INLINE BOOL BKObjectTestIsOnGlobalQueue(void) {
    return !BKObjectTestIsOnQueue() && !BKObjectTestIsOnMainQueue();
}

@interface NSObjectBlocksKitTest : XCTestCase {
    dispatch_queue_t _queue;
}

@end

@implementation NSObjectBlocksKitTest

- (void)setUp
{
    _queue = dispatch_queue_create(NSStringFromClass(self.class).UTF8String, 0);
    dispatch_queue_set_specific(_queue, BKObjectTestIsOnQueueKey, (__bridge void *)self, NULL);
}

- (void)tearDown
{
    _queue = nil;
}

- (void)testInstancePerformBlockAfterDelay {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Perform sender block after delay"];
    id<NSObject,NSCopying> token = [self bk_performBlock:^(id sender) {
        [expectation fulfill];

        XCTAssertNotNil(sender);
        XCTAssertTrue(BKObjectTestIsOnMainQueue());
    } afterDelay:BKObjectTestInterval];

    XCTAssertNotNil(token);

    [self waitForExpectationsWithTimeout:BKObjectTestTimeout handler:NULL];
}

- (void)testPerformBlockAfterDelay {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Perform block after delay"];
    id<NSObject,NSCopying> token = [NSObject bk_performBlock:^{
        [expectation fulfill];
        XCTAssertTrue(BKObjectTestIsOnMainQueue());
    } afterDelay:BKObjectTestInterval];

    XCTAssertNotNil(token);

    [self waitForExpectationsWithTimeout:BKObjectTestTimeout handler:NULL];
}

- (void)testInstancePerformBlockOnQueueAfterDelay {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Perform block after delay"];
    id<NSObject,NSCopying> token = [self bk_performBlock:^(id sender){
        [expectation fulfill];

        XCTAssertNotNil(sender);
        XCTAssertTrue(BKObjectTestIsOnQueue());
    } onQueue:_queue afterDelay:BKObjectTestInterval];

    XCTAssertNotNil(token);

    [self waitForExpectationsWithTimeout:BKObjectTestTimeout handler:NULL];
}

- (void)testPerformBlockOnQueueAfterDelay {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Perform block after delay"];
    id<NSObject,NSCopying> token = [NSObject bk_performBlock:^{
        [expectation fulfill];
        XCTAssertTrue(BKObjectTestIsOnQueue());
    } onQueue:_queue afterDelay:BKObjectTestInterval];

    XCTAssertNotNil(token);

    [self waitForExpectationsWithTimeout:BKObjectTestTimeout handler:NULL];
}

- (void)testPerformBlockInBackgroundAfterDelay {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Perform block after delay"];
    id<NSObject,NSCopying> token = [NSObject bk_performBlockInBackground:^{
        [expectation fulfill];
        XCTAssertTrue(BKObjectTestIsOnGlobalQueue());
    } afterDelay:BKObjectTestInterval];

    XCTAssertNotNil(token);

    [self waitForExpectationsWithTimeout:BKObjectTestTimeout handler:NULL];
}

- (void)testInstancePerformBlockInBackgroundAfterDelay {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Perform block after delay"];
    id<NSObject,NSCopying> token = [self bk_performBlockInBackground:^(id sender){
        [expectation fulfill];
        XCTAssertTrue(BKObjectTestIsOnGlobalQueue());
    } afterDelay:BKObjectTestInterval];

    XCTAssertNotNil(token);

    [self waitForExpectationsWithTimeout:BKObjectTestTimeout handler:NULL];
}

- (void)testCancelPerformBlock {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Cancel performed block"];
    id<NSObject,NSCopying> token = [NSObject bk_performBlock:^{
        XCTFail();
    } onQueue:_queue afterDelay:BKObjectTestInterval];

    XCTAssertNotNil(token);
    [NSObject bk_cancelBlock:token];

    [NSObject bk_performBlock:^{
        [expectation fulfill];
    } afterDelay:BKObjectTestInterval];

    [self waitForExpectationsWithTimeout:BKObjectTestTimeout handler:NULL];
}

@end
