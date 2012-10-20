//
//  A2BlockInvocation.h
//  BlocksKit
//

#import "BKGlobals.h"

@interface A2BlockInvocation : NSObject

- (id) initWithBlock: (id) block methodSignature: (NSMethodSignature *)methodSignature;

@property (nonatomic, copy, readonly) id block;

@property (nonatomic, strong, readonly) NSMethodSignature *methodSignature;
@property (nonatomic, strong, readonly) NSMethodSignature *blockSignature;

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
