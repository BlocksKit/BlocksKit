//
//  NSObjectAssociatedObjectTest.m
//  BlocksKit Unit Tests
//
//  Contributed by Kai Wu.
//

#import <XCTest/XCTest.h>
#import <BlocksKit/NSObject+BKAssociatedObjects.h>

@interface NSObjectAssociatedObjectTest : XCTestCase

@end

static void *kAssociationKey = &kAssociationKey;
static void *kNotFoundKey = &kNotFoundKey;

@implementation NSObjectAssociatedObjectTest

- (void)tearDown {
	[self bk_removeAllAssociatedObjects];
}

- (void)testAssociatedRetainValue {
	NSMutableString *subject = [NSMutableString stringWithString:@"Hello"];
	[self bk_associateValue:subject withKey:kAssociationKey];
	[subject appendString:@" BlocksKit"];

	// Value is retained
	NSString *associated = [self bk_associatedValueForKey:kAssociationKey];
	XCTAssertTrue([associated isEqualToString:@"Hello BlocksKit"], @"associated value is %@", associated);
}

- (void)testAssociatedCopyValue {
	NSMutableString *subject = [NSMutableString stringWithString:@"Hello"];
	[self bk_associateCopyOfValue:subject withKey:kAssociationKey];
	[subject appendString:@" BlocksKit"];

	// Value is copied
	NSString *associated = [self bk_associatedValueForKey:kAssociationKey];
	XCTAssertTrue([associated isEqualToString:@"Hello"], @"associated value is %@", associated);
}

- (void)testAssociatedWeakValue {
	CFStringRef string = CFStringCreateWithCString(NULL, "Hello BlocksKit", kCFStringEncodingUTF8);
	[self bk_weaklyAssociateValue:(__bridge NSString *)string withKey:kAssociationKey];
	CFRelease(string); string = NULL;

	id associated = [self bk_associatedValueForKey:kAssociationKey];
	NSLog(@"associated %@", associated);
	XCTAssertNil(associated, @"weak associated values nil");
}

- (void)testAssociatedNotFound {
	NSString *associated = [self bk_associatedValueForKey:kNotFoundKey];
	XCTAssertNil(associated,@"associated value is not found for kNotFoundKey");
}

@end
