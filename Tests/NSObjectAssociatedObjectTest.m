//
//  NSObjectAssociatedObjectTest.m
//  BlocksKit Unit Tests
//
//  Created by Kai Wu on 7/6/11.
//  Copyright (c) 2011-2012 Pandamonia LLC. All rights reserved.
//

#import "NSObjectAssociatedObjectTest.h"
#import "NSObject+BKAssociatedObjects.h"

static char kAssociationKey;
static char kNotFoundKey;

@implementation NSObjectAssociatedObjectTest

- (void)tearDown {
	[self bk_removeAllAssociatedObjects];
}

- (void)testAssociatedRetainValue {
	NSMutableString *subject = [NSMutableString stringWithString:@"Hello"];
	[self bk_associateValue:subject withKey:&kAssociationKey];
	[subject appendString:@" BlocksKit"];

	// Value is retained
	NSString *associated = [self bk_associatedValueForKey:&kAssociationKey];
	STAssertTrue([associated isEqualToString:@"Hello BlocksKit"], @"associated value is %@", associated);
}

- (void)testAssociatedCopyValue {
	NSMutableString *subject = [NSMutableString stringWithString:@"Hello"];
	[self bk_associateCopyOfValue:subject withKey:&kAssociationKey];
	[subject appendString:@" BlocksKit"];

	// Value is copied
	NSString *associated = [self bk_associatedValueForKey:&kAssociationKey];
	STAssertTrue([associated isEqualToString:@"Hello"], @"associated value is %@", associated);
}

- (void)testAssociatedWeakValue {
    CFStringRef string = CFStringCreateWithCString(NULL, "Hello BlocksKit", kCFStringEncodingUTF8);
	[self bk_weaklyAssociateValue:(__bridge NSString *)string withKey:&kAssociationKey];
	CFRelease(string); string = NULL;

	id associated = [self bk_associatedValueForKey:&kAssociationKey];
    NSLog(@"associated %@", associated);
    STAssertNil(associated, @"weak associated values nil");
}

- (void)testAssociatedNotFound {
	NSString *associated = [self bk_associatedValueForKey:&kNotFoundKey];
	STAssertNil(associated,@"associated value is not found for kNotFoundKey");
}

@end
