//
//  A2BlockInvocationTests.h
//  A2DynamicDelegate
//
//  Created by Zachary Waldowski on 6/5/12.
//  Copyright (c) 2012 Pandamonia LLC. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

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
