//
//  A2BlockInvocationTests.h
//  BlocksKit Unit Tests
//

#import <SenTestingKit/SenTestingKit.h>
#import <BlocksKit/A2BlockInvocation.h>

@interface A2BlockInvocationTests : SenTestCase

- (void)testVoidBlockInvocation;
- (void)testReturnObjectBlockInvocation;
- (void)testReturnStructBlockInvocation;
- (void)testPassObjectBlockInvocation;
- (void)testPassCharBlockInvocation;
- (void)testPassUCharBlockInvocation;
- (void)testPassShortBlockInvocation;
- (void)testPassUShortBlockInvocation;
- (void)testPassIntBlockInvocation;
- (void)testPassUIntBlockInvocation;
- (void)testPassLongBlockInvocation;
- (void)testPassULongBlockInvocation;
- (void)testPassLongLongBlockInvocation;
- (void)testPassULongLongBlockInvocation;
- (void)testPassFloatBlockInvocation;
- (void)testPassDoubleBlockInvocation;
- (void)testPassArrayBlockInvocation;
- (void)testPassStructBlockInvocation;

@end
