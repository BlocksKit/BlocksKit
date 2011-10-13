//
//  NSObjectAssociatedObjectTest.m
//  BlocksKit Unit Tests
//

#import "NSObjectAssociatedObjectTest.h"

static NSInteger *kAssociationKey = 0;
static NSInteger *kNotFoundKey = 0;

@implementation NSObjectAssociatedObjectTest

- (BOOL)shouldRunOnMainThread {
  // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
  return NO;
}

- (void)setUpClass {
    // Run at start of all tests in the class
}

- (void)tearDownClass {
    // Run at end of all tests in the class
    [self associateValue:nil withKey:kAssociationKey];
}

- (void)setUp {
    // Run before each test method
    [self associateValue:nil withKey:kAssociationKey];
}

- (void)tearDown {
    // Run after each test method
}

- (void)testAssociatedRetainValue {
    NSMutableString *subject = [[NSMutableString alloc] initWithString:@"Hello"];
    [self associateValue:subject withKey:kAssociationKey];
    [subject appendString:@" BlocksKit"];
    [subject release];

    // Value is retained
    NSString *associated = (NSString *)[self associatedValueForKey:kAssociationKey];
    GHAssertEqualStrings(associated,@"Hello BlocksKit",@"associated value is %@",associated);
}

- (void)testAssociatedCopyValue {
    NSMutableString *subject = [[NSMutableString alloc] initWithString:@"Hello"];
    [self associateCopyOfValue:subject withKey:kAssociationKey];
    [subject appendString:@" BlocksKit"];
    [subject release];

    // Value is copied
    NSString *associated = (NSString *)[self associatedValueForKey:kAssociationKey];
    GHAssertEqualStrings(associated,@"Hello",@"associated value is %@",associated);
}

- (void)testAssociatedAssignValue {
    NSString *subject = [[NSString alloc] initWithString:@"Hello BlocksKit"];
    [self weaklyAssociateValue:subject withKey:kAssociationKey];
    [subject release];
    subject = nil;
#if BK_HAS_APPKIT
    //zeroing weak reference is not available for iOS
    NSString *associated = (NSString *)[self associatedValueForKey:kAssociationKey];
    GHAssertNil(associated,@"associated value is nil");
#endif
}

- (void)testAssociatedNotFound {
    NSString *subject = [[NSString alloc] initWithString:@"Hello BlocksKit"];
    [self associateValue:subject withKey:kAssociationKey];
    [subject release];

    NSString *associated = (NSString *)[self associatedValueForKey:kNotFoundKey];
    GHAssertNil(associated,@"associated value is not found for kNotFoundKey");
}

@end
