//
//  A2BlockInvocationTests.m
//  BlocksKit Unit Tests
//

#import <XCTest/XCTest.h>
#import <BlocksKit/A2BlockInvocation.h>

static const void *A2BlockInvocationTestPass = &A2BlockInvocationTestPass;

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

- (void)getInvocationsForBlock:(id)block native:(out NSInvocation **)outInv block:(out A2BlockInvocation **)outBlockInv
{
	A2BlockInvocation *blockInv = nil;
	XCTAssertNoThrow((blockInv = [[A2BlockInvocation alloc] initWithBlock:block]));
	XCTAssertNotNil(blockInv);

	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:blockInv.methodSignature];
	XCTAssertNotNil(inv);

	if (outInv) *outInv = inv;
	if (outBlockInv) *outBlockInv = blockInv;
}

- (void)testReturnVoid
{
	__block BOOL ran = NO;
	NSInvocation *inv; A2BlockInvocation *blockInv;

	[self getInvocationsForBlock:^{
		ran = YES;
	} native:&inv block:&blockInv];

	XCTAssertNoThrow([blockInv invokeWithInvocation:inv]);

	XCTAssertTrue(ran);
}

- (void)testReturnObject {
	NSInvocation *inv; A2BlockInvocation *blockInv;

	[self getInvocationsForBlock:^(int val, NSString *str) {
		return (val == 42 && [str isEqualToString:@"Test"]) ? @"YES" : @"NO";
	} native:&inv block:&blockInv];

	int firstArgument = 42;
	NSString *secondArgument = @"Test";
	[inv setArgument:&firstArgument atIndex:2];
	[inv setArgument:&secondArgument atIndex:3];

	XCTAssertNoThrow([blockInv invokeWithInvocation:inv]);

	NSString *output;
	[inv getReturnValue:&output];
	XCTAssertEqualObjects(output, @"YES");
}

- (void)testReturnStruct {
	NSInvocation *inv; A2BlockInvocation *blockInv;

	[self getInvocationsForBlock:^(int val, NSString *str) {
		return (BigStruct){ .doubleValue = 92.4, .integerValue = 42, .stringValue = "Test", .first = YES, .second = NO };
	} native:&inv block:&blockInv];

	int firstArgument = 42;
	NSString *secondArgument = @"Test";
	[inv setArgument:&firstArgument atIndex:2];
	[inv setArgument:&secondArgument atIndex:3];

	XCTAssertNoThrow([blockInv invokeWithInvocation:inv]);

	BigStruct output;
	[inv getReturnValue:&output];
	XCTAssertEqual(output.doubleValue, 92.4);
	XCTAssertEqual(output.integerValue, 42);
	XCTAssertTrue(strcmp(output.stringValue, "Test") == 0);
	XCTAssertEqual(output.first, YES);
	XCTAssertEqual(output.second, NO);
}

#define AssertReturnValueEquals(inv, rvalue, format...) { \
	__typeof__(rvalue) output; \
	[inv getReturnValue:&output]; \
	XCTAssertEqual(output, rvalue, ## format); \
}

- (void)testPassObjectBlockInvocation {
	NSInvocation *inv; A2BlockInvocation *blockInv;

	[self getInvocationsForBlock:^(int val, NSString *str) {
		return (val == 42 && [str isEqualToString:@"Test"]) ? A2BlockInvocationTestPass : NULL;
	} native:&inv block:&blockInv];

	int firstArgument = 42;
	NSString *secondArgument = @"Test";
	[inv setArgument:&firstArgument atIndex:2];
	[inv setArgument:&secondArgument atIndex:3];

	XCTAssertNoThrow([blockInv invokeWithInvocation:inv]);
	AssertReturnValueEquals(inv, A2BlockInvocationTestPass);
}

#define TEST_PASS_VALUE(__type, __testValue) { \
	NSInvocation *inv; A2BlockInvocation *blockInv; \
	[self getInvocationsForBlock:^(__type val) { \
		return (memcmp(&val, &__testValue, sizeof(__type)) == 0) ? A2BlockInvocationTestPass : NULL; \
	} native:&inv block:&blockInv]; \
	\
	[inv setArgument:(void *)&__testValue atIndex:2]; \
	\
	XCTAssertNoThrow([blockInv invokeWithInvocation:inv]); \
	AssertReturnValueEquals(inv, A2BlockInvocationTestPass); \
}

#define TEST_SIMPLE_PASSING(__type, ___testValue) { \
	static const __type __testValue = ___testValue; \
	TEST_PASS_VALUE(__type, __testValue); \
}

- (void)testPassCharBlockInvocation {
	TEST_SIMPLE_PASSING(char, 'Z');
}

- (void)testPassUCharBlockInvocation {
	TEST_SIMPLE_PASSING(unsigned char, 'Z');
}

- (void)testPassShortBlockInvocation {
	TEST_SIMPLE_PASSING(short, SHRT_MAX);
}

- (void)testPassUShortBlockInvocation {
	TEST_SIMPLE_PASSING(unsigned short, USHRT_MAX);
}

- (void)testPassIntBlockInvocation {
	TEST_SIMPLE_PASSING(int, INT_MAX);
}

- (void)testPassUIntBlockInvocation {
	TEST_SIMPLE_PASSING(unsigned int, UINT_MAX);
}

- (void)testPassLongBlockInvocation {
	TEST_SIMPLE_PASSING(long, LONG_MAX);
}

- (void)testPassULongBlockInvocation {
	TEST_SIMPLE_PASSING(unsigned long, ULONG_MAX);
}

- (void)testPassLongLongBlockInvocation {
	TEST_SIMPLE_PASSING(long long, LLONG_MAX);
}

- (void)testPassULongLongBlockInvocation {
	TEST_SIMPLE_PASSING(unsigned long long, ULLONG_MAX);
}

- (void)testPassFloatBlockInvocation {
	TEST_SIMPLE_PASSING(float, 1.01f);
}

- (void)testPassDoubleBlockInvocation {
	TEST_SIMPLE_PASSING(double, 1.01);
}

- (void)testPassArrayBlockInvocation {
	static int const tarray[5] = (const int[5]){ 1, 2, 3, 4, 5 };
	TEST_PASS_VALUE(int *, tarray);
}

- (void)testPassStructBlockInvocation
{
	TEST_SIMPLE_PASSING(BigStruct, ((BigStruct){
		.doubleValue = 92.4,
		.integerValue = 42,
		.stringValue = "Test",
		.first = YES,
		.second = NO }));
}

#undef TEST_PASS_VALUE
#undef TEST_SIMPLE_PASSING

- (void)test_arm64_argumentAlign
{
	NSInvocation *inv; A2BlockInvocation *blockInv;

	[self getInvocationsForBlock:^(char w0, char w1, char w2, char w3, char w4, char w5, char w6, char w7, char s0, char s1) {
		return (w0 == 'a' && w1 == 'b' && w2 == 'c' && w3 == 'd' && w4 == 'e' && w5 == 'f' && w6 == 'g' && w7 == 'h' && s0 == 'i' && s1 == 'j') ? A2BlockInvocationTestPass : NULL;
	} native:&inv block:&blockInv];

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
	AssertReturnValueEquals(inv, A2BlockInvocationTestPass);
}

- (void)test_arm64_argumentAlignStructOnStack
{
	NSInvocation *inv; A2BlockInvocation *blockInv;
	[self getInvocationsForBlock:^(char w0, char w1, char w2, char w3, char w4, char w5, char w6, char w7, BigStruct arg) {
		return (w0 == 'a' && w1 == 'b' && w2 == 'c' && w3 == 'd' && w4 == 'e' && w5 == 'f' && w6 == 'g' && w7 == 'h' && arg.doubleValue == 92.4 && arg.integerValue == 42 && !strcmp(arg.stringValue, "Test") && arg.first && !arg.second) ? A2BlockInvocationTestPass : NULL;
	} native:&inv block:&blockInv];

	char a1 = 'a';
	char a2 = 'b';
	char a3 = 'c';
	char a4 = 'd';
	char a5 = 'e';
	char a6 = 'f';
	char a7 = 'g';
	char a8 = 'h';
	BigStruct a9 = (BigStruct){ .doubleValue = 92.4, .integerValue = 42, .stringValue = "Test", .first = YES, .second = NO };

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
	AssertReturnValueEquals(inv, A2BlockInvocationTestPass);
}

#undef AssertReturnValueEquals

@end
