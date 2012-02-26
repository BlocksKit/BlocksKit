//
//  NSDictionary+BlocksKit.h
//  %PROJECT
//

#import "BKGlobals.h"

/** Block extension for NSDictionary.

 Both inspired by and resembling Smalltalk syntax, this utility
 allows iteration of a dictionary in a concise way that
 saves quite a bit of boilerplate code.

 Includes code by the following:

- Mirko Kiefer.   <https://github.com/mirkok>.	 2011.
- Zach Waldowski. <https://github.com/zwaldowski>. 2011. MIT.

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

@end
