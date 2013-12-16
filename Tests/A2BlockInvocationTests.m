//
//  A2BlockInvocationTests.m
//  BlocksKit Unit Tests
//

#import <XCTest/XCTest.h>
#import <BlocksKit/A2BlockInvocation.h>

@interface A2BlockInvocationTests : XCTestCase

@end

typedef struct _BigStruct {
	double doubleValue;
	int integerValue;
	const char *stringValue;
	BOOL first;
	BOOL second;
} BigStruct;

@implementation A2BlockInvocationTests

- (void)testVoidBlockInvocation
{
	__block BOOL ran = NO;

	void(^block)(void) = ^{
		ran = YES;
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes:"v@:"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock:block methodSignature:siggy];
	[inv invoke];

	XCTAssertTrue(ran, @"Void block didn't run");
}

- (void)testReturnObjectBlockInvocation
{
	NSString *(^block)(int, NSString *) = ^(int val, NSString *str) {
		return (val == 42 && [str isEqualToString:@"Test"]) ? @"YES" : @"NO";
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes:"@@:i@"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock:block methodSignature:siggy];

	int firstArgument = 42;
	NSString *secondArgument = @"Test";
	[inv setArgument:&firstArgument atIndex:0];
	[inv setArgument:&secondArgument atIndex:1];

	[inv invoke];

	NSString *output;
	[inv getReturnValue:&output];
	XCTAssertEqualObjects(output, @"YES", @"Object return block test didn't return right value");
}

- (void)testReturnStructBlockInvocation {
	BigStruct(^block)(int, NSString *) = ^BigStruct(int val, NSString *str) {
		BigStruct ret;
		ret.doubleValue = val * 2.2;
		ret.integerValue = val;
		ret.stringValue = str.UTF8String;
		ret.first = YES;
		ret.second = NO;
		return ret;
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes:"{_BigStruct=di*cc}@:i@"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock:block methodSignature:siggy];

	int firstArgument = 42;
	NSString *secondArgument = @"Test";
	[inv setArgument:&firstArgument atIndex:0];
	[inv setArgument:&secondArgument atIndex:1];
	[inv invoke];

	BigStruct output;
	[inv getReturnValue:&output];
	XCTAssertEqual(output.doubleValue, 92.4, @"Struct return block test didn't return right values");
	XCTAssertEqual(output.integerValue, 42, @"Struct return block test didn't return right values");
	XCTAssertTrue(strcmp(output.stringValue, "Test") == 0, @"Struct return block test didn't return right values");
	XCTAssertEqual(output.first, YES, @"Struct return block test didn't return right values");
	XCTAssertEqual(output.second, NO, @"Struct return block test didn't return right values");
}

- (void)testPassObjectBlockInvocation {
	BOOL(^block)(int, NSString *) = ^BOOL(int val, NSString *str) {
		return (val == 42 && [str isEqualToString:@"Test"]);
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes:"@@:i@"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock:block methodSignature:siggy];

	int firstArgument = 42;
	NSString *secondArgument = @"Test";
	[inv setArgument:&firstArgument atIndex:0];
	[inv setArgument:&secondArgument atIndex:1];

	[inv invoke];

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass object block test didn't return right value");
}

- (void)testPassCharBlockInvocation {
	BOOL(^block)(char) = ^BOOL(char val) {
		return (val == 'Z');
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes:"c@:c"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock:block methodSignature:siggy];

	char firstArgument = 'Z';
	[inv setArgument:&firstArgument atIndex:0];

	[inv invoke];

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass char block test didn't return right value");
}

- (void)testPassUCharBlockInvocation {
	BOOL(^block)(unsigned char) = ^BOOL(unsigned char val) {
		return (val == 'Z');
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes:"c@:C"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock:block methodSignature:siggy];

	unsigned char firstArgument = 'Z';
	[inv setArgument:&firstArgument atIndex:0];

	[inv invoke];

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass unsigned char block test didn't return right value");
}

- (void)testPassShortBlockInvocation {
	BOOL(^block)(short) = ^BOOL(short val) {
		return (val == SHRT_MAX);
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes:"c@:s"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock:block methodSignature:siggy];

	short firstArgument = SHRT_MAX;
	[inv setArgument:&firstArgument atIndex:0];

	[inv invoke];

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass short block test didn't return right value");
}

- (void)testPassUShortBlockInvocation {
	BOOL(^block)(unsigned short) = ^BOOL(unsigned short val) {
		return (val == USHRT_MAX);
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes:"c@:S"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock:block methodSignature:siggy];

	unsigned short firstArgument = USHRT_MAX;
	[inv setArgument:&firstArgument atIndex:0];

	[inv invoke];

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass unsigned short block test didn't return right value");
}

- (void)testPassIntBlockInvocation {
	BOOL(^block)(int) = ^BOOL(int val) {
		return (val == INT_MAX);
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes:"c@:i"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock:block methodSignature:siggy];

	int firstArgument = INT_MAX;
	[inv setArgument:&firstArgument atIndex:0];

	[inv invoke];

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass int block test didn't return right value");
}

- (void)testPassUIntBlockInvocation {
	BOOL(^block)(unsigned int) = ^BOOL(unsigned int val) {
		return (val == UINT_MAX);
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes:"c@:I"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock:block methodSignature:siggy];

	unsigned int firstArgument = UINT_MAX;
	[inv setArgument:&firstArgument atIndex:0];

	[inv invoke];

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass unsigned int block test didn't return right value");
}

- (void)testPassLongBlockInvocation {
	BOOL(^block)(long) = ^BOOL(long val) {
		return (val == LONG_MAX);
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes:"c@:l"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock:block methodSignature:siggy];

	long firstArgument = LONG_MAX;
	[inv setArgument:&firstArgument atIndex:0];

	[inv invoke];

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass long block test didn't return right value");
}

- (void)testPassULongBlockInvocation {
	BOOL(^block)(unsigned long) = ^BOOL(unsigned long val) {
		return (val == ULONG_MAX);
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes:"c@:L"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock:block methodSignature:siggy];

	unsigned long firstArgument = ULONG_MAX;
	[inv setArgument:&firstArgument atIndex:0];

	[inv invoke];

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass unsigned long block test didn't return right value");
}

- (void)testPassLongLongBlockInvocation {
	BOOL(^block)(long long) = ^BOOL(long long val) {
		return (val == LLONG_MAX);
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes:"c@:q"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock:block methodSignature:siggy];

	long long firstArgument = LLONG_MAX;
	[inv setArgument:&firstArgument atIndex:0];

	[inv invoke];

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass long long block test didn't return right value");
}

- (void)testPassULongLongBlockInvocation {
	BOOL(^block)(unsigned long long) = ^BOOL(unsigned long long val) {
		return (val == ULLONG_MAX);
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes:"c@:Q"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock:block methodSignature:siggy];

	unsigned long long firstArgument = ULLONG_MAX;
	[inv setArgument:&firstArgument atIndex:0];

	[inv invoke];

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass unsigned long long block test didn't return right value");
}

- (void)testPassFloatBlockInvocation {
	BOOL(^block)(float) = ^BOOL(float val) {
		return (val == 1.01f);
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes:"c@:f"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock:block methodSignature:siggy];

	float firstArgument = 1.01f;
	[inv setArgument:&firstArgument atIndex:0];

	[inv invoke];

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass float block test didn't return right value");
}

- (void)testPassDoubleBlockInvocation {
	BOOL(^block)(double) = ^BOOL(double val) {
		return (val == 1.01);
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes:"c@:d"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock:block methodSignature:siggy];

	double firstArgument = 1.01;
	[inv setArgument:&firstArgument atIndex:0];

	[inv invoke];

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass double block test didn't return right value");
}

- (void)testPassArrayBlockInvocation {
	BOOL(^block)(int []) = ^BOOL(int *ary) {
		return ary[0] == 1 && ary[1] == 2 && ary[2] == 3 && ary[3] == 4 && ary[4] == 5;
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes:"c@:^i"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock:block methodSignature:siggy];

	int firstArgument[5] = { 1, 2, 3, 4, 5 };
	int *indirect = firstArgument;
	[inv setArgument:&indirect atIndex:0];

	[inv invoke];

	BOOL output;
	[inv getReturnValue:&output];
	XCTAssertTrue(output, @"Pass integer array block test didn't return right value");

}

- (void)testPassStructBlockInvocation
{
	NSString *(^block)(BigStruct) = ^NSString *(BigStruct sret) {
		return (sret.doubleValue == 92.4 && sret.integerValue == 42 && !strcmp(sret.stringValue, "Test") && sret.first && !sret.second) ? @"YES" : @"NO";
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes:"@@:{_BigStruct=di*cc}"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock:block methodSignature:siggy];

	int val = 42;
	NSString *str = @"Test";
	BigStruct ret;
	ret.doubleValue = val * 2.2;
	ret.integerValue = val;
	ret.stringValue = str.UTF8String;
	ret.first = YES;
	ret.second = NO;
	[inv setArgument:&ret atIndex:0];

	[inv invoke];

	NSString *output;
	[inv getReturnValue:&output];
	XCTAssertEqualObjects(output, @"YES", @"Object return block test didn't return right value");
}
- (void)testRetainArgumentsBeforeSetting
{
	NSString *(^block)(BigStruct, id, char*) = ^NSString *(BigStruct sret, id object, char *string) {
		return (sret.doubleValue == 92.4 && sret.integerValue == 42 && !strcmp(sret.stringValue, "Test") && sret.first && !sret.second && [object boolValue] && !strcmp(string, "Hello, World")) ? @"YES" : @"NO";
	};
	
	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes:"@@:{_BigStruct=di*cc}@*"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock:block methodSignature:siggy];
	[inv retainArguments];
	
	int val = 42;
	NSString *str = @"Test";
	BigStruct ret;
	ret.doubleValue = val * 2.2;
	ret.integerValue = val;
	ret.stringValue = str.UTF8String;
	ret.first = YES;
	ret.second = NO;
	[inv setArgument:&ret atIndex:0];
	
	id object = @YES;
	[inv setArgument:&object atIndex:1];
	
	char *cstr = "Hello, World";
	[inv setArgument:&cstr atIndex:2];
	
	[inv invoke];
	
	NSString *output;
	[inv getReturnValue:&output];
	XCTAssertEqualObjects(output, @"YES", @"Object return block test didn't return right value");
}
- (void)testRetainArgumentsAfterSetting
{
	NSString *(^block)(BigStruct, id, char*) = ^NSString *(BigStruct sret, id object, char *string) {
		return (sret.doubleValue == 92.4 && sret.integerValue == 42 && !strcmp(sret.stringValue, "Test") && sret.first && !sret.second && [object boolValue] && !strcmp(string, "Hello, World")) ? @"YES" : @"NO";
	};
	
	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes:"@@:{_BigStruct=di*cc}@*"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock:block methodSignature:siggy];
	
	int val = 42;
	NSString *str = @"Test";
	BigStruct ret;
	ret.doubleValue = val * 2.2;
	ret.integerValue = val;
	ret.stringValue = str.UTF8String;
	ret.first = YES;
	ret.second = NO;
	[inv setArgument:&ret atIndex:0];
	
	id object = @YES;
	[inv setArgument:&object atIndex:1];
	
	char *cstr = "Hello, World";
	[inv setArgument:&cstr atIndex:2];
	
	[inv retainArguments];

	[inv invoke];
	
	NSString *output;
	[inv getReturnValue:&output];
	XCTAssertEqualObjects(output, @"YES", @"Object return block test didn't return right value");
}
- (void)testClearArguments
{
	NSString *(^block)(BigStruct, id, char*) = ^NSString *(BigStruct sret, id object, char *string) {
		return (sret.doubleValue == 92.4 && sret.integerValue == 42 && !strcmp(sret.stringValue, "Test") && sret.first && !sret.second && [object boolValue] && !strcmp(string, "Hello, World")) ? @"YES" : @"NO";
	};
	
	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes:"@@:{_BigStruct=di*cc}@*"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock:block methodSignature:siggy];
	
	int val = 42;
	NSString *str = @"Test";
	BigStruct ret;
	ret.doubleValue = val * 2.2;
	ret.integerValue = val;
	ret.stringValue = str.UTF8String;
	ret.first = YES;
	ret.second = NO;
	[inv setArgument:&ret atIndex:0];
	
	id object = @YES;
	[inv setArgument:&object atIndex:1];
	
	char *cstr = "Hello, World";
	[inv setArgument:&cstr atIndex:2];
	
	XCTAssertNoThrow([inv clearArguments], @"-clearArguments should not throw an exception");
}
- (void)testClearRetainedArguments
{
	NSString *(^block)(BigStruct, id, char*) = ^NSString *(BigStruct sret, id object, char *string) {
		return (sret.doubleValue == 92.4 && sret.integerValue == 42 && !strcmp(sret.stringValue, "Test") && sret.first && !sret.second && [object boolValue] && !strcmp(string, "Hello, World")) ? @"YES" : @"NO";
	};
	
	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes:"@@:{_BigStruct=di*cc}@*"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock:block methodSignature:siggy];
	
	int val = 42;
	NSString *str = @"Test";
	BigStruct ret;
	ret.doubleValue = val * 2.2;
	ret.integerValue = val;
	ret.stringValue = str.UTF8String;
	ret.first = YES;
	ret.second = NO;
	[inv setArgument:&ret atIndex:0];
	
	id object = @YES;
	[inv setArgument:&object atIndex:1];
	
	char *cstr = "Hello, World";
	[inv setArgument:&cstr atIndex:2];
	
	[inv retainArguments];
	
	XCTAssertNoThrow([inv clearArguments], @"-clearArguments should not throw an exception");
}

- (void)test_arm64_argumentAlign
{
    NSString *(^block)(char w0, char w1, char w2, char w3, char w4, char w5, char w6, char w7, char s0, char s1) = ^NSString *(char w0, char w1, char w2, char w3, char w4, char w5, char w6, char w7, char s0, char s1) {
        return (w0 == 'a' && w1 == 'b' && w2 == 'c' && w3 == 'd' && w4 == 'e' && w5 == 'f' && w6 == 'g' && w7 == 'h' && s0 == 'i' && s1 == 'j') ? @"YES" : @"NO";
	};
    
	A2BlockInvocation *inv = nil;
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"@@:cccccccccc"];
    XCTAssertNoThrow((inv = [[A2BlockInvocation alloc] initWithBlock:block methodSignature:signature]));
    XCTAssertNotNil(inv);
    
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
    [inv setArgument:&a1 atIndex:0];
    [inv setArgument:&a2 atIndex:1];
    [inv setArgument:&a3 atIndex:2];
    [inv setArgument:&a4 atIndex:3];
    [inv setArgument:&a5 atIndex:4];
    [inv setArgument:&a6 atIndex:5];
    [inv setArgument:&a7 atIndex:6];
    [inv setArgument:&a8 atIndex:7];
    [inv setArgument:&a9 atIndex:8];
    [inv setArgument:&a10 atIndex:9];
    
	XCTAssertNoThrow([inv invoke]);
	
	NSString *output;
	[inv getReturnValue:&output];
	XCTAssertEqualObjects(output, @"YES", @"Object return block test didn't return right value");
}

- (void)test_arm64_argumentAlignStructOnStack
{
    NSString *(^block)(char w0, char w1, char w2, char w3, char w4, char w5, char w6, char w7, BigStruct sret) = ^NSString *(char w0, char w1, char w2, char w3, char w4, char w5, char w6, char w7, BigStruct sret) {
        return (w0 == 'a' && w1 == 'b' && w2 == 'c' && w3 == 'd' && w4 == 'e' && w5 == 'f' && w6 == 'g' && w7 == 'h' && sret.doubleValue == 92.4 && sret.integerValue == 42 && !strcmp(sret.stringValue, "Test") && sret.first && !sret.second) ? @"YES" : @"NO";
	};
    
	A2BlockInvocation *inv = nil;
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"@@:cccccccc{_BigStruct=di*cc}"];
    XCTAssertNoThrow((inv = [[A2BlockInvocation alloc] initWithBlock:block methodSignature:signature]));
    XCTAssertNotNil(inv);
    
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
    
    [inv setArgument:&a1 atIndex:0];
    [inv setArgument:&a2 atIndex:1];
    [inv setArgument:&a3 atIndex:2];
    [inv setArgument:&a4 atIndex:3];
    [inv setArgument:&a5 atIndex:4];
    [inv setArgument:&a6 atIndex:5];
    [inv setArgument:&a7 atIndex:6];
    [inv setArgument:&a8 atIndex:7];
    [inv setArgument:&a9 atIndex:8];
    
	XCTAssertNoThrow([inv invoke]);
	
	NSString *output;
	[inv getReturnValue:&output];
	XCTAssertEqualObjects(output, @"YES", @"Object return block test didn't return right value");
}

@end
