//
//  NSInvocation+BlocksKit.h
//  %PROJECT
//

#import "BKGlobals.h"

/** Blocks wrapper for NSInvocation.

 Usage example:
	 NSInvocation *invocation = [NSInvocation invocationWithTarget:myObject block:^(id myObject){
	   [myObject someMethodWithArg:42.0];
	 }];
 
 Created by Jonathan Rentzch as [NSInvocation-blocks](https://github.com/rentzsch/NSInvocation-blocks).
 Licensed under MIT.
 */
@interface NSInvocation (BlocksKit)

/** Generates an `NSInvocation` object for a given block.

 @param target The object to "grab" the block invocation from.
 @param block A code block.
 @return A fully-prepared instance of NSInvocation ready to be invoked
 */
+ (NSInvocation *)invocationWithTarget:(id)target block:(BKSenderBlock)block;

@end
