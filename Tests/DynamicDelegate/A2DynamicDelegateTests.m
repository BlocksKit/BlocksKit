//
//  A2DynamicDelegateTests.m
//  BlocksKit Unit Tests
//

#import <XCTest/XCTest.h>
#import <BlocksKit/A2DynamicDelegate.h>
#import "A2DynamicTestClasses.h"

@interface A2DynamicDelegateTests : XCTestCase

@end

@implementation A2DynamicDelegateTests

- (void)testReturnObject {
	TestReturnObject *obj = [TestReturnObject new];
	A2DynamicDelegate <TestReturnObjectDelegate> *dd = [obj bk_dynamicDelegateForProtocol:@protocol(TestReturnObjectDelegate)];
	XCTAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testReturnObject) withBlock:^NSString *{
		return @"Test";
	}];
	XCTAssertNotNil([dd blockImplementationForMethod:@selector(testReturnObject)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testReturnStruct {
	TestReturnStruct *obj = [TestReturnStruct new];
	A2DynamicDelegate <TestReturnStructDelegate> *dd = [obj bk_dynamicDelegateForProtocol:@protocol(TestReturnStructDelegate)];
	XCTAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testReturnStruct) withBlock:^MyStruct{
		MyStruct val;
		val.first = YES;
		val.second = YES;
		return val;
	}];
	XCTAssertNotNil([dd blockImplementationForMethod:@selector(testReturnStruct)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassObject {
	TestPassObject *obj = [TestPassObject new];
	A2DynamicDelegate <TestPassObjectDelegate> *dd = [obj bk_dynamicDelegateForProtocol:@protocol(TestPassObjectDelegate)];
	XCTAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithObject:) withBlock:^BOOL(NSString *str) {
		return !!str.length;
	}];
	XCTAssertNotNil([dd blockImplementationForMethod:@selector(testWithObject:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassChar {
	TestPassChar *obj = [TestPassChar new];
	A2DynamicDelegate <TestPassCharDelegate> *dd = [obj bk_dynamicDelegateForProtocol:@protocol(TestPassCharDelegate)];
	XCTAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithChar:) withBlock:^BOOL(char chr) {
		return (chr == 'Z');
	}];
	XCTAssertNotNil([dd blockImplementationForMethod:@selector(testWithChar:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassUChar {
	TestPassUChar *obj = [TestPassUChar new];
	A2DynamicDelegate <TestPassUCharDelegate> *dd = [obj bk_dynamicDelegateForProtocol:@protocol(TestPassUCharDelegate)];
	XCTAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithUChar:) withBlock:^BOOL(unsigned char uchr) {
		return (uchr == 'Z');
	}];
	XCTAssertNotNil([dd blockImplementationForMethod:@selector(testWithUChar:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassShort {
	TestPassShort *obj = [TestPassShort new];
	A2DynamicDelegate <TestPassShortDelegate> *dd = [obj bk_dynamicDelegateForProtocol:@protocol(TestPassShortDelegate)];
	XCTAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithShort:) withBlock:^BOOL(short shrt) {
		return (shrt == SHRT_MAX);
	}];
	XCTAssertNotNil([dd blockImplementationForMethod:@selector(testWithShort:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassUShort {
	TestPassUShort *obj = [TestPassUShort new];
	A2DynamicDelegate <TestPassUShortDelegate> *dd = [obj bk_dynamicDelegateForProtocol:@protocol(TestPassUShortDelegate)];
	XCTAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithUShort:) withBlock:^BOOL(unsigned short ushrt) {
		return (ushrt == USHRT_MAX);
	}];
	XCTAssertNotNil([dd blockImplementationForMethod:@selector(testWithUShort:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassInt {
	TestPassInt *obj = [TestPassInt new];
	A2DynamicDelegate <TestPassIntDelegate> *dd = [obj bk_dynamicDelegateForProtocol:@protocol(TestPassIntDelegate)];
	XCTAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithInt:) withBlock:^BOOL(int inte) {
		return (inte == INT_MAX);
	}];
	XCTAssertNotNil([dd blockImplementationForMethod:@selector(testWithInt:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassUInt {
	TestPassUInt *obj = [TestPassUInt new];
	A2DynamicDelegate <TestPassUIntDelegate> *dd = [obj bk_dynamicDelegateForProtocol:@protocol(TestPassUIntDelegate)];
	XCTAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithUInt:) withBlock:^BOOL(unsigned int uint) {
		return (uint == UINT_MAX);
	}];
	XCTAssertNotNil([dd blockImplementationForMethod:@selector(testWithUInt:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassLong {
	TestPassLong *obj = [TestPassLong new];
	A2DynamicDelegate <TestPassLongDelegate> *dd = [obj bk_dynamicDelegateForProtocol:@protocol(TestPassLongDelegate)];
	XCTAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithLong:) withBlock:^BOOL(long lng) {
		return (lng == LONG_MAX);
	}];
	XCTAssertNotNil([dd blockImplementationForMethod:@selector(testWithLong:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassULong {
	TestPassULong *obj = [TestPassULong new];
	A2DynamicDelegate <TestPassULongDelegate> *dd = [obj bk_dynamicDelegateForProtocol:@protocol(TestPassULongDelegate)];
	XCTAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithULong:) withBlock:^BOOL(unsigned long lng) {
		return (lng == ULONG_MAX);
	}];
	XCTAssertNotNil([dd blockImplementationForMethod:@selector(testWithULong:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassLongLong {
	TestPassLongLong *obj = [TestPassLongLong new];
	A2DynamicDelegate <TestPassLongLongDelegate> *dd = [obj bk_dynamicDelegateForProtocol:@protocol(TestPassLongLongDelegate)];
	XCTAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithLongLong:) withBlock:^BOOL(long long llng) {
		return (llng == LLONG_MAX);
	}];
	XCTAssertNotNil([dd blockImplementationForMethod:@selector(testWithLongLong:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassULongLong {
	TestPassULongLong *obj = [TestPassULongLong new];
	A2DynamicDelegate <TestPassULongLongDelegate> *dd = [obj bk_dynamicDelegateForProtocol:@protocol(TestPassULongLongDelegate)];
	XCTAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithULongLong:) withBlock:^BOOL(unsigned long long lng) {
		return (lng == ULLONG_MAX);
	}];
	XCTAssertNotNil([dd blockImplementationForMethod:@selector(testWithULongLong:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassFloat {
	TestPassFloat *obj = [TestPassFloat new];
	A2DynamicDelegate <TestPassFloatDelegate> *dd = [obj bk_dynamicDelegateForProtocol:@protocol(TestPassFloatDelegate)];
	XCTAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithFloat:) withBlock:^BOOL(float flt) {
		return (flt == 1.01f);
	}];
	XCTAssertNotNil([dd blockImplementationForMethod:@selector(testWithFloat:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassDouble {
	TestPassDouble *obj = [TestPassDouble new];
	A2DynamicDelegate <TestPassDoubleDelegate> *dd = [obj bk_dynamicDelegateForProtocol:@protocol(TestPassDoubleDelegate)];
	XCTAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithDouble:) withBlock:^BOOL(double dbl) {
		return (dbl == 1.01);
	}];
	XCTAssertNotNil([dd blockImplementationForMethod:@selector(testWithDouble:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassArray {
	TestPassArray *obj = [TestPassArray new];
	A2DynamicDelegate <TestPassArrayDelegate> *dd = [obj bk_dynamicDelegateForProtocol:@protocol(TestPassArrayDelegate)];
	XCTAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithArray:) withBlock:^BOOL(int *ary) {
		return ary[0] == 1 && ary[1] == 2 && ary[2] == 3 && ary[3] == 4 && ary[4] == 5;
	}];
	XCTAssertNotNil([dd blockImplementationForMethod:@selector(testWithArray:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassStruct {
	TestPassStruct *obj = [TestPassStruct new];
	A2DynamicDelegate <TestPassStructDelegate> *dd = [obj bk_dynamicDelegateForProtocol:@protocol(TestPassStructDelegate)];
	XCTAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testPassStruct:) withBlock:^BOOL(MyStruct stret) {
		return stret.first && stret.second;
	}];
	XCTAssertNotNil([dd blockImplementationForMethod:@selector(testPassStruct:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testClassMethod {
	TestClassMethod *obj = [TestClassMethod new];
	A2DynamicDelegate <TestClassMethodProtocol> *dd = [obj bk_dynamicDelegateForProtocol:@protocol(TestClassMethodProtocol)];
	XCTAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementClassMethod:@selector(testWithObject:) withBlock:^BOOL(NSString *str) {
		return !!str.length;
	}];
	XCTAssertNotNil([dd blockImplementationForClassMethod:@selector(testWithObject:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	XCTAssertTrue(result, @"Test object didn't return true");
}

- (void)testClassInterfacing {
	TestClassMethod *obj = [TestClassMethod new];
	A2DynamicDelegate <TestClassMethodProtocol> *dd = [obj bk_dynamicDelegateForProtocol:@protocol(TestClassMethodProtocol)];
	XCTAssertNotNil(dd, @"Dynamic delegate not set");
	Class interposed = [dd class];
	Class original = [A2DynamicDelegate class];
	
	XCTAssertTrue([[interposed description] isEqualToString:[original description]], @"Descriptions not the same");
	XCTAssertEqual([interposed class], [original class], @"Classes not the same");
	XCTAssertEqual([interposed hash], [original hash], @"Hashes not the same");
	XCTAssertEqual([interposed superclass], [original superclass], @"Superclasses not the same");
}

@end
