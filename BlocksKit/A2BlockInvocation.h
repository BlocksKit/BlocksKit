//
//  A2BlockInvocation.h
//  BlocksKit
//

#import "BKGlobals.h"

@interface A2BlockInvocation : NSInvocation

+ (A2BlockInvocation *) invocationWithBlock: (id) block;

- (void) clearArguments;
- (void) invokeUsingInvocation: (NSInvocation *) inv;

@property (nonatomic, copy, readonly) id block;

#pragma mark - Unavailable Methods

+ (NSInvocation *) invocationWithMethodSignature: (NSMethodSignature *) sig NS_UNAVAILABLE;

- (id) target NS_UNAVAILABLE;
- (void) setTarget: (id) target NS_UNAVAILABLE;

- (SEL) selector NS_UNAVAILABLE;
- (void) setSelector: (SEL) selector NS_UNAVAILABLE;

- (void) invokeWithTarget: (id) target NS_UNAVAILABLE;

@end
