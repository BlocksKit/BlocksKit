//
//  NSString+BlocksKit.h
//  BlocksKit

/** Block extensions for NSString.
 A category on NSString that give access to Higher-order functions such as `filter` and `map` as well as some convenience methods for testing strings.
 
 Includes code by the following:
 - [Terry Lewis II]("https://github.com/tLewisII")
 */

#import "BKGlobals.h"

@interface NSString (BlocksKit)
/*!
 *Iterates over the receiver and returns only the values that pass the test of `YES` within the block.
 @param block, a block that contains a string and an index
 @returns A NSString with only those characters that passed the test.
 */
- (NSString *)filter:(BKStringFilterBlock)block;

/*!
 *Returns a new string with the changes applied in `block`.
 @param A block containing a string and an index
 @returns A new string with the given transform applied.
 */
- (NSString *)map:(BKStringTransformBlock)block;

/*!
 *Returns YES if any character in the string passes the test in `block`, returns NO otherwise.
 @param block, a block that contains a string and an index
 @returns A BOOL value indicating if the test was passed
 */
-(BOOL)anyCharacter:(BKStringFilterBlock)block;

/*!
 *Returns YES if any word in the string passes the test in `block`, returns NO otherwise. A word here is defined as being seperated by a space, such as: @" ";.
 @param block, a block that contains a string and an index
 @returns A BOOL value indicating if the test was passed
 */
-(BOOL)anyWord:(BKStringFilterBlock)block;

/*!
 *Returns YES if all character in the string pass the test in `block`, returns NO otherwise.
 @param block, a block that contains a string and an index
 @returns A BOOL value indicating if the test was passed
 */
-(BOOL)allCharacters:(BKStringFilterBlock)block;

/*!
 *Returns YES if all words in the string pass the test in `block`, returns NO otherwise. A word here is defined as being seperated by a space, such as: @" ";.
 @param block, a block that contains a string and an index
 @returns A BOOL value indicating if the test was passed
 */
-(BOOL)allWords:(BKStringFilterBlock)block;

@end
