//
//  NSInvocation+BlocksKit.h
//  BlocksKit
//

#import "BKGlobals.h"

/** BlocksKit extensions for NSInvocation. */
@interface NSInvocation (BlocksKit)

/** Generates an `NSInvocation` instance for a given block.

 	NSInvocation *invocation = [NSInvocation invocationWithTarget: target block: ^(id myObject){
 		[myObject someMethodWithArg:42.0];
 	}];
 
 This returns an invocation with the appropriate target, selector, and arguments
 without creating the buffers yourself. It is only recommended to call a method
 on the argument to the block only once.
 
 Created by [Jonathan Rentzch](https://github.com/rentzsch) as
 `NSInvocation-blocks`.

 @param target The object to "grab" the block invocation from.
 @param block A code block.
 @return A fully-prepared instance of NSInvocation ready to be invoked.
 */
+ (NSInvocation *)invocationWithTarget:(id)target block:(BKSenderBlock)block;

@end
