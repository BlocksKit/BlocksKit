//
//  NSObjectAssociatedObjectTest.m
//  BlocksKit Unit Tests
//
//  Created by Kai Wu on 7/6/11.
//  Copyright (c) 2011-2012 Pandamonia LLC. All rights reserved.
//

#import "NSObjectAssociatedObjectTest.h"

static char kAssociationKey;
static char kNotFoundKey;

@implementation NSObjectAssociatedObjectTest

- (void)tearDown {
	[self removeAllAssociatedObjects];
}

- (void)testAssociatedRetainValue {
	NSMutableString *subject = [NSMutableString stringWithString: @"Hello"];
	[self associateValue:subject withKey: &kAssociationKey];
	[subject appendString: @" BlocksKit"];

	// Value is retained
	NSString *associated = [self associatedValueForKey: &kAssociationKey];
	STAssertTrue([associated isEqualToString: @"Hello BlocksKit"], @"associated value is %@", associated);
}

- (void)testAssociatedCopyValue {
	NSMutableString *subject = [NSMutableString stringWithString: @"Hello"];
	[self associateCopyOfValue: subject withKey: &kAssociationKey];
	[subject appendString: @" BlocksKit"];

	// Value is copied
	NSString *associated = [self associatedValueForKey: &kAssociationKey];
	STAssertTrue([associated isEqualToString: @"Hello"], @"associated value is %@", associated);
}

- (void)testAssociatedAssignValue {
	NSString *subject = @"Hello BlocksKit";
	[self weaklyAssociateValue:subject withKey:&kAssociationKey];
	void *brokenPtr = (__bridge void *)subject;
	subject = nil;
	void *associated = (__bridge void *)[self associatedValueForKey:&kAssociationKey];
	STAssertEquals(brokenPtr, associated, @"assign associated values equal");
}

- (void)testAssociatedNotFound {
	NSString *associated = [self associatedValueForKey:&kNotFoundKey];
	STAssertNil(associated,@"associated value is not found for kNotFoundKey");
}

@end
