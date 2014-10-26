//
//  A2DynamicTestClasses.m
//  BlocksKit Unit Tests
//

#import "A2DynamicTestClasses.h"

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
	return [self.delegate testWithObject:@"Test"];
}

@end

#pragma mark -

@implementation TestPassChar

- (BOOL)test {
	return [self.delegate testWithChar:'Z'];
}

@end

#pragma mark -

@implementation TestPassUChar

- (BOOL)test {
	return [self.delegate testWithUChar:'Z'];
}

@end

#pragma mark -

@implementation TestPassShort

- (BOOL)test {
	return [self.delegate testWithShort:SHRT_MAX];
}

@end

#pragma mark -

@implementation TestPassUShort

- (BOOL)test {
	return [self.delegate testWithUShort:USHRT_MAX];
}

@end

#pragma mark -

@implementation TestPassInt

- (BOOL)test {
	return [self.delegate testWithInt:INT_MAX];
}

@end

#pragma mark -

@implementation TestPassUInt

- (BOOL)test {
	return [self.delegate testWithUInt:UINT_MAX];
}

@end

#pragma mark -

@implementation TestPassLong

- (BOOL)test {
	return [self.delegate testWithLong:LONG_MAX];
}

@end

#pragma mark -

@implementation TestPassULong

- (BOOL)test {
	return [self.delegate testWithULong:ULONG_MAX];
}

@end

#pragma mark -

@implementation TestPassLongLong

- (BOOL)test {
	return [self.delegate testWithLongLong:LLONG_MAX];
}

@end

#pragma mark -

@implementation TestPassULongLong

- (BOOL)test {
	return [self.delegate testWithULongLong:ULLONG_MAX];
}

@end

#pragma mark -

@implementation TestPassFloat

- (BOOL)test {
	return [self.delegate testWithFloat:1.01f];
}

@end

#pragma mark -

@implementation TestPassDouble

- (BOOL)test {
	return [self.delegate testWithDouble:1.01];
}

@end

#pragma mark -

@implementation TestPassArray

- (BOOL)test {
	int myArray[5] = { 1, 2, 3, 4, 5 };
	return [self.delegate testWithArray:myArray];
}

@end

#pragma mark -

@implementation TestPassStruct

- (BOOL)test {
	MyStruct stret;
	stret.first = YES;
	stret.second = YES;
	return [self.delegate testPassStruct:stret];
}

@end

#pragma mark -

@implementation TestClassMethod

- (BOOL)test {
	return [[self.delegate class] testWithObject:@"Test"];
}


@end
