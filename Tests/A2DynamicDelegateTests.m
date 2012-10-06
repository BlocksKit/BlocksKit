//
//  A2DynamicDelegateTests.m
//  BlocksKit Unit Tests
//
//  Created by Zachary Waldowski on 6/5/12.
//  Copyright (c) 2012 Pandamonia LLC. All rights reserved.
//

#import "A2DynamicDelegateTests.h"

#pragma mark -

@implementation TestReturnObject

- (BOOL)test {
	return !![self.delegate testReturnObject].length;
}

@end

#pragma mark -

@implementation TestReturnStruct

- (BOOL)test {
	MyStruct value = [self.delegate testReturnStruct];
	return value.first && value.second;
}

@end

#pragma mark -

@implementation TestPassObject

- (BOOL)test {
	return [self.delegate testWithObject: @"Test"];
}

@end

#pragma mark -

@implementation TestPassChar

- (BOOL)test {
	return [self.delegate testWithChar: 'Z'];
}

@end

#pragma mark -

@implementation TestPassUChar

- (BOOL)test {
	return [self.delegate testWithUChar: 'Z'];
}

@end

#pragma mark -

@implementation TestPassShort

- (BOOL)test {
	return [self.delegate testWithShort: SHRT_MAX];
}

@end

#pragma mark -

@implementation TestPassUShort

- (BOOL)test {
	return [self.delegate testWithUShort: USHRT_MAX];
}

@end

#pragma mark -

@implementation TestPassInt

- (BOOL)test {
	return [self.delegate testWithInt: INT_MAX];
}

@end

#pragma mark -

@implementation TestPassUInt

- (BOOL)test {
	return [self.delegate testWithUInt: UINT_MAX];
}

@end

#pragma mark -

@implementation TestPassLong

- (BOOL)test {
	return [self.delegate testWithLong: LONG_MAX];
}

@end

#pragma mark -

@implementation TestPassULong

- (BOOL)test {
	return [self.delegate testWithULong: ULONG_MAX];
}

@end

#pragma mark -

@implementation TestPassLongLong

- (BOOL)test {
	return [self.delegate testWithLongLong: LLONG_MAX];
}

@end

#pragma mark -

@implementation TestPassULongLong

- (BOOL)test {
	return [self.delegate testWithULongLong: ULLONG_MAX];
}

@end

#pragma mark -

@implementation TestPassFloat

- (BOOL)test {
	return [self.delegate testWithFloat: 1.01f];
}

@end

#pragma mark -

@implementation TestPassDouble

- (BOOL)test {
	return [self.delegate testWithDouble: 1.01];
}

@end

#pragma mark -

@implementation TestPassArray

- (BOOL)test {
	int myArray[5] = { 1, 2, 3, 4, 5 };
	return [self.delegate testWithArray: myArray];
}

@end

#pragma mark -

@implementation TestPassStruct

- (BOOL)test {
	MyStruct stret;
	stret.first = YES;
	stret.second = YES;
	return [self.delegate testPassStruct: stret];
}

@end

#pragma mark -

@implementation TestClassMethod

- (BOOL)test {
	return [[self.delegate class] testWithObject: @"Test"];
}


@end

#pragma mark -

@implementation A2DynamicDelegateTests

- (void)testReturnObject {
	TestReturnObject *obj = [TestReturnObject new];
	A2DynamicDelegate <TestReturnObjectDelegate> *dd = [obj dynamicDelegateForProtocol:@protocol(TestReturnObjectDelegate)];
	STAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testReturnObject) withBlock:^NSString *{
		return @"Test";
	}];
	STAssertNotNil(dd, [dd blockImplementationForMethod:@selector(testReturnObject)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testReturnStruct {
	TestReturnStruct *obj = [TestReturnStruct new];
	A2DynamicDelegate <TestReturnStructDelegate> *dd = [obj dynamicDelegateForProtocol:@protocol(TestReturnStructDelegate)];
	STAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testReturnStruct) withBlock:^MyStruct{
		MyStruct val;
		val.first = YES;
		val.second = YES;
		return val;
	}];
	STAssertNotNil(dd, [dd blockImplementationForMethod:@selector(testReturnStruct)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassObject {
	TestPassObject *obj = [TestPassObject new];
	A2DynamicDelegate <TestPassObjectDelegate> *dd = [obj dynamicDelegateForProtocol:@protocol(TestPassObjectDelegate)];
	STAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithObject:) withBlock:^BOOL(NSString *str){
		return !!str.length;
	}];
	STAssertNotNil(dd, [dd blockImplementationForMethod:@selector(testWithObject:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassChar {
	TestPassChar *obj = [TestPassChar new];
	A2DynamicDelegate <TestPassCharDelegate> *dd = [obj dynamicDelegateForProtocol:@protocol(TestPassCharDelegate)];
	STAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithChar:) withBlock:^BOOL(char chr){
		return (chr == 'Z');
	}];
	STAssertNotNil(dd, [dd blockImplementationForMethod:@selector(testWithChar:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassUChar {
	TestPassUChar *obj = [TestPassUChar new];
	A2DynamicDelegate <TestPassUCharDelegate> *dd = [obj dynamicDelegateForProtocol:@protocol(TestPassUCharDelegate)];
	STAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithUChar:) withBlock:^BOOL(unsigned char uchr){
		return (uchr == 'Z');
	}];
	STAssertNotNil(dd, [dd blockImplementationForMethod:@selector(testWithUChar:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassShort {
	TestPassShort *obj = [TestPassShort new];
	A2DynamicDelegate <TestPassShortDelegate> *dd = [obj dynamicDelegateForProtocol:@protocol(TestPassShortDelegate)];
	STAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithShort:) withBlock:^BOOL(short shrt){
		return (shrt == SHRT_MAX);
	}];
	STAssertNotNil(dd, [dd blockImplementationForMethod:@selector(testWithShort:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassUShort {
	TestPassUShort *obj = [TestPassUShort new];
	A2DynamicDelegate <TestPassUShortDelegate> *dd = [obj dynamicDelegateForProtocol:@protocol(TestPassUShortDelegate)];
	STAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithUShort:) withBlock:^BOOL(unsigned short ushrt){
		return (ushrt == USHRT_MAX);
	}];
	STAssertNotNil(dd, [dd blockImplementationForMethod:@selector(testWithUShort:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassInt {
	TestPassInt *obj = [TestPassInt new];
	A2DynamicDelegate <TestPassIntDelegate> *dd = [obj dynamicDelegateForProtocol:@protocol(TestPassIntDelegate)];
	STAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithInt:) withBlock:^BOOL(int inte){
		return (inte == INT_MAX);
	}];
	STAssertNotNil(dd, [dd blockImplementationForMethod:@selector(testWithInt:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassUInt {
	TestPassUInt *obj = [TestPassUInt new];
	A2DynamicDelegate <TestPassUIntDelegate> *dd = [obj dynamicDelegateForProtocol:@protocol(TestPassUIntDelegate)];
	STAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithUInt:) withBlock:^BOOL(unsigned int uint){
		return (uint == UINT_MAX);
	}];
	STAssertNotNil(dd, [dd blockImplementationForMethod:@selector(testWithUInt:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassLong {
	TestPassLong *obj = [TestPassLong new];
	A2DynamicDelegate <TestPassLongDelegate> *dd = [obj dynamicDelegateForProtocol:@protocol(TestPassLongDelegate)];
	STAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithLong:) withBlock:^BOOL(long lng){
		return (lng == LONG_MAX);
	}];
	STAssertNotNil(dd, [dd blockImplementationForMethod:@selector(testWithLong:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassULong {
	TestPassULong *obj = [TestPassULong new];
	A2DynamicDelegate <TestPassULongDelegate> *dd = [obj dynamicDelegateForProtocol:@protocol(TestPassULongDelegate)];
	STAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithULong:) withBlock:^BOOL(unsigned long lng){
		return (lng == ULONG_MAX);
	}];
	STAssertNotNil(dd, [dd blockImplementationForMethod:@selector(testWithULong:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassLongLong {
	TestPassLongLong *obj = [TestPassLongLong new];
	A2DynamicDelegate <TestPassLongLongDelegate> *dd = [obj dynamicDelegateForProtocol:@protocol(TestPassLongLongDelegate)];
	STAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithLongLong:) withBlock:^BOOL(long long llng){
		return (llng == LLONG_MAX);
	}];
	STAssertNotNil(dd, [dd blockImplementationForMethod:@selector(testWithLongLong:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassULongLong {
	TestPassULongLong *obj = [TestPassULongLong new];
	A2DynamicDelegate <TestPassULongLongDelegate> *dd = [obj dynamicDelegateForProtocol:@protocol(TestPassULongLongDelegate)];
	STAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithULongLong:) withBlock:^BOOL(unsigned long long lng){
		return (lng == ULLONG_MAX);
	}];
	STAssertNotNil(dd, [dd blockImplementationForMethod:@selector(testWithULongLong:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassFloat {
	TestPassFloat *obj = [TestPassFloat new];
	A2DynamicDelegate <TestPassFloatDelegate> *dd = [obj dynamicDelegateForProtocol:@protocol(TestPassFloatDelegate)];
	STAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithFloat:) withBlock:^BOOL(float flt){
		return (flt == 1.01f);
	}];
	STAssertNotNil(dd, [dd blockImplementationForMethod:@selector(testWithFloat:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassDouble {
	TestPassDouble *obj = [TestPassDouble new];
	A2DynamicDelegate <TestPassDoubleDelegate> *dd = [obj dynamicDelegateForProtocol:@protocol(TestPassDoubleDelegate)];
	STAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithDouble:) withBlock:^BOOL(double dbl){
		return (dbl == 1.01);
	}];
	STAssertNotNil(dd, [dd blockImplementationForMethod:@selector(testWithDouble:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassArray {
	TestPassArray *obj = [TestPassArray new];
	A2DynamicDelegate <TestPassArrayDelegate> *dd = [obj dynamicDelegateForProtocol:@protocol(TestPassArrayDelegate)];
	STAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testWithArray:) withBlock:^BOOL(int *ary){
		return ary[0] == 1 && ary[1] == 2 && ary[2] == 3 && ary[3] == 4 && ary[4] == 5;
	}];
	STAssertNotNil(dd, [dd blockImplementationForMethod:@selector(testWithArray:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testPassStruct {
	TestPassStruct *obj = [TestPassStruct new];
	A2DynamicDelegate <TestPassStructDelegate> *dd = [obj dynamicDelegateForProtocol:@protocol(TestPassStructDelegate)];
	STAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementMethod:@selector(testPassStruct:) withBlock:^BOOL(MyStruct stret){
		return stret.first && stret.second;
	}];
	STAssertNotNil(dd, [dd blockImplementationForMethod:@selector(testPassStruct:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testClassMethod {
	TestClassMethod *obj = [TestClassMethod new];
	A2DynamicDelegate <TestClassMethodProtocol> *dd = [obj dynamicDelegateForProtocol:@protocol(TestClassMethodProtocol)];
	STAssertNotNil(dd, @"Dynamic delegate not set");
	[dd implementClassMethod:@selector(testWithObject:) withBlock:^BOOL(NSString *str){
		return !!str.length;
	}];
	STAssertNotNil(dd, [dd blockImplementationForClassMethod:@selector(testWithObject:)]);
	obj.delegate = dd;
	BOOL result = [obj test];
	STAssertTrue(result, @"Test object didn't return true");
}

- (void)testClassInterfacing {
	TestClassMethod *obj = [TestClassMethod new];
	A2DynamicDelegate <TestClassMethodProtocol> *dd = [obj dynamicDelegateForProtocol:@protocol(TestClassMethodProtocol)];
	STAssertNotNil(dd, @"Dynamic delegate not set");
	Class interposed = [dd class];
	Class original = [A2DynamicDelegate class];
	
	STAssertTrue([[interposed description] isEqualToString: [original description]], @"Descriptions not the same");
	STAssertEquals([interposed class], [original class], @"Classes not the same");
	STAssertEquals([interposed hash], [original hash], @"Hashes not the same");
	STAssertEquals([interposed superclass], [original superclass], @"Superclasses not the same");
}

@end
