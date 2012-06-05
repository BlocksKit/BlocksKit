//
//  A2BlockClosureTests.m
//  A2DynamicDelegate
//
//  Created by Zachary Waldowski on 6/5/12.
//  Copyright (c) 2012 Pandamonia LLC. All rights reserved.
//

#import "A2BlockClosureTests.h"
#import "A2BlockClosure.h"

@implementation A2BlockClosureTests

- (void)testBlock
{
	BOOL(^block)(void) = ^BOOL{
		return YES;
	};
	NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"c@:"];
	A2BlockClosure *closure = [[A2BlockClosure alloc] initWithBlock: block methodSignature: signature];
	STAssertNotNil(closure, @"Could not init closure");
	STAssertNotNil(closure.block, @"Closure couldn't get block");
	BOOL(^blockPull)(void) = closure.block;
	BOOL result = blockPull();
	STAssertTrue(result, @"Block not run");
}

- (void)testBlockWithArguments
{
	BOOL(^block)(int, NSString *) = ^BOOL(int val, NSString *str){
		return (val == 42 && [str isEqualToString:@"Test"]);
	};
	NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"c@:i@"];
	A2BlockClosure *closure = [[A2BlockClosure alloc] initWithBlock: block methodSignature: signature];
	STAssertNotNil(closure, @"Could not init closure");
	STAssertNotNil(closure.block, @"Closure couldn't get block");
	BOOL(^blockPull)(int, NSString *) = closure.block;
	BOOL result = blockPull(42, @"Test");
	STAssertTrue(result, @"Block not run");
}

- (void)testFunctionInterface
{
	BOOL(^block)(void) = ^BOOL{
		return YES;
	};
	NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"c@:"];
	A2BlockClosure *closure = [[A2BlockClosure alloc] initWithBlock: block methodSignature: signature];
	STAssertNotNil(closure, @"Could not init closure");
	STAssertNotNil(closure.functionPointer, @"Closure couldn't get function interface");
	IMP interface = closure.functionPointer;
	BOOL result = (BOOL)interface(self, NULL);
	STAssertTrue(result, @"Block not run");
}

- (void)testFunctionInterfaceWithArguments
{
	BOOL(^block)(int, NSString *) = ^BOOL(int val, NSString *str){
		return (val == 42 && [str isEqualToString:@"Test"]);
	};
	NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"c@:i@"];
	A2BlockClosure *closure = [[A2BlockClosure alloc] initWithBlock: block methodSignature: signature];
	STAssertNotNil(closure, @"Could not init closure");
	STAssertNotNil(closure.functionPointer, @"Closure couldn't get function interface");
	IMP interface = closure.functionPointer;
	BOOL result = (BOOL)interface(self, NULL, 42, @"Test");
	STAssertTrue(result, @"Block not run");
}

@end
