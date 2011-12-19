//
//  NSObjectAssociatedObjectTest.m
//  BlocksKit Unit Tests
//

#import "NSObjectAssociatedObjectTest.h"

static char kAssociationKey;
static char kNotFoundKey;

@implementation NSObjectAssociatedObjectTest

- (void)tearDown {
    [self associateValue:nil withKey:&kAssociationKey];
}

- (void)testAssociatedRetainValue {
    NSMutableString *subject = [[NSMutableString alloc] initWithString:@"Hello"];
    [self associateValue:subject withKey:&kAssociationKey];
    [subject appendString:@" BlocksKit"];
    [subject release];

    // Value is retained
    NSString *associated = (NSString *)[self associatedValueForKey:&kAssociationKey];
    GHAssertEqualStrings(associated,@"Hello BlocksKit",@"associated value is %@",associated);
}

- (void)testAssociatedCopyValue {
    NSMutableString *subject = [[NSMutableString alloc] initWithString:@"Hello"];
    [self associateCopyOfValue:subject withKey:&kAssociationKey];
    [subject appendString:@" BlocksKit"];
    [subject release];

    // Value is copied
    NSString *associated = (NSString *)[self associatedValueForKey:&kAssociationKey];
    GHAssertEqualStrings(associated,@"Hello",@"associated value is %@",associated);
}

- (void)testAssociatedAssignValue {
    NSString *subject = [[NSString alloc] initWithString:@"Hello BlocksKit"];
    [self weaklyAssociateValue:subject withKey:&kAssociationKey];
    [subject release];
    subject = nil;
#if BK_HAS_APPKIT
    //zeroing weak reference is not available for iOS
    NSString *associated = (NSString *)[self associatedValueForKey:&kAssociationKey];
    GHAssertNil(associated,@"associated value is nil");
#endif
}

- (void)testAssociatedNotFound {
    NSString *subject = [[NSString alloc] initWithString:@"Hello BlocksKit"];
    [self associateValue:subject withKey:&kAssociationKey];
    [subject release];

    NSString *associated = [self associatedValueForKey:&kNotFoundKey];
    GHAssertNil(associated,@"associated value is not found for kNotFoundKey");
}

@end
