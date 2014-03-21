//
//  A2BlockInvocation.h
//  BlocksKit
//

#import <Foundation/Foundation.h>

/** An `A2BlockInvocation` is an Objective-C block call rendered static, that
 is, it is an action turned into an object. `A2BlockInvocation` objects are used
 to store and forward closure invocations between objects, primarily by the
 `A2DynamicDelegate` system.

 A block invocation object can be repeatedly dispatched with multiple sets of
 arguments with the same flexibility as NSInvocation. This design makes
 `A2BlockInvocation` extremely useful, because blocks can be used to capture
 scope and a block invocation can be used to save it for later.

 Like `NSInvocation`, `A2BlockInvocation` does not support invocations of
 methods with variadic arguments or union arguments.
 */
@interface A2BlockInvocation : NSObject

/** @name Creating A2BlockInvocation Objects */

/** Returns an `A2BlockInvocation` object able to construct calls to a given
 block using a given method signature.

 The method signature given must be compatible with the signature of the block.
 Generally, this means being all the same except for the selector argument, for
 a block is the first parameter of the block's function dispatch just like
 `self` is the first parameter of a method.

 An example method returning a string for an integer argument would have the
 following properties:
 - Block type signature of `NSString *(^)(int)`
 - Block function definition of `NSString *(*)(id, int)`
 - Block signature of `"@@?i"`
 - Method signature of `"@:i"` or `"@i"`

 @param block An Objective-C block literal
 @param methodSignature An method signature matching the block
 @return An initialized block invocation object
 */
- (instancetype)initWithBlock:(id)block methodSignature:(NSMethodSignature *)methodSignature;

/** @name Getting the Block and Method Signatures */

/// The receiver's method signature, reflecting the block with a selector.
/// Appropriate for use in `-methodSignatureForSelector:`.
@property (nonatomic, strong, readonly) NSMethodSignature *methodSignature;

/// Returns the receiver's block.
@property (nonatomic, copy, readonly) id block;

/** Calls the receiver's block with the arguments from the given invocation,
 providing a buffer containing the block's return value upon return.

 @param inv An instance of NSInvocation with values for its arguments set.
 @param returnValue On return, the block's return value, or `nil` for a void
 return type.
 @param NO if the buffer copies necessary for invocation failed, YES otherwise.
 @see invokeWithInvocation:returnValue:
 */
- (BOOL)invokeWithInvocation:(NSInvocation *)inv returnValue:(out NSValue **)returnValue;

/** Calls the receiver's block with the arguments from the given invocation
 and sets the return value on the given invocation.

 @param inv An instance of NSInvocation with values for its arguments set.
 @see invokeWithInvocation:returnValue:
 */
- (void)invokeWithInvocation:(NSInvocation *)inv;

@end
