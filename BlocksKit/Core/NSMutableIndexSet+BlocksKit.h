//
//  NSMutableIndexSet+BlocksKit.h
//  BlocksKit
//

#import <Foundation/Foundation.h>

/** Block extensions for NSMutableIndexSet.

 These utilities expound upon the BlocksKit additions to the immutable
 superclass by allowing certain utilities to work on an instance of the mutable
 class, saving memory by not creating an immutable copy of the results.

 @see NSIndexSet(BlocksKit)
 */
@interface NSMutableIndexSet (BlocksKit)

/** Filters a mutable index set to the indexes matching the block.

 @param block A single-argument, BOOL-returning code block.
 @see <NSIndexSet(BlocksKit)>bk_reject:
 */
- (void)bk_performSelect:(BOOL (^)(NSUInteger index))block;

/** Filters a mutable index set to all indexes but the ones matching the block,
 the logical inverse to bk_select:.

 @param block A single-argument, BOOL-returning code block.
 @see <NSIndexSet(BlocksKit)>bk_select:
 */
- (void)bk_performReject:(BOOL (^)(NSUInteger index))block;

/** Transform each index of the index set to a new index, as returned by the
 block.

 @param block A block that returns a new index for a index.
 @see <NSIndexSet(BlocksKit)>bk_map:
 */
- (void)bk_performMap:(NSUInteger (^)(NSUInteger index))block;


@end
