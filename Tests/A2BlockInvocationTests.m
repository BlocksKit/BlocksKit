//
//  A2BlockInvocationTests.m
//  BlocksKit Unit Tests
//

#import <XCTest/XCTest.h>
#import <BlocksKit/A2BlockInvocation.h>

@interface A2BlockInvocationTests : XCTestCase

@end

typedef struct {
	double doubleValue;
	int integerValue;
	const char *stringValue;
	BOOL first;
	BOOL second;
} BigStruct;

@implementation A2BlockInvocationTests

- (void)invocationsForBlock:(id)block withSignature:(const char *)str native:(out NSInvocation **)outInv block:(out A2BlockInvocation **)outBlockInv
{
	NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:str];
	XCTAssertNotNil(signature);

	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:signature];
	XCTAssertNotNil(inv);

	A2BlockInvocation *blockInv = nil;
	XCTAssertNoThrow((blockInv = [[A2BlockInvocation alloc] initWithBlock:block methodSignature:signature]));
	XCTAssertNotNil(inv);

	if (outInv) *outInv = inv;
	if (outBlockInv) *outBlockInv = blockInv;
}

- (void)testVoidBlockInvocation
{
	__block BOOL ran = NO;
	NSInvocation *inv; A2BlockInvocation *blockInv;

	[self invocationsForBlock:^{
		ran = YES;
	} withSignature:"v@:" native:&inv block:&blockInv];

	XCTAssertNoThrow([blockInv invokeWithInvocation:inv]);

	XCTAssertTrue(ran, @"Void block didn't run");
}

- (void)testReturnObjectBlockInvocation
{
	NSInvocation *inv; A2BlockInvocation *blockInv;

	[self invocationsForBlock:^(int val, NSString *str) {
		return (val == 42 && [str isEqualToString:@"Test"]) ? @"YES" : @"NO";
	} withSignature:"@@:i@" native:&inv block:&blockInv];


	int firstArgument = 42;
	NSString *secondArgument = @"Test";
	[inv setArgument:&firstArgument atIndex:2];
	[inv setArgument:&secondArgument atIndex:3];

	XCTAssertNoThrow([blockInv invokeWithInvocation:inv]);

	NSString *output;
	[inv getReturnValue:&output];
	XCTAssertEqualObjects(output, @"YES", @"Object return block test didn't return right value");
}

- (void)testReturnStructBlockInvocation {
	NSInvocation *inv; A2BlockInvocation *blockInv;

	[self invocationsForBlock:^(int val, NSString *str) {
		BigStruct ret;
		ret.doubleValue = val * 2.2;
		ret.integerValue = val;
		ret.stringValue = str.UTF8String;
		ret.first = YES;
		ret.second = NO;
		return ret;
	} withSignature:"{_BigStruct=di*cc}@:i@" native:&inv block:&blockInv];

	int firstArgument = 42;
	NSString *secondArgument = @"Test";
	[inv setArgument:&firstArgument atIndex:2];
	[inv setArgument:&secondArgument atIndex:3];

	XCTAssertNoThrow([blockInv invokeWithInvocation:inv]);

	BigStruct output;
	[inv getReturnValue:&output];
	XCTAssertEqual(output.doubleValue, 92.4, @"Struct return block test didn't return right values");
	XCTAssertEqual(output.integerValue, 42, @"Struct return block test didn't return right values");
	XCTAssertTrue(strcmp(output.stringValue, "Test") == 0, @"Struct return block test didn't return right values");
	XCTAssertEqual(output.first, YES, @"Struct return block test didn't return right values");
	XCTAssertEqual(output.second, NO, @"Struct return block test didn't return right values");
}

- (void)testPassObjectBlockInvocation {
	NSInvocation *inv; A2BlockInvocation *blockInv;

	[self invocationsForBlock:^BOOL(int val, NSString *str) {
		return (val == 42 && [str isEqualToString:@"Test"]);
	} withSignature:"c@:i@" native:&inv block:&blockInv];

	int firstArgument = 42;
	NSString *secondArgument = @"Test";
	[inv setArgument:&firstArgument atIndex:2];
	[inv setArgument:&secondArgument atIndex:3];

	XCTAssertNoThrow([blockInv invokeWithInvocation:inv]);

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass object block test didn't return right value");
}

- (void)testPassCharBlockInvocation {
	NSInvocation *inv; A2BlockInvocation *blockInv;

	[self invocationsForBlock:^BOOL(char val) {
		return (val == 'Z');
	} withSignature:"c@:c" native:&inv block:&blockInv];

	char firstArgument = 'Z';
	[inv setArgument:&firstArgument atIndex:2];

	XCTAssertNoThrow([blockInv invokeWithInvocation:inv]);

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass char block test didn't return right value");
}

- (void)testPassUCharBlockInvocation {
	NSInvocation *inv; A2BlockInvocation *blockInv;

	[self invocationsForBlock:^BOOL(unsigned char val) {
		return (val == 'Z');
	} withSignature:"c@:C" native:&inv block:&blockInv];

	unsigned char firstArgument = 'Z';
	[inv setArgument:&firstArgument atIndex:2];

	XCTAssertNoThrow([blockInv invokeWithInvocation:inv]);

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass unsigned char block test didn't return right value");
}

- (void)testPassShortBlockInvocation {
	NSInvocation *inv; A2BlockInvocation *blockInv;

	[self invocationsForBlock:^BOOL(short val) {
		return (val == SHRT_MAX);
	} withSignature:"c@:s" native:&inv block:&blockInv];

	short firstArgument = SHRT_MAX;
	[inv setArgument:&firstArgument atIndex:2];

	XCTAssertNoThrow([blockInv invokeWithInvocation:inv]);

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass short block test didn't return right value");
}

- (void)testPassUShortBlockInvocation {
	NSInvocation *inv; A2BlockInvocation *blockInv;

	[self invocationsForBlock:^BOOL(unsigned short val) {
		return (val == USHRT_MAX);
	} withSignature:"c@:S" native:&inv block:&blockInv];

	unsigned short firstArgument = USHRT_MAX;
	[inv setArgument:&firstArgument atIndex:2];

	XCTAssertNoThrow([blockInv invokeWithInvocation:inv]);

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass unsigned short block test didn't return right value");
}

- (void)testPassIntBlockInvocation {
	NSInvocation *inv; A2BlockInvocation *blockInv;

	[self invocationsForBlock:^BOOL(int val) {
		return (val == INT_MAX);
	} withSignature:"c@:i" native:&inv block:&blockInv];

	int firstArgument = INT_MAX;
	[inv setArgument:&firstArgument atIndex:2];

	XCTAssertNoThrow([blockInv invokeWithInvocation:inv]);

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass int block test didn't return right value");
}

- (void)testPassUIntBlockInvocation {
	NSInvocation *inv; A2BlockInvocation *blockInv;

	[self invocationsForBlock:^BOOL(unsigned int val) {
		return (val == UINT_MAX);
	} withSignature:"c@:I" native:&inv block:&blockInv];

	unsigned int firstArgument = UINT_MAX;
	[inv setArgument:&firstArgument atIndex:2];

	XCTAssertNoThrow([blockInv invokeWithInvocation:inv]);

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass unsigned int block test didn't return right value");
}

#ifndef __LP64__

- (void)testPassLongBlockInvocation {
	NSInvocation *inv; A2BlockInvocation *blockInv;

	[self invocationsForBlock:^BOOL(long val) {
		return (val == LONG_MAX);
	} withSignature:"c@:l" native:&inv block:&blockInv];

	long firstArgument = LONG_MAX;
	[inv setArgument:&firstArgument atIndex:2];

	XCTAssertNoThrow([blockInv invokeWithInvocation:inv]);

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass long block test didn't return right value");
}

- (void)testPassULongBlockInvocation {
	NSInvocation *inv; A2BlockInvocation *blockInv;

	[self invocationsForBlock:^BOOL(unsigned long val) {
		return (val == ULONG_MAX);
	} withSignature:"c@:L" native:&inv block:&blockInv];

	unsigned long firstArgument = ULONG_MAX;
	[inv setArgument:&firstArgument atIndex:2];

	XCTAssertNoThrow([blockInv invokeWithInvocation:inv]);

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass unsigned long block test didn't return right value");
}

#else

- (void)testPassLongBlockInvocation { }
- (void)testPassULongBlockInvocation { }

#endif

- (void)testPassLongLongBlockInvocation {
	NSInvocation *inv; A2BlockInvocation *blockInv;

	[self invocationsForBlock:^BOOL(long long val) {
		return (val == LLONG_MAX);
	} withSignature:"c@:q" native:&inv block:&blockInv];

	long long firstArgument = LLONG_MAX;
	[inv setArgument:&firstArgument atIndex:2];

	XCTAssertNoThrow([blockInv invokeWithInvocation:inv]);

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass long long block test didn't return right value");
}

- (void)testPassULongLongBlockInvocation {
	NSInvocation *inv; A2BlockInvocation *blockInv;

	[self invocationsForBlock:^BOOL(unsigned long long val) {
		return (val == ULLONG_MAX);
	} withSignature:"c@:Q" native:&inv block:&blockInv];

	unsigned long long firstArgument = ULLONG_MAX;
	[inv setArgument:&firstArgument atIndex:2];

	XCTAssertNoThrow([blockInv invokeWithInvocation:inv]);

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass unsigned long long block test didn't return right value");
}

- (void)testPassFloatBlockInvocation {
	NSInvocation *inv; A2BlockInvocation *blockInv;

	[self invocationsForBlock:^BOOL(float val) {
		return (val == 1.01f);
	} withSignature:"c@:f" native:&inv block:&blockInv];

	float firstArgument = 1.01f;
	[inv setArgument:&firstArgument atIndex:2];

	XCTAssertNoThrow([blockInv invokeWithInvocation:inv]);

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass float block test didn't return right value");
}

- (void)testPassDoubleBlockInvocation {
	NSInvocation *inv; A2BlockInvocation *blockInv;

	[self invocationsForBlock:^BOOL(double val) {
		return (val == 1.01);
	} withSignature:"c@:d" native:&inv block:&blockInv];

	double firstArgument = 1.01;
	[inv setArgument:&firstArgument atIndex:2];

	XCTAssertNoThrow([blockInv invokeWithInvocation:inv]);

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass double block test didn't return right value");
}

- (void)testPassArrayBlockInvocation {
	NSInvocation *inv; A2BlockInvocation *blockInv;

	[self invocationsForBlock:^BOOL(int *ary) {
		return ary[0] == 1 && ary[1] == 2 && ary[2] == 3 && ary[3] == 4 && ary[4] == 5;
	} withSignature:"c@:^i" native:&inv block:&blockInv];

	int firstArgument[5] = { 1, 2, 3, 4, 5 };
	int *indirect = firstArgument;
	[inv setArgument:&indirect atIndex:2];

	XCTAssertNoThrow([blockInv invokeWithInvocation:inv]);

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass integer array block test didn't return right value");
}

- (void)testPassStructBlockInvocation
{
	NSInvocation *inv; A2BlockInvocation *blockInv;

	[self invocationsForBlock:^NSString *(BigStruct sret) {
		return (sret.doubleValue == 92.4 && sret.integerValue == 42 && !strcmp(sret.stringValue, "Test") && sret.first && !sret.second) ? @"YES" : @"NO";
	} withSignature:"@@:{_BigStruct=di*cc}" native:&inv block:&blockInv];

	int val = 42;
	NSString *str = @"Test";
	BigStruct ret;
	ret.doubleValue = val * 2.2;
	ret.integerValue = val;
	ret.stringValue = str.UTF8String;
	ret.first = YES;
	ret.second = NO;
	[inv setArgument:&ret atIndex:2];

	XCTAssertNoThrow([blockInv invokeWithInvocation:inv]);

	NSString *output;
	[inv getReturnValue:&output];
	XCTAssertEqualObjects(output, @"YES", @"Object return block test didn't return right value");
}

- (void)test_arm64_argumentAlign
{
	NSInvocation *inv; A2BlockInvocation *blockInv;
    
	[self invocationsForBlock:^NSString *(char w0, char w1, char w2, char w3, char w4, char w5, char w6, char w7, char s0, char s1) {
		return (w0 == 'a' && w1 == 'b' && w2 == 'c' && w3 == 'd' && w4 == 'e' && w5 == 'f' && w6 == 'g' && w7 == 'h' && s0 == 'i' && s1 == 'j') ? @"YES" : @"NO";
	} withSignature:"@@:cccccccccc" native:&inv block:&blockInv];
    
    char a1 = 'a';
    char a2 = 'b';
    char a3 = 'c';
    char a4 = 'd';
    char a5 = 'e';
    char a6 = 'f';
    char a7 = 'g';
    char a8 = 'h';
    char a9 = 'i';
    char a10 = 'j';
	[inv setArgument:&a1 atIndex:2];
	[inv setArgument:&a2 atIndex:3];
	[inv setArgument:&a3 atIndex:4];
	[inv setArgument:&a4 atIndex:5];
	[inv setArgument:&a5 atIndex:6];
	[inv setArgument:&a6 atIndex:7];
	[inv setArgument:&a7 atIndex:8];
	[inv setArgument:&a8 atIndex:9];
	[inv setArgument:&a9 atIndex:10];
	[inv setArgument:&a10 atIndex:11];

	XCTAssertNoThrow([blockInv invokeWithInvocation:inv]);
	
	NSString *output;
	[inv getReturnValue:&output];
	XCTAssertEqualObjects(output, @"YES", @"Object return block test didn't return right value");
}

- (void)test_arm64_argumentAlignStructOnStack
{
	NSInvocation *inv; A2BlockInvocation *blockInv;
	[self invocationsForBlock:^NSString *(char w0, char w1, char w2, char w3, char w4, char w5, char w6, char w7, BigStruct sret) {
        return (w0 == 'a' && w1 == 'b' && w2 == 'c' && w3 == 'd' && w4 == 'e' && w5 == 'f' && w6 == 'g' && w7 == 'h' && sret.doubleValue == 92.4 && sret.integerValue == 42 && !strcmp(sret.stringValue, "Test") && sret.first && !sret.second) ? @"YES" : @"NO";
	} withSignature:"@@:cccccccc{_BigStruct=di*cc}" native:&inv block:&blockInv];
    
    char a1 = 'a';
    char a2 = 'b';
    char a3 = 'c';
    char a4 = 'd';
    char a5 = 'e';
    char a6 = 'f';
    char a7 = 'g';
    char a8 = 'h';
    BigStruct a9;
	int val = 42;
	a9.doubleValue = val * 2.2;
	a9.integerValue = val;
	a9.stringValue = @"Test".UTF8String;
	a9.first = YES;
	a9.second = NO;
    
	[inv setArgument:&a1 atIndex:2];
	[inv setArgument:&a2 atIndex:3];
	[inv setArgument:&a3 atIndex:4];
	[inv setArgument:&a4 atIndex:5];
	[inv setArgument:&a5 atIndex:6];
	[inv setArgument:&a6 atIndex:7];
	[inv setArgument:&a7 atIndex:8];
	[inv setArgument:&a8 atIndex:9];
	[inv setArgument:&a9 atIndex:10];

	XCTAssertNoThrow([blockInv invokeWithInvocation:inv]);
	
	NSString *output;
	[inv getReturnValue:&output];
	XCTAssertEqualObjects(output, @"YES", @"Object return block test didn't return right value");
}

@end
