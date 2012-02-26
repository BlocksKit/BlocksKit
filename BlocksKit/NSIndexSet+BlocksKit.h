//
//  NSIndexSet+BlocksKit.h
//  %PROJECT
//

#import "BKGlobals.h"

/** Block extensions for NSIndexSet.

 Both inspired by and resembling Smalltalk syntax, these utilities
 allows for iteration of an array in a concise way that
 saves quite a bit of boilerplate code for filtering or finding
 objects or an object.

 Includes code by the following:

- Robin Lu.	   <https://github.com/robin>.	  2009. MIT.
- Michael Ash.	<https://github.com/mikeash>.	2010. BSD.
- Zach Waldowski. <https://github.com/zwaldowski>. 2011. MIT.

 @see NSArray(BlocksKit)
 @see NSDictionary(BlocksKit)
 @see NSSet(BlocksKit)
 */
@interface NSIndexSet (BlocksKit)

/** Loops through an index set and executes the given block at each index.
 
 @param block A single-argument, void-returning code block.
 */
- (void)each:(BKIndexBlock)block;

/** Enumerates each index in an index set concurrently and executes the
 given block once per index.
 
 Enumeration will occur on appropriate background queues. 
 Be aware that the block will not necessarily be executed
 in order for each index.
 
 @param block A single-argument, void-returning code block.
 */
- (void)apply:(BKIndexBlock)block;

/** Loops through an array and returns the index matching the block.
 
 @param block A single-argument, `BOOL`-returning code block.
 @return Returns the index if found, `NSNotFound` otherwise.
 @see select:
 */
- (NSUInteger)match:(BKIndexValidationBlock)block;

/** Loops through an index set and returns an all indexes matching the block.
 
 @param block A single-argument, BOOL-returning code block.
 @return Returns an index set of matching indexes found.
 @see match:
 */
- (NSIndexSet *)select:(BKIndexValidationBlock)block;

/** Loops through an index set and returns an all indexes but the ones matching the block.
 
 This selector performs *literally* the exact same function as select: but in reverse.
 
 @param block A single-argument, BOOL-returning code block.
 @return Returns an index set of all indexes but those matched.
 */
- (NSIndexSet *)reject:(BKIndexValidationBlock)block;

/** Call the block once for each index and create an index set with the new values.
 
 @param block A block that returns a new index for an index.
 @return An index set of the indexes returned by the block.
 */
- (NSIndexSet *)map:(BKIndexTransformBlock)block;

@end
