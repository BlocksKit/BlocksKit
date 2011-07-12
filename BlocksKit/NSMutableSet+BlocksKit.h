//
//  NSMutableSet+BlocksKit.h
//  BlocksKit
//

#import "BlocksKit_Globals.h"

/** Block extensions for NSMutableSet.
 
 These utilities expound upon the BlocksKit additions
 to the immutable superclass by allowing certain utilities
 to work on an instance of the mutable class, saving memory
 by not creating an immutable copy of the results.
 
 Includes code by the following:
 
 - Martin Schürrer.  <https://github.com/MSch>.     2011. MIT.
 - Zach Waldowski. <https://github.com/zwaldowski>. 2011. MIT.
 
 @see NSSet(BlocksKit)
 */
@interface NSMutableSet (BlocksKit)

/** Filters a mutable set to the objects matching the block.
 
 @param block A single-argument, BOOL-returning code block.
 @see reject:
 */
- (void)performSelect:(BKValidationBlock)block;

/** Filters a mutable set to all objects but the ones matching the block,
 the logical inverse to select:.
 
 @param block A single-argument, BOOL-returning code block.
 @see select:
 */
- (void)performReject:(BKValidationBlock)block;

/** Transform the objects in the set to the results of the block.
 
 This is sometimes referred to as a transform, mutating one of each object:
    [controllers map:^id(id obj) {
      return [obj view];
    }];
 
 @param block A single-argument, object-returning code block.
 */
- (void)performMap:(BKTransformBlock)block;

@end
