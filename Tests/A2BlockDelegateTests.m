//
//  A2BlockDelegateTests.m
//  A2DynamicDelegate
//
//  Created by Zachary Waldowski on 6/5/12.
//  Copyright (c) 2012 Pandamonia LLC. All rights reserved.
//

#import "A2BlockDelegateTests.h"
#import <A2DynamicDelegate/A2BlockDelegate.h>
#import <A2DynamicDelegate/A2DynamicDelegate.h>

@implementation TestReturnObject (A2BlockDelegate)

@dynamic testReturnObjectBlock;

+ (void)load {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[self linkCategoryBlockProperty:@"testReturnObjectBlock" withDelegateMethod:@selector(testReturnObject)];
	[pool release];
}

@end

#pragma mark -

@implementation TestReturnStruct (A2BlockDelegate)

@dynamic testReturnStructBlock;

+ (void)load {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[self linkCategoryBlockProperty:@"testReturnStructBlock" withDelegateMethod:@selector(testReturnStruct)];
	[pool release];
}

@end

#pragma mark -

@implementation TestPassObject (A2BlockDelegate)

@dynamic testWithObjectBlock;

+ (void)load {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[self linkCategoryBlockProperty:@"testWithObjectBlock" withDelegateMethod:@selector(testWithObject:)];
	[pool release];
}

@end

#pragma mark -

@implementation TestPassChar (A2BlockDelegate)

@dynamic testWithCharBlock;

+ (void)load {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[self linkCategoryBlockProperty:@"testWithCharBlock" withDelegateMethod:@selector(testWithChar:)];
	[pool release];
}

@end

#pragma mark -

@implementation TestPassUChar (A2BlockDelegate)

@dynamic testWithUCharBlock;

+ (void)load {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[self linkCategoryBlockProperty:@"testWithUCharBlock" withDelegateMethod:@selector(testWithUChar:)];
	[pool release];
}

@end

#pragma mark -

@implementation TestPassShort (A2BlockDelegate)

@dynamic testWithShortBlock;

+ (void)load {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[self linkCategoryBlockProperty:@"testWithShortBlock" withDelegateMethod:@selector(testWithShort:)];
	[pool release];
}

@end

#pragma mark -

@implementation TestPassUShort (A2BlockDelegate)

@dynamic testWithUShortBlock;

+ (void)load {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[self linkCategoryBlockProperty:@"testWithUShortBlock" withDelegateMethod:@selector(testWithUShort:)];
	[pool release];
}

@end

#pragma mark -

@implementation TestPassInt (A2BlockDelegate)

@dynamic testWithIntBlock;

+ (void)load {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[self linkCategoryBlockProperty:@"testWithIntBlock" withDelegateMethod:@selector(testWithInt:)];
	[pool release];
}

@end

#pragma mark -

@implementation TestPassUInt (A2BlockDelegate)

@dynamic testWithUIntBlock;

+ (void)load {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[self linkCategoryBlockProperty:@"testWithUIntBlock" withDelegateMethod:@selector(testWithUInt:)];
	[pool release];
}

@end

#pragma mark -

@implementation TestPassLong (A2BlockDelegate)

@dynamic testWithLongBlock;

+ (void)load {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[self linkCategoryBlockProperty:@"testWithLongBlock" withDelegateMethod:@selector(testWithLong:)];
	[pool release];
}

@end

#pragma mark -

@implementation TestPassULong (A2BlockDelegate)

@dynamic testWithULongBlock;

+ (void)load {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[self linkCategoryBlockProperty:@"testWithULongBlock" withDelegateMethod:@selector(testWithULong:)];
	[pool release];
}

@end

#pragma mark -

@implementation TestPassLongLong (A2BlockDelegate)

@dynamic testWithLongLongBlock;

+ (void)load {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[self linkCategoryBlockProperty:@"testWithLongLongBlock" withDelegateMethod:@selector(testWithLongLong:)];
	[pool release];
}

@end

#pragma mark -

@implementation TestPassULongLong (A2BlockDelegate)

@dynamic testWithULongLongBlock;

+ (void)load {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[self linkCategoryBlockProperty:@"testWithULongLongBlock" withDelegateMethod:@selector(testWithULongLong:)];
	[pool release];
}

@end

#pragma mark -

@implementation TestPassFloat (A2BlockDelegate)

@dynamic testWithFloatBlock;

+ (void)load {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[self linkCategoryBlockProperty:@"testWithFloatBlock" withDelegateMethod:@selector(testWithFloat:)];
	[pool release];
}

@end

#pragma mark -=

@implementation TestPassDouble (A2BlockDelegate)

@dynamic testWithDoubleBlock;

+ (void)load {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[self linkCategoryBlockProperty:@"testWithDoubleBlock" withDelegateMethod:@selector(testWithDouble:)];
	[pool release];
}

@end

#pragma mark -

@implementation TestPassArray (A2BlockDelegate)

@dynamic testWithArrayBlock;

+ (void)load {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[self linkCategoryBlockProperty:@"testWithArrayBlock" withDelegateMethod:@selector(testWithArray:)];
	[pool release];
}

@end

#pragma mark -

@implementation TestPassStruct (A2BlockDelegate)

@dynamic testWithStructBlock;

+ (void)load {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[self linkCategoryBlockProperty:@"testWithStructBlock" withDelegateMethod:@selector(testPassStruct:)];
	[pool release];
}

@end

#pragma mark -

@implementation A2BlockDelegateTests

- (void)testReturnObject {
	TestReturnObject *obj = [TestReturnObject new];
	[obj setTestReturnObjectBlock:^NSString *{
		return @"Test";
	}];
	obj.delegate = obj.dynamicDelegate;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testReturnStruct {
	TestReturnStruct *obj = [TestReturnStruct new];
	[obj setTestReturnStructBlock:^MyStruct{
		MyStruct val;
		val.first = YES;
		val.second = YES;
		return val;
	}];
	obj.delegate = obj.dynamicDelegate;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassObject {
	TestPassObject *obj = [TestPassObject new];
	[obj setTestWithObjectBlock:^BOOL(NSString *str) {
		return !!str.length;
	}];
	obj.delegate = obj.dynamicDelegate;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassChar {
	TestPassChar *obj = [TestPassChar new];
	[obj setTestWithCharBlock:^BOOL(char chr) {
		return (chr == 'Z');
	}];
	obj.delegate = obj.dynamicDelegate;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassUChar {
	TestPassUChar *obj = [TestPassUChar new];
	[obj setTestWithUCharBlock:^BOOL(unsigned char uchr){
		return (uchr == 'Z');
	}];
	obj.delegate = obj.dynamicDelegate;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassShort {
	TestPassShort *obj = [TestPassShort new];
	[obj setTestWithShortBlock:^BOOL(short shrt){
		return (shrt == SHRT_MAX);
	}];
	obj.delegate = obj.dynamicDelegate;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassUShort {
	TestPassUShort *obj = [TestPassUShort new];
	[obj setTestWithUShortBlock:^BOOL(unsigned short ushrt) {
		return (ushrt == USHRT_MAX);
	}];
	obj.delegate = obj.dynamicDelegate;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassInt {
	TestPassInt *obj = [TestPassInt new];
	[obj setTestWithIntBlock:^BOOL(int inte) {
		return (inte == INT_MAX);
	}];
	obj.delegate = obj.dynamicDelegate;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassUInt {
	TestPassUInt *obj = [TestPassUInt new];
	[obj setTestWithUIntBlock:^BOOL(unsigned int uint) {
		return (uint == UINT_MAX);
	}];
	obj.delegate = obj.dynamicDelegate;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassLong {
	TestPassLong *obj = [TestPassLong new];
	[obj setTestWithLongBlock:^BOOL(long lng) {
		return (lng == LONG_MAX);
	}];
	obj.delegate = obj.dynamicDelegate;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassULong {
	TestPassULong *obj = [TestPassULong new];
	[obj setTestWithULongBlock:^BOOL(unsigned long lng) {
		return (lng == ULONG_MAX);
	}];
	obj.delegate = obj.dynamicDelegate;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassLongLong {
	TestPassLongLong *obj = [TestPassLongLong new];
	[obj setTestWithLongLongBlock:^BOOL(long long llng) {
		return (llng == LLONG_MAX);
	}];
	obj.delegate = obj.dynamicDelegate;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassULongLong {
	TestPassULongLong *obj = [TestPassULongLong new];
	[obj setTestWithULongLongBlock:^BOOL(unsigned long long lng) {
		return (lng == ULLONG_MAX);
	}];
	obj.delegate = obj.dynamicDelegate;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassFloat {
	TestPassFloat *obj = [TestPassFloat new];
	[obj setTestWithFloatBlock:^BOOL(float flt) {
		return (flt == 1.01f);
	}];
	obj.delegate = obj.dynamicDelegate;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassDouble {
	TestPassDouble *obj = [TestPassDouble new];
	[obj setTestWithDoubleBlock:^BOOL(double dbl) {
		return (dbl == 1.01);
	}];
	obj.delegate = obj.dynamicDelegate;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassArray {
	TestPassArray *obj = [TestPassArray new];
	[obj setTestWithArrayBlock:^BOOL(int *ary) {
		return ary[0] == 1 && ary[1] == 2 && ary[2] == 3 && ary[3] == 4 && ary[4] == 5;
	}];
	obj.delegate = obj.dynamicDelegate;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassStruct {
	TestPassStruct *obj = [TestPassStruct new];
	[obj setTestWithStructBlock:^BOOL(MyStruct stret) {
		return stret.first && stret.second;
	}];
	obj.delegate = obj.dynamicDelegate;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

@end
