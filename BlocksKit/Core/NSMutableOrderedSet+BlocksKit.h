//
//  NSMutableOrderedSet+BlocksKit.h
//  BlocksKit
//

#import <Foundation/Foundation.h>

/** Block extensions for NSMutableOrderedSet.

 These utilities expound upon the BlocksKit additions to the immutable
 superclass by allowing certain utilities to work on an instance of the mutable
 class, saving memory by not creating an immutable copy of the results.

 Includes code by the following:

 - [Martin Schürrer](https://github.com/MSch)
 - [Zach Waldowski](https://github.com/zwaldowski)

 @see NSOrderedSet(BlocksKit)
 */
@interface NSMutableOrderedSet (BlocksKit)

/** Filters a mutable ordered set to the objects matching the block.

 @param block A single-argument, BOOL-returning code block.
 @see <NSOrderedSet(BlocksKit)>bk_reject:
 */
- (void)bk_performSelect:(BOOL (^)(id obj))block;

/** Filters a mutable ordered set to all objects but the ones matching the
 block, the logical inverse to bk_select:.

 @param block A single-argument, BOOL-returning code block.
 @see <NSOrderedSet(BlocksKit)>bk_select:
 */
- (void)bk_performReject:(BOOL (^)(id obj))block;

/** Transform the objects in the ordered set to the results of the block.

 This is sometimes referred to as a transform, mutating one of each object:
	 [foo bk_performMap:^id(id obj) {
		 return [dateTransformer dateFromString:obj];
	 }];

 @param block A single-argument, object-returning code block.
 @see <NSOrderedSet(BlocksKit)>bk_map:
 */
- (void)bk_performMap:(id (^)(id obj))block;

@end
