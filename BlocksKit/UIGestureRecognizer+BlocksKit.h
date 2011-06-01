//
//  UIGestureRecognizer+BlocksKit.h
//  BlocksKit
//

#import "BlocksKit_Globals.h"

/** Block initialization for UIGestureRecognizer.

 @warning UIGestureRecognizer is only available on iOS or in a Mac app using Chameleon.
 
 Includes code by the following:
 
 - Kevin O'Neill.  <https://github.com/kevinoneill>. 2011. BSD.
 - Zach Waldowski. <https://github.com/zwaldowski>.  2011. MIT.
 */

@interface UIGestureRecognizer (BlocksKit)

/** An autoreleased gesture recognizer that will call the given block.
  
 @return An initialized and autoreleased instance of a concrete UIGestureRecognizer subclass, or `nil`.
 @param block The block which handles an executed gesture.
 */
+ (id)recognizerWithHandler:(BKSenderBlock)block;

/** Initializes an allocated gesture recognizer that will call the given block.

 An alternative to the designated initializer.

 @return An initialized instance of a concrete UIGestureRecognizer subclass or `nil`.
 @param block The block which handles an executed gesture.
 */
- (id)initWithHandler:(BKSenderBlock)block;

/** Allows the block that will be fired by the gesture recognizer
 to be modified after the fact.
 */
@property (copy) BKSenderBlock handler;

@end