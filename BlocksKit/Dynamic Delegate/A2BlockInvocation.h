//
//  A2BlockInvocation.h
//  BlocksKit
//

#import <Foundation/Foundation.h>

/** An `A2BlockInvocation` is an Objective-C block call rendered static, that
 is, it is an action turned into an object. `A2BlockInvocation` objects are used
 to store and forward closure invocations between objects, primarily by the
 `A2DynamicDelegate` system.

 An `A2BlockInvocation` object encapsulates all the elements of an Objective-C
 block invocation, including arguments and the return value. Each of these can
 be set directly, and the return value is set automatically when the object is
 dispatched.

 An `A2BlockInvocation` object can be repeatedly dispatched. Its arguments can
 be modified between dispatches for varying results, making it useful for
 repeating calls with many arguments. This flexibility makes `A2BlockInvocation`
 extremely powerful, because blocks can be used to capture scope and
 `A2BlockInvocation` can be used to save them for later.

 Like `NSInvocation`, `A2BlockInvocation` does not support invocations of
 methods with variadic arguments or union arguments.

 This class does not retain the arguments for the contained call by default. If
 those objects might disappear between the time you create your invocation and
 the time you use it, you should call the retainArguments method to have the
 invocation object retain them itself.

 `A2BlockInvocation` is powered by [libffi](http://sourceware.org/libffi/),
 which serves as a way to call functions like `NSInvocation` calls methods.
 This is the only way to do this for now. Get used to it.
 */
@interface A2BlockInvocation : NSObject

/** @name Creating A2BlockInvocation Objects */

/** Returns an `A2BlockInvocation` object able to construct calls using a given
 block and a given method signature.

 The new object must have its arguments set with setArgument:atIndex: before it
 can be invoked.

 The method signature given must be compatible with the signature of the block.
 Generally, this means being all the same except for the removal of the
 selector argument, for the block is the first parameter of the block's
 function just like `self` is the first parameter of a method. An example method
 that returns a string and has an integer argument would have a block signature
 of `NSString *(^)(int)`, and an Objective-C method signature `@@i`.

 @param block An Objective-C block literal.
 @param methodSignature An Objective-C method signature matching the block.
 @return An initialized block invocation object.
*/
- (id)initWithBlock:(id)block methodSignature:(NSMethodSignature *)methodSignature;

/** @name Getting the Block and Method Signatures */

/** Returns the reciever's method signature. Appropriate for use in
 `methodSignatureForSelector:`, and reflects the method *with* a selector. */
@property (nonatomic, strong, readonly) NSMethodSignature *methodSignature;

/** Returns the reciever's block signature. Intended for use in compatibility
 comparison, and generally not useful. */
@property (nonatomic, strong, readonly) NSMethodSignature *blockSignature;

/** Returns the reciever's block. Can be used to call it manually, if you
 know its signature. */
@property (nonatomic, copy, readonly) id block;

/** @name Configuring a Block Invocation Object */

/** If the receiver hasn’t already done so, retains all object arguments of the
 receiver and copies all of its C-string arguments.

 Before this method is invoked, argumentsRetained returns NO; after, it returns
 YES.

 For efficiency, newly created block invocations don’t retain or copy their
 arguments, nor do they retain their targets or copy C strings. You should
 instruct a block invocation to retain its arguments if you intend to cache it,
 since the arguments may otherwise be released before the NSInvocation is
 invoked.

 Note that objects referenced in the scope of the block are generally retained.

 @see argumentsRetained
 */
- (void)retainArguments;

/** Returns YES if the receiver has retained its arguments, NO otherwise.

 @see retainArguments
 */
@property (nonatomic, readonly) BOOL argumentsRetained;

/** Gets the receiver's return value.

 Use the `NSMethodSignature` method `-methodReturnLength` to determine the size
 needed for the buffer:

	 NSUInteger length = [[myInvocation methodSignature] methodReturnLength];
	 buffer = (void *)malloc(length);
	 [invocation getReturnValue:buffer];

 When the return value is an object (or a pointer), pass a pointer to the
 variable (or memory) into which the object should be placed:

	 id anObject;
	 NSArray *anArray;
	 [invocation1 getReturnValue:&anObject];
	 [invocation2 getReturnValue:&anArray];

 If the block invocation object has never been invoked, the result of this
 method is undefined and is not recommended.

 @param retLoc An untyped buffer into which the receiver copies its return
 value. It should be large enough to accommodate the value. See the discussion
 for more information.
 @see setReturnValue:
 */
- (void)getReturnValue:(void *)retLoc;

/** Sets the receiver’s return value.

 This value is normally set when you send an invoke message.

 @param retLoc An untyped buffer whose contents are copied as the receiver's
 return value.
 @see invoke
 @see getReturnValue:
 */
- (void)setReturnValue:(void *)retLoc;

/** Returns by indirection the receiver's argument at a specified index.

 This method copies the argument stored at index into the storage pointed to by
 buffer. The size of buffer must be large enough to accommodate the argument value.

 When the argument value is an object, pass a pointer to the variable
 (or memory) into which the object should be placed:

	 NSArray *anArray;
	 [invocation getArgument:&anArray atIndex:3];

 This method raises NSInvalidArgumentException if idx is greater than the
 actual number of arguments for the selector.

 @param argumentLocation An untyped buffer to hold the returned argument. See
 the discussion relating to argument values that are objects.
 @param idx An integer specifying the index of the argument to get, starting
 at 0 representing the first argument of the underlying block.
 @see setArgument:atIndex:
 */
- (void)getArgument:(void *)argumentLocation atIndex:(NSInteger)idx;

/** Sets an argument of the receiver.

 This method copies the contents of buffer as the argument at index. The number
 of bytes copied is determined by the argument size.

 When the argument value is an object, pass a pointer to the variable
 (or memory) from which the object should be copied:

	 NSArray *anArray;
	 [invocation setArgument:&anArray atIndex:3];

 This method raises NSInvalidArgumentException if the value of index is greater
 than the actual number of arguments for the selector.

 @param argumentLocation An untyped buffer containing an argument to be assigned
 to the receiver. See the discussion relating to arguments that are objects.
 @param idx An integer specifying the index of the argument, starting at 0
 representing the first argument of the underlying block.
 */
- (void)setArgument:(void *)argumentLocation atIndex:(NSInteger)idx;

/** Unsets all arguments in the block invocation, including releasing any
 objects if argumentsRetained is YES. */
- (void)clearArguments;

/** @name Dispatching an Invocation */

/** Calls the receiver's block (with arguments) and sets the return value.

 You must set the receiver's argument values before calling this method.

 @see setArgument:atIndex:
 @see getReturnValue:
 */
- (void)invoke;

/** Calls the receiver's block with the arguments from the given invocation,
 and sets the return value both on the receiving invocation and the given
 invocation.

 Copying arguments will exclude the target and selector of the given invocation.
 Otherwise, this method raises NSInvalidArgumentException if the number of
 arguments in both invocations are not appropriately matched.

 @param inv An instance of NSInvocation with values for its arguments set.
 @see setArgument:atIndex:
 @see getReturnValue:
 */
- (void)invokeUsingInvocation:(NSInvocation *)inv;

@end
