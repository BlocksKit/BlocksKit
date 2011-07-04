//
//  NSDictionary+BlocksKit.h
//  BlocksKit
//

#import "BlocksKit_Globals.h"

@interface NSDictionaryBlocksKitCategories : NSObject {
}
@end

/** Block extension for NSDictionary.

 Both inspired by and resembling Smalltalk syntax, this utility
 allows iteration of a dictionary in a concise way that
 saves quite a bit of boilerplate code.

 Includes code by the following:

- Mirko Kiefer.   <https://github.com/mirkok>.     2011.
- Zach Waldowski. <https://github.com/zwaldowski>. 2011. MIT.

 @see NSArray(BlocksKit)
 @see NSSet(BlocksKit)
 */
@interface NSDictionary (BlocksKit)

/** Loops through set and executes the given block using each dictionary item.
 
 @param block A block that performs an action using a key/value pair.
 */
- (void)each:(BKKeyValueBlock)block;

/** Call the block once for each object and create a dictionary with the same keys
 and a new set of values.
 
 @param block A block that returns a new value for a key/value pair.
 @return Returns a dictionary of the objects returned by the block.
 */
- (NSDictionary *)map:(BKKeyValueTransformBlock)block;

@end
