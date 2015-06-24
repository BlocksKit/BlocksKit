//
//  NSInvocation+BlocksKit.h
//  BlocksKit
//

#import "BKDefines.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** BlocksKit extensions for NSInvocation. */
@interface NSInvocation (BlocksKit)

/** Generates a forwarding `NSInvocation` instance for a given method call
 encapsulated by the given block.

	NSInvocation *invocation = [NSInvocation invocationWithTarget:target block:^(id myObject) {
		[myObject someMethodWithArg:42.0];
	}];

 This returns an invocation with the appropriate target, selector, and arguments
 without creating the buffers yourself. It is only recommended to call a method
 on the argument to the block only once. More complicated forwarding machinery
 can be accomplished by the A2DynamicDelegate family of classes included in
 BlocksKit.

 Created by [Jonathan Rentzch](https://github.com/rentzsch) as
 `NSInvocation-blocks`.

 @param target The object to "grab" the block invocation from.
 @param block A code block.
 @return A fully-prepared instance of NSInvocation ready to be invoked.
 */
+ (NSInvocation *)bk_invocationWithTarget:(id)target block:(void (^)(id target))block;

@end

NS_ASSUME_NONNULL_END
