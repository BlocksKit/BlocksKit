//
//  NSDictionary+BlocksKit.h
//  BlocksKit
//

#import "BKGlobals.h"

/** Block extension for NSDictionary.

 Both inspired by and resembling Smalltalk syntax, this utility
 allows iteration of a dictionary in a concise way that
 saves quite a bit of boilerplate code.

 Includes code by the following:

- [Mirko Kiefer](https://github.com/mirkok)
- [Zach Waldowski](https://github.com/zwaldowski)

 @see NSArray(BlocksKit)
 @see NSSet(BlocksKit)
 */
@interface NSDictionary (BlocksKit)

/** Loops through the dictionary and executes the given block using each item.
 
 @param block A block that performs an action using a key/value pair.
 */
- (void)each:(BKKeyValueBlock)block;

/** Enumerates through the dictionary concurrently and executes
 the given block once for each pair.
 
 Enumeration will occur on appropriate background queues;
 the system will spawn threads as need for execution. This
 will have a noticeable speed increase, especially on dual-core
 devices, but you *must* be aware of the thread safety of the
 objects you message from within the block.
 
 @param block A block that performs an action using a key/value pair.
 */
- (void)apply:(BKKeyValueBlock)block;

/** Loops through a dictionary to find the first key/value pair matching the block.
 
 match: is functionally identical to select:, but will stop and return
 the value on the first match.
 
 @param block A BOOL-returning code block for a key/value pair.
 @return The value of the first pair found;
 */
- (id)match:(BKKeyValueValidationBlock)block;

/** Loops through a dictionary to find the key/value pairs matching the block.
 
 @param block A BOOL-returning code block for a key/value pair.
 @return Returns a dictionary of the objects found.
 */
- (NSDictionary *)select:(BKKeyValueValidationBlock)block;

/** Loops through a dictionary to find the key/value pairs not matching the block.
 
 This selector performs *literally* the exact same function as select: but in reverse.
 
 This is useful, as one may expect, for filtering objects.
	 NSDictionary *strings = [userData reject:^BOOL(id key, id value) {
	   return ([obj isKindOfClass:[NSString class]]);
	 }];
 
 @param block A BOOL-returning code block for a key/value pair.
 @return Returns a dictionary of all objects not found.
 */
- (NSDictionary *)reject:(BKKeyValueValidationBlock)block;

/** Call the block once for each object and create a dictionary with the same keys
 and a new set of values.
 
 @param block A block that returns a new value for a key/value pair.
 @return Returns a dictionary of the objects returned by the block.
 */
- (NSDictionary *)map:(BKKeyValueTransformBlock)block;

/** Loops through a dictionary to find whether any key/value pair matches the block.
 
 This method is similar to the Scala list `exists`. It is functionally
 identical to match: but returns a `BOOL` instead. It is not recommended
 to use any: as a check condition before executing match:, since it would
 require two loops through the dictionary.
 
 @param block A two-argument, BOOL-returning code block.
 @return YES for the first time the block returns YES for a key/value pair, NO otherwise.
 */
- (BOOL)any:(BKKeyValueValidationBlock)block;

/** Loops through a dictionary to find whether no key/value pairs match the block.
 
 This selector performs *literally* the exact same function as all: but in reverse.
 
 @param block A two-argument, BOOL-returning code block.
 @return YES if the block returns NO for all key/value pairs in the dictionary, NO otherwise.
 */
- (BOOL)none:(BKKeyValueValidationBlock)block;

/** Loops through a dictionary to find whether all key/value pairs match the block.
 
 @param block A two-argument, BOOL-returning code block.
 @return YES if the block returns YES for all key/value pairs in the dictionary, NO otherwise.
 */
- (BOOL)all:(BKKeyValueValidationBlock)block;

@end
