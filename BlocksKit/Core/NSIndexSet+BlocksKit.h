//
//  NSIndexSet+BlocksKit.h
//  BlocksKit
//

#import "BKDefines.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** Block extensions for NSIndexSet.

 Both inspired by and resembling Smalltalk syntax, these utilities
 allows for iteration of an array in a concise way that
 saves quite a bit of boilerplate code for filtering or finding
 objects or an object.

 Includes code by the following:

- [Robin Lu](https://github.com/robin)
- [Michael Ash](https://github.com/mikeash)
- [Zach Waldowski](https://github.com/zwaldowski)
- [Kaelin Colclasure]<https://github.com/kaelin>

 @see NSArray(BlocksKit)
 @see NSDictionary(BlocksKit)
 @see NSSet(BlocksKit)
 */
@interface NSIndexSet (BlocksKit)

/** Loops through an index set and executes the given block at each index.

 @param block A single-argument, void-returning code block.
 */
- (void)bk_each:(void (^)(NSUInteger index))block;

/** Enumerates each index in an index set concurrently and executes the
 given block once per index.

 Enumeration will occur on appropriate background queues.
 Be aware that the block will not necessarily be executed
 in order for each index.

 @param block A single-argument, void-returning code block.
 */
- (void)bk_apply:(void (^)(NSUInteger index))block;

/** Loops through an array and returns the index matching the block.

 @param block A single-argument, `BOOL`-returning code block.
 @return Returns the index if found, `NSNotFound` otherwise.
 @see bk_select:
 */
- (NSUInteger)bk_match:(BOOL (^)(NSUInteger index))block;

/** Loops through an index set and returns an all indexes matching the block.

 @param block A single-argument, BOOL-returning code block.
 @return Returns an index set of matching indexes found.
 @see bk_match:
 */
- (NSIndexSet *)bk_select:(BOOL (^)(NSUInteger index))block;

/** Loops through an index set and returns an all indexes but the ones matching the block.

 This selector performs *literally* the exact same function as bk_select: but in reverse.

 @param block A single-argument, BOOL-returning code block.
 @return Returns an index set of all indexes but those matched.
 */
- (NSIndexSet *)bk_reject:(BOOL (^)(NSUInteger index))block;

/** Call the block once for each index and create an index set with the new values.

 @param block A block that returns a new index for an index.
 @return An index set of the indexes returned by the block.
 */
- (NSIndexSet *)bk_map:(NSUInteger (^)(NSUInteger index))block;

/** Call the block once for each index and create an array of the return values.

 This method allows transforming indexes into objects:
	 int values[10] = { 1, 2, 4, 8, 16, 32, 64, 128, 256, 512 };
	 NSIndexSet *idxs = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 10)];
	 NSArray *new = [idxs mapIndex:^id(NSUInteger index) {
	   return [NSNumber numberWithInt:values[index]]);
	 }];

 @param block A block that returns an object for an index.
 @return Returns an array of the objects returned by the block.
 */
- (NSArray *)bk_mapIndex:(id (^)(NSUInteger index))block;

/** Loops through an index set to find whether any of the indexes matche the block.

 This method is similar to the Scala list `exists`. It is functionally
 identical to bk_match: but returns a `BOOL` instead. It is not recommended
 to use bk_any: as a check condition before executing bk_match:, since it would
 require two loops through the index set.

 @param block A single-argument, BOOL-returning code block.
 @return YES for the first time the block returns YES for an index, NO otherwise.
 */
- (BOOL)bk_any:(BOOL (^)(NSUInteger index))block;

/** Loops through an index set to find whether all objects match the block.

 @param block A single-argument, BOOL-returning code block.
 @return YES if the block returns YES for all indexes in the array, NO otherwise.
 */
- (BOOL)bk_all:(BOOL (^)(NSUInteger index))block;

/** Loops through an index set to find whether no objects match the block.

 This selector performs *literally* the exact same function as bk_all: but in reverse.

 @param block A single-argument, BOOL-returning code block.
 @return YES if the block returns NO for all indexes in the array, NO otherwise.
 */
- (BOOL)bk_none:(BOOL (^)(NSUInteger index))block;

@end

NS_ASSUME_NONNULL_END
