//
//  A2BlockDelegateTests.m
//  BlocksKit Unit Tests
//

#import <XCTest/XCTest.h>
#import <BlocksKit/A2DynamicDelegate.h>
#import "A2DynamicTestClasses+A2BlockDelegate.h"

@interface A2BlockDelegateTests : XCTestCase

@end

@implementation A2BlockDelegateTests

- (void)testReturnObject {
	TestReturnObject *obj = [TestReturnObject new];
	[obj setTestReturnObjectBlock:^NSString *{
		return @"Test";
	}];
	obj.delegate = obj.bk_dynamicDelegate;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testReturnStruct {
	TestReturnStruct *obj = [TestReturnStruct new];
	[obj setTestReturnStructBlock:^MyStruct{
		MyStruct val;
		val.first = YES;
		val.second = YES;
		return val;
	}];
	obj.delegate = obj.bk_dynamicDelegate;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassObject {
	TestPassObject *obj = [TestPassObject new];
	[obj setTestWithObjectBlock:^BOOL(NSString *str) {
		return !!str.length;
	}];
	obj.delegate = obj.bk_dynamicDelegate;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassChar {
	TestPassChar *obj = [TestPassChar new];
	[obj setTestWithCharBlock:^BOOL(char chr) {
		return (chr == 'Z');
	}];
	obj.delegate = obj.bk_dynamicDelegate;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassUChar {
	TestPassUChar *obj = [TestPassUChar new];
	[obj setTestWithUCharBlock:^BOOL(unsigned char uchr) {
		return (uchr == 'Z');
	}];
	obj.delegate = obj.bk_dynamicDelegate;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassShort {
	TestPassShort *obj = [TestPassShort new];
	[obj setTestWithShortBlock:^BOOL(short shrt) {
		return (shrt == SHRT_MAX);
	}];
	obj.delegate = obj.bk_dynamicDelegate;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassUShort {
	TestPassUShort *obj = [TestPassUShort new];
	[obj setTestWithUShortBlock:^BOOL(unsigned short ushrt) {
		return (ushrt == USHRT_MAX);
	}];
	obj.delegate = obj.bk_dynamicDelegate;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassInt {
	TestPassInt *obj = [TestPassInt new];
	[obj setTestWithIntBlock:^BOOL(int inte) {
		return (inte == INT_MAX);
	}];
	obj.delegate = obj.bk_dynamicDelegate;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassUInt {
	TestPassUInt *obj = [TestPassUInt new];
	[obj setTestWithUIntBlock:^BOOL(unsigned int uint) {
		return (uint == UINT_MAX);
	}];
	obj.delegate = obj.bk_dynamicDelegate;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassLong {
	TestPassLong *obj = [TestPassLong new];
	[obj setTestWithLongBlock:^BOOL(long lng) {
		return (lng == LONG_MAX);
	}];
	obj.delegate = obj.bk_dynamicDelegate;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassULong {
	TestPassULong *obj = [TestPassULong new];
	[obj setTestWithULongBlock:^BOOL(unsigned long lng) {
		return (lng == ULONG_MAX);
	}];
	obj.delegate = obj.bk_dynamicDelegate;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassLongLong {
	TestPassLongLong *obj = [TestPassLongLong new];
	[obj setTestWithLongLongBlock:^BOOL(long long llng) {
		return (llng == LLONG_MAX);
	}];
	obj.delegate = obj.bk_dynamicDelegate;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassULongLong {
	TestPassULongLong *obj = [TestPassULongLong new];
	[obj setTestWithULongLongBlock:^BOOL(unsigned long long lng) {
		return (lng == ULLONG_MAX);
	}];
	obj.delegate = obj.bk_dynamicDelegate;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassFloat {
	TestPassFloat *obj = [TestPassFloat new];
	[obj setTestWithFloatBlock:^BOOL(float flt) {
		return (flt == 1.01f);
	}];
	obj.delegate = obj.bk_dynamicDelegate;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassDouble {
	TestPassDouble *obj = [TestPassDouble new];
	[obj setTestWithDoubleBlock:^BOOL(double dbl) {
		return (dbl == 1.01);
	}];
	obj.delegate = obj.bk_dynamicDelegate;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassArray {
	TestPassArray *obj = [TestPassArray new];
	[obj setTestWithArrayBlock:^BOOL(int *ary) {
		return ary[0] == 1 && ary[1] == 2 && ary[2] == 3 && ary[3] == 4 && ary[4] == 5;
	}];
	obj.delegate = obj.bk_dynamicDelegate;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassStruct {
	TestPassStruct *obj = [TestPassStruct new];
	[obj setTestWithStructBlock:^BOOL(MyStruct stret) {
		return stret.first && stret.second;
	}];
	obj.delegate = obj.bk_dynamicDelegate;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

@end
