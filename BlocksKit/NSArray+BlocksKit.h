//
//  NSArray+BlocksKit.h
//  %PROJECT
//

#import "BKGlobals.h"

/** Block extensions for NSArray.

 Both inspired by and resembling Smalltalk syntax, these utilities
 allows for iteration of an array in a concise way that
 saves quite a bit of boilerplate code for filtering or finding
 objects or an object.

 Includes code by the following:

- Robin Lu.	   <https://github.com/robin>.	  2009. MIT.
- Michael Ash.	<https://github.com/mikeash>.	2010. BSD.
- Aleks Nesterow. <https://github.com/nesterow>.   2010. BSD.
- Zach Waldowski. <https://github.com/zwaldowski>. 2011. MIT.

 @see NSDictionary(BlocksKit)
 @see NSSet(BlocksKit)
 */
@interface NSArray (BlocksKit)

/** Loops through an array and executes the given block with each object.
 
 @param block A single-argument, void-returning code block.
 */
- (void)each:(BKSenderBlock)block;

/** Enumerates through an array concurrently and executes
 the given block once for each object.
 
 Enumeration will occur on appropriate background queues. This
 will have a noticeable speed increase, especially on dual-core
 devices, but you *must* be aware of the thread safety of the
 objects you message from within the block. Be aware that the
 order of objects is not necessarily the order each block will
 be called in.
 
 @param block A single-argument, void-returning code block.
 */
- (void)apply:(BKSenderBlock)block;

/** Loops through an array to find the object matching the block.
 
 match: is functionally identical to select:, but will stop and return
 on the first match.
 
 @param block A single-argument, `BOOL`-returning code block.
 @return Returns the object, if found, or `nil`.
 @see select:
 */
- (id)match:(BKValidationBlock)block;

/** Loops through an array to find the objects matching the block.
 
 @param block A single-argument, BOOL-returning code block.
 @return Returns an array of the objects found.
 @see match:
 */
- (NSArray *)select:(BKValidationBlock)block;

/** Loops through an array to find the objects not matching the block.
 
 This selector performs *literally* the exact same function as select: but in reverse.
 
 This is useful, as one may expect, for removing objects from an array.
	 NSArray *new = [computers reject:^BOOL(id obj) {
	   return ([obj isUgly]);
	 }];
 
 @param block A single-argument, BOOL-returning code block.
 @return Returns an array of all objects not found.
 */
- (NSArray *)reject:(BKValidationBlock)block;

/** Call the block once for each object and create an array of the return values.
 
 This is sometimes referred to as a transform, mutating one of each object:
	 NSArray *new = [stringArray map:^id(id obj) {
	   return [obj stringByAppendingString:@".png"]);
	 }];
 
 @param block A single-argument, object-returning code block.
 @return Returns an array of the objects returned by the block.
 */
- (NSArray *)map:(BKTransformBlock)block;

/** Arbitrarily accumulate objects using a block.
 
 The concept of this selector is difficult to illustrate in words. The sum can
 be any NSObject, including (but not limited to) an NSString, NSNumber, or NSValue.
 
 For example, you can concentate the strings in an array:
	 NSString *concentrated = [stringArray reduce:@"" withBlock:^id(id sum, id obj) {
	   return [sum stringByAppendingString:obj];
	 }];
 
 You can also do something like summing the lengths of strings in an array:
	 NSNumber *sum = [stringArray reduce:nil withBlock:^id(id sum, id obj) {
	   return [NSNumber numberWithInteger: [sum integerValue] + obj.length];
	 }];
	 NSUInteger value = [sum integerValue];

 @param initial The value of the reduction at its start.
 @param block A block that takes the current sum and the next object to return the new sum.
 @return An accumulated value.
 */
- (id)reduce:(id)initial withBlock:(BKAccumulationBlock)block;

@end