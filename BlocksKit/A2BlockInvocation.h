//
//  A2BlockInvocation.h
//  BlocksKit
//

#import "BKGlobals.h"

@interface A2BlockInvocation : NSObject

- (id) initWithBlock: (id) block;
@property (nonatomic, copy, readonly) id block;

@property (nonatomic, readonly) NSMethodSignature *methodSignature;

- (void) retainArguments;
- (BOOL) argumentsRetained;

- (void) getReturnValue: (void *) retLoc;
- (void) setReturnValue: (void *) retLoc;

- (void) getArgument: (void *) argumentLocation atIndex: (NSInteger) idx;
- (void) setArgument: (void *) argumentLocation atIndex: (NSInteger) idx;
- (void) clearArguments;

- (void) invoke;
- (void) invokeUsingInvocation: (NSInvocation *) inv;

@end
