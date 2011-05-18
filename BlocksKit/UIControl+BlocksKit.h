//
//  UIControl+BlocksKit.h
//  BlocksKit
//

/** Block control event handling for UIControl.
 
 This set of extensions allows for two pathways of block
 handling for a UIControl instance.  There's the basic
 setup, which adds a block 
 
 Includes code by the following:
 
 - Kevin O'Neill.  <https://github.com/kevinoneill>. 2011. BSD.
 - Zach Waldowski. <https://github.com/zwaldowski>.  2011. MIT.
 */
@interface UIControl (BlocksKit)

///-----------------------------------
/// @name Block event handling
///-----------------------------------

/** Adds a block for a particular event to an internal dispatch table.

 @param handler A block representing an action message, with an argument for the sender.
 @param controlEvents A bitmask specifying the control events for which the action message is sent.
 @see addTarget:action:forControlEvents:
 @see removeEventHandlersForControlEvents:
 */
- (void)addEventHandler:(void (^)(id sender))handler forControlEvents:(UIControlEvents)controlEvents;

/** Removes all blocks for a particular event combination.
 @param controlEvents A bitmask specifying the control events for which the block will be removed.
 @see addTarget:action:forControlEvents:
 @see addEventHandler:forControlEvents:
 */
- (void)removeEventHandlersForControlEvents:(UIControlEvents)controlEvents;

@end
