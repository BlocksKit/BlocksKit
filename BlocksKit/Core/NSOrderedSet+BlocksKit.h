//
//  NSOrderedSet+BlocksKit.h
//  BlocksKit
//

#import "BKDefines.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** Block extensions for NSOrderedSet.

 Both inspired by and resembling Smalltalk syntax, these utilities allow for
 iteration through an ordered set (also known as a uniqued array) in a concise
 way that saves a ton of boilerplate code for filtering or finding objects.

 Includes code by the following:

 - Robin Lu. <https://github.com/robin>. 2009.
 - Michael Ash. <https://github.com/mikeash>. 2010. BSD.
 - Aleks Nesterow. <https://github.com/nesterow>. 2010. BSD.
 - Zach Waldowski. <https://github.com/zwaldowski>. 2011.

 @see NSArray(BlocksKit)
 @see NSSet(BlocksKit)
 */
@interface __GENERICS(NSOrderedSet, ObjectType) (BlocksKit)

/** Loops through an ordered set and executes the given block with each object.

 @param block A single-argument, void-returning code block.
 */
- (void)bk_each:(void (^)(ObjectType obj))block;

/** Enumerates through an ordered set concurrently and executes the given block
 once for each object.

 Enumeration will occur on appropriate background queues. This will have a
 noticeable speed increase, especially on multi-core devices, but you *must*
 be aware of the thread safety of the objects you message from within the block.
 Be aware that the order of objects is not necessarily the order each block will
 be called in.

 @param block A single-argument, void-returning code block.
 */
- (void)bk_apply:(void (^)(ObjectType obj))block;

/** Loops through an ordered set to find the object matching the block.

 bk_match: is functionally identical to bk_select:, but will stop and return
 on the first match.

 @param block A single-argument, `BOOL`-returning code block.
 @return Returns the object, if found, or `nil`.
 @see bk_select:
 */
- (nullable id)bk_match:(BOOL (^)(ObjectType obj))block;

/** Loops through an ordered set to find the objects matching the block.

 @param block A single-argument, BOOL-returning code block.
 @return Returns an ordered set of the objects found.
 @see bk_match:
 */
- (NSOrderedSet *)bk_select:(BOOL (^)(ObjectType obj))block;

/** Loops through an ordered set to to find the objects not matching the block.

 This selector performs *literally* the exact same function as bk_select: but in
 reverse.

 This is useful, as one may expect, for removing objects from an ordered set to.
	 NSOrderedSet *new = [computers bk_reject:^BOOL(id obj) {
		 return ([obj isUgly]);
	 }];

 @param block A single-argument, BOOL-returning code block.
 @return Returns an ordered set of all objects not found.
 */
- (NSOrderedSet *)bk_reject:(BOOL (^)(ObjectType obj))block;

/** Call the block once for each object and create an ordered set of the return
 values.

 This is sometimes referred to as a transform, mutating one of each object:
	 NSOrderedSet *new = [stringArray bk_map:^id(id obj) {
		 return [obj stringByAppendingString:@".png"]);
	 }];

 @param block A single-argument, object-returning code block.
 @return Returns an ordered set of the objects returned by the block.
 */
- (NSOrderedSet *)bk_map:(id (^)(ObjectType obj))block;

/** Arbitrarily accumulate objects using a block.

 The concept of this selector is difficult to illustrate in words. The sum can
 be any NSObject, including (but not limited to) a string, number, or value.

 For example, you can concentate the strings in an ordered set:
	 NSString *concentrated = [stringArray bk_reduce:@"" withBlock:^id(id sum, id obj) {
		 return [sum stringByAppendingString:obj];
	 }];

 You can also do something like summing the lengths of strings in an ordered set:
	 NSUInteger value = [[[stringArray bk_reduce:nil withBlock:^id(id sum, id obj) {
		 return @([sum integerValue] + obj.length);
	 }]] unsignedIntegerValue];

 @param initial The value of the reduction at its start.
 @param block A block that takes the current sum and the next object to return the new sum.
 @return An accumulated value.
 */
- (nullable id)bk_reduce:(nullable id)initial withBlock:(__nullable id (^)(__nullable id sum, ObjectType obj))block;

/** Loops through an ordered set to find whether any object matches the block.

 This method is similar to the Scala list `exists`. It is functionally
 identical to bk_match: but returns a `BOOL` instead. It is not recommended
 to use bk_any: as a check condition before executing bk_match:, since it would
 require two loops through the ordered set.

 For example, you can find if a string in an ordered set starts with a certain
 letter:

	 NSString *letter = @"A";
	 BOOL containsLetter = [stringArray bk_any:^(id obj) {
		 return [obj hasPrefix:@"A"];
	 }];

 @param block A single-argument, BOOL-returning code block.
 @return YES for the first time the block returns YES for an object, NO otherwise.
 */
- (BOOL)bk_any:(BOOL (^)(ObjectType obj))block;

/** Loops through an ordered set to find whether no objects match the block.

 This selector performs *literally* the exact same function as bk_all: but in reverse.

 @param block A single-argument, BOOL-returning code block.
 @return YES if the block returns NO for all objects in the ordered set, NO
 otherwise.
 */
- (BOOL)bk_none:(BOOL (^)(ObjectType obj))block;

/** Loops through an ordered set to find whether all objects match the block.

 @param block A single-argument, BOOL-returning code block.
 @return YES if the block returns YES for all objects in the ordered set, NO
 otherwise.
 */
- (BOOL)bk_all:(BOOL (^)(ObjectType obj))block;

/** Tests whether every element of this ordered set relates to the corresponding
 element of another array according to match by block.

 For example, finding if a list of numbers corresponds to their sequenced string values;

	 NSArray *numbers = @[ @(1), @(2), @(3) ];
	 NSArray *letters = @[ @"1", @"2", @"3" ];
	 BOOL doesCorrespond = [numbers bk_corresponds:letters withBlock:^(id number, id letter) {
		 return [[number stringValue] isEqualToString:letter];
	 }];

 @param list An array of objects to compare with.
 @param block A two-argument, BOOL-returning code block.
 @return Returns a BOOL, true if every element of the ordered set relates to
 corresponding element in another ordered set.
 */
- (BOOL)bk_corresponds:(NSOrderedSet *)list withBlock:(BOOL (^)(ObjectType obj1, id obj2))block;
@end

NS_ASSUME_NONNULL_END
