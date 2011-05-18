//
//  UIGestureRecognizer+BlocksKit.h
//  BlocksKit
//

/** Block initialization for UIGestureRecognizer.
 
 Includes code by the following:
 
 - Kevin O'Neill.  <https://github.com/kevinoneill>. 2011. BSD.
 - Zach Waldowski. <https://github.com/zwaldowski>.  2011. MIT.
 */
@interface UIGestureRecognizer (BlocksKit)

/** An autoreleased gesture recognizer that will call the given block.
  
 @return An initialized and autoreleased instance of a concrete UIGestureRecognizer subclass, or `nil`.
 @param block The block which handles an executed gesture.
 */
+ (id)recognizerWithHandler:(void (^)(id recognizer))block;

/** Initializes an allocated gesture recognizer that will call the given block.

 An alternative to the designated initializer.

 @return An initialized instance of a concrete UIGestureRecognizer subclass or `nil`.
 @param block The block which handles an executed gesture.
 */
- (id)initWithHandler:(void (^)(id recognizer))block;

@end