//
//  NSObjectAssociatedObjectTest.m
//  BlocksKit Unit Tests
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
	subject = nil;
#warning FIXME
	/*#if BK_HAS_APPKIT
	//zeroing weak reference is not available for iOS
	NSString *associated = [self associatedValueForKey:&kAssociationKey];
	STAssertNil(associated,@"associated value is nil");
	 #endif*/
}

- (void)testAssociatedNotFound {
	NSString *associated = [self associatedValueForKey:&kNotFoundKey];
	STAssertNil(associated,@"associated value is not found for kNotFoundKey");
}

@end
