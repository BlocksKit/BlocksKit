//
//  A2BlockInvocationTests.m
//  BlocksKit Unit Tests
//
//  Created by Zachary Waldowski on 6/5/12.
//  Copyright (c) 2012 Pandamonia LLC. All rights reserved.
//

#import "A2BlockInvocationTests.h"

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

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes: "v@:"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock: block methodSignature: siggy];
	[inv invoke];

	STAssertTrue(ran, @"Void block didn't run");
}

- (void)testReturnObjectBlockInvocation
{
	NSString *(^block)(int, NSString *) = ^(int val, NSString *str){
		return (val == 42 && [str isEqualToString:@"Test"]) ? @"YES" : @"NO";
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes: "@@:i@"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock: block methodSignature: siggy];

	int firstArgument = 42;
	NSString *secondArgument = @"Test";
	[inv setArgument: &firstArgument atIndex: 0];
	[inv setArgument: &secondArgument atIndex: 1];

	[inv invoke];

	NSString *output;
	[inv getReturnValue: &output];
	STAssertEqualObjects(output, @"YES", @"Object return block test didn't return right value");
}

- (void)testReturnStructBlockInvocation {
	BigStruct(^block)(int, NSString *) = ^BigStruct(int val, NSString *str){
		BigStruct ret;
		ret.doubleValue = val * 2.2;
		ret.integerValue = val;
		ret.stringValue = str.UTF8String;
		ret.first = YES;
		ret.second = NO;
		return ret;
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes: "{_BigStruct=di*cc}@:i@"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock: block methodSignature: siggy];

	int firstArgument = 42;
	NSString *secondArgument = @"Test";
	[inv setArgument: &firstArgument atIndex: 0];
	[inv setArgument: &secondArgument atIndex: 1];
	[inv invoke];

	BigStruct output;
	[inv getReturnValue: &output];
	STAssertEquals(output.doubleValue, 92.4, @"Struct return block test didn't return right values");
	STAssertEquals(output.integerValue, 42, @"Struct return block test didn't return right values");
	STAssertTrue(strcmp(output.stringValue, "Test") == 0, @"Struct return block test didn't return right values");
	STAssertEquals(output.first, YES, @"Struct return block test didn't return right values");
	STAssertEquals(output.second, NO, @"Struct return block test didn't return right values");
}

- (void)testPassObjectBlockInvocation {
	BOOL(^block)(int, NSString *) = ^BOOL(int val, NSString *str){
		return (val == 42 && [str isEqualToString:@"Test"]);
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes: "@@:i@"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock: block methodSignature: siggy];

	int firstArgument = 42;
	NSString *secondArgument = @"Test";
	[inv setArgument: &firstArgument atIndex: 0];
	[inv setArgument: &secondArgument atIndex: 1];

	[inv invoke];

	BOOL output;
	[inv getReturnValue: &output];
	STAssertTrue(output, @"Pass object block test didn't return right value");
}

- (void)testPassCharBlockInvocation {
	BOOL(^block)(char) = ^BOOL(char val){
		return (val == 'Z');
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes: "c@:c"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock: block methodSignature: siggy];

	char firstArgument = 'Z';
	[inv setArgument: &firstArgument atIndex: 0];

	[inv invoke];

	BOOL output;
	[inv getReturnValue: &output];
	STAssertTrue(output, @"Pass char block test didn't return right value");
}

- (void)testPassUCharBlockInvocation {
	BOOL(^block)(unsigned char) = ^BOOL(unsigned char val){
		return (val == 'Z');
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes: "c@:C"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock: block methodSignature: siggy];

	unsigned char firstArgument = 'Z';
	[inv setArgument: &firstArgument atIndex: 0];

	[inv invoke];

	BOOL output;
	[inv getReturnValue: &output];
	STAssertTrue(output, @"Pass unsigned char block test didn't return right value");
}

- (void)testPassShortBlockInvocation {
	BOOL(^block)(short) = ^BOOL(short val){
		return (val == SHRT_MAX);
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes: "c@:s"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock: block methodSignature: siggy];

	short firstArgument = SHRT_MAX;
	[inv setArgument: &firstArgument atIndex: 0];

	[inv invoke];

	BOOL output;
	[inv getReturnValue: &output];
	STAssertTrue(output, @"Pass short block test didn't return right value");
}

- (void)testPassUShortBlockInvocation {
	BOOL(^block)(unsigned short) = ^BOOL(unsigned short val){
		return (val == USHRT_MAX);
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes: "c@:S"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock: block methodSignature: siggy];

	unsigned short firstArgument = USHRT_MAX;
	[inv setArgument: &firstArgument atIndex: 0];

	[inv invoke];

	BOOL output;
	[inv getReturnValue: &output];
	STAssertTrue(output, @"Pass unsigned short block test didn't return right value");
}

- (void)testPassIntBlockInvocation {
	BOOL(^block)(int) = ^BOOL(int val){
		return (val == INT_MAX);
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes: "c@:i"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock: block methodSignature: siggy];

	int firstArgument = INT_MAX;
	[inv setArgument: &firstArgument atIndex: 0];

	[inv invoke];

	BOOL output;
	[inv getReturnValue: &output];
	STAssertTrue(output, @"Pass int block test didn't return right value");
}

- (void)testPassUIntBlockInvocation {
	BOOL(^block)(unsigned int) = ^BOOL(unsigned int val){
		return (val == UINT_MAX);
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes: "c@:I"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock: block methodSignature: siggy];

	unsigned int firstArgument = UINT_MAX;
	[inv setArgument: &firstArgument atIndex: 0];

	[inv invoke];

	BOOL output;
	[inv getReturnValue: &output];
	STAssertTrue(output, @"Pass unsigned int block test didn't return right value");
}

- (void)testPassLongBlockInvocation {
	BOOL(^block)(long) = ^BOOL(long val){
		return (val == LONG_MAX);
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes: "c@:l"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock: block methodSignature: siggy];

	long firstArgument = LONG_MAX;
	[inv setArgument: &firstArgument atIndex: 0];

	[inv invoke];

	BOOL output;
	[inv getReturnValue: &output];
	STAssertTrue(output, @"Pass long block test didn't return right value");
}

- (void)testPassULongBlockInvocation {
	BOOL(^block)(unsigned long) = ^BOOL(unsigned long val){
		return (val == ULONG_MAX);
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes: "c@:L"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock: block methodSignature: siggy];

	unsigned long firstArgument = ULONG_MAX;
	[inv setArgument: &firstArgument atIndex: 0];

	[inv invoke];

	BOOL output;
	[inv getReturnValue: &output];
	STAssertTrue(output, @"Pass unsigned long block test didn't return right value");
}

- (void)testPassLongLongBlockInvocation {
	BOOL(^block)(long long) = ^BOOL(long long val){
		return (val == LLONG_MAX);
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes: "c@:q"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock: block methodSignature: siggy];

	long long firstArgument = LLONG_MAX;
	[inv setArgument: &firstArgument atIndex: 0];

	[inv invoke];

	BOOL output;
	[inv getReturnValue: &output];
	STAssertTrue(output, @"Pass long long block test didn't return right value");
}

- (void)testPassULongLongBlockInvocation {
	BOOL(^block)(unsigned long long) = ^BOOL(unsigned long long val){
		return (val == ULLONG_MAX);
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes: "c@:Q"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock: block methodSignature: siggy];

	unsigned long long firstArgument = ULLONG_MAX;
	[inv setArgument: &firstArgument atIndex: 0];

	[inv invoke];

	BOOL output;
	[inv getReturnValue: &output];
	STAssertTrue(output, @"Pass unsigned long long block test didn't return right value");
}

- (void)testPassFloatBlockInvocation {
	BOOL(^block)(float) = ^BOOL(float val){
		return (val == 1.01f);
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes: "c@:f"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock: block methodSignature: siggy];

	float firstArgument = 1.01f;
	[inv setArgument: &firstArgument atIndex: 0];

	[inv invoke];

	BOOL output;
	[inv getReturnValue: &output];
	STAssertTrue(output, @"Pass float block test didn't return right value");
}

- (void)testPassDoubleBlockInvocation {
	BOOL(^block)(double) = ^BOOL(double val){
		return (val == 1.01);
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes: "c@:d"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock: block methodSignature: siggy];

	double firstArgument = 1.01;
	[inv setArgument: &firstArgument atIndex: 0];

	[inv invoke];

	BOOL output;
	[inv getReturnValue: &output];
	STAssertTrue(output, @"Pass double block test didn't return right value");
}

- (void)testPassArrayBlockInvocation {
	BOOL(^block)(int []) = ^BOOL(int *ary){
		return ary[0] == 1 && ary[1] == 2 && ary[2] == 3 && ary[3] == 4 && ary[4] == 5;
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes: "c@:^i"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock: block methodSignature: siggy];

	int firstArgument[5] = { 1, 2, 3, 4, 5 };
	int *indirect = firstArgument;
	[inv setArgument: &indirect atIndex: 0];

	[inv invoke];

	BOOL output;
	[inv getReturnValue: &output];
	STAssertTrue(output, @"Pass integer array block test didn't return right value");

}

- (void)testPassStructBlockInvocation
{
	NSString *(^block)(BigStruct) = ^NSString *(BigStruct sret){
		return (sret.doubleValue == 92.4 && sret.integerValue == 42 && !strcmp(sret.stringValue, "Test") && sret.first && !sret.second) ? @"YES" : @"NO";
	};

	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes: "@@:{_BigStruct=di*cc}"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock: block methodSignature: siggy];

	int val = 42;
	NSString *str = @"Test";
	BigStruct ret;
	ret.doubleValue = val * 2.2;
	ret.integerValue = val;
	ret.stringValue = str.UTF8String;
	ret.first = YES;
	ret.second = NO;
	[inv setArgument: &ret atIndex: 0];

	[inv invoke];

	NSString *output;
	[inv getReturnValue: &output];
	STAssertEqualObjects(output, @"YES", @"Object return block test didn't return right value");
}
- (void)testRetainArgumentsBeforeSetting
{
	NSString *(^block)(BigStruct, id, char*) = ^NSString *(BigStruct sret, id object, char *string){
		return (sret.doubleValue == 92.4 && sret.integerValue == 42 && !strcmp(sret.stringValue, "Test") && sret.first && !sret.second && [object boolValue] && !strcmp(string, "Hello, World")) ? @"YES" : @"NO";
	};
	
	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes: "@@:{_BigStruct=di*cc}@*"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock: block methodSignature: siggy];
	[inv retainArguments];
	
	int val = 42;
	NSString *str = @"Test";
	BigStruct ret;
	ret.doubleValue = val * 2.2;
	ret.integerValue = val;
	ret.stringValue = str.UTF8String;
	ret.first = YES;
	ret.second = NO;
	[inv setArgument: &ret atIndex: 0];
	
	id object = @YES;
	[inv setArgument: &object atIndex: 1];
	
	char *cstr = "Hello, World";
	[inv setArgument: &cstr atIndex: 2];
	
	[inv invoke];
	
	NSString *output;
	[inv getReturnValue: &output];
	STAssertEqualObjects(output, @"YES", @"Object return block test didn't return right value");
}
- (void)testRetainArgumentsAfterSetting
{
	NSString *(^block)(BigStruct, id, char*) = ^NSString *(BigStruct sret, id object, char *string){
		return (sret.doubleValue == 92.4 && sret.integerValue == 42 && !strcmp(sret.stringValue, "Test") && sret.first && !sret.second && [object boolValue] && !strcmp(string, "Hello, World")) ? @"YES" : @"NO";
	};
	
	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes: "@@:{_BigStruct=di*cc}@*"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock: block methodSignature: siggy];
	
	int val = 42;
	NSString *str = @"Test";
	BigStruct ret;
	ret.doubleValue = val * 2.2;
	ret.integerValue = val;
	ret.stringValue = str.UTF8String;
	ret.first = YES;
	ret.second = NO;
	[inv setArgument: &ret atIndex: 0];
	
	id object = @YES;
	[inv setArgument: &object atIndex: 1];
	
	char *cstr = "Hello, World";
	[inv setArgument: &cstr atIndex: 2];
	
	[inv retainArguments];

	[inv invoke];
	
	NSString *output;
	[inv getReturnValue: &output];
	STAssertEqualObjects(output, @"YES", @"Object return block test didn't return right value");
}
- (void)testClearArguments
{
	NSString *(^block)(BigStruct, id, char*) = ^NSString *(BigStruct sret, id object, char *string){
		return (sret.doubleValue == 92.4 && sret.integerValue == 42 && !strcmp(sret.stringValue, "Test") && sret.first && !sret.second && [object boolValue] && !strcmp(string, "Hello, World")) ? @"YES" : @"NO";
	};
	
	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes: "@@:{_BigStruct=di*cc}@*"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock: block methodSignature: siggy];
	
	int val = 42;
	NSString *str = @"Test";
	BigStruct ret;
	ret.doubleValue = val * 2.2;
	ret.integerValue = val;
	ret.stringValue = str.UTF8String;
	ret.first = YES;
	ret.second = NO;
	[inv setArgument: &ret atIndex: 0];
	
	id object = @YES;
	[inv setArgument: &object atIndex: 1];
	
	char *cstr = "Hello, World";
	[inv setArgument: &cstr atIndex: 2];
	
	STAssertNoThrow([inv clearArguments], @"-clearArguments should not throw an exception");
}
- (void)testClearRetainedArguments
{
	NSString *(^block)(BigStruct, id, char*) = ^NSString *(BigStruct sret, id object, char *string){
		return (sret.doubleValue == 92.4 && sret.integerValue == 42 && !strcmp(sret.stringValue, "Test") && sret.first && !sret.second && [object boolValue] && !strcmp(string, "Hello, World")) ? @"YES" : @"NO";
	};
	
	NSMethodSignature *siggy = [NSMethodSignature signatureWithObjCTypes: "@@:{_BigStruct=di*cc}@*"];
	A2BlockInvocation *inv = [[A2BlockInvocation alloc] initWithBlock: block methodSignature: siggy];
	
	int val = 42;
	NSString *str = @"Test";
	BigStruct ret;
	ret.doubleValue = val * 2.2;
	ret.integerValue = val;
	ret.stringValue = str.UTF8String;
	ret.first = YES;
	ret.second = NO;
	[inv setArgument: &ret atIndex: 0];
	
	id object = @YES;
	[inv setArgument: &object atIndex: 1];
	
	char *cstr = "Hello, World";
	[inv setArgument: &cstr atIndex: 2];
	
	[inv retainArguments];
	
	STAssertNoThrow([inv clearArguments], @"-clearArguments should not throw an exception");
}

@end
