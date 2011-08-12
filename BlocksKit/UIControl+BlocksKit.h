//
//  UIControl+BlocksKit.h
//  %PROJECT
//

#import "BKGlobals.h"

/** Block control event handling for UIControl.

 Includes code by the following:

 - Kevin O'Neill.  <https://github.com/kevinoneill>. 2011. BSD.
 - Zach Waldowski. <https://github.com/zwaldowski>.  2011. MIT.

 @warning UIControl is only available on iOS or in a Mac app using Chameleon.
 */
@interface UIControl (BlocksKit)

///-----------------------------------
/// @name Block event handling
///-----------------------------------

/** Adds a block for a particular event to an internal dispatch table.

 @param handler A block representing an action message, with an argument for the sender.
 @param controlEvents A bitmask specifying the control events for which the action message is sent.
 @see removeEventHandlersForControlEvents:
 */
- (void)addEventHandler:(BKSenderBlock)handler forControlEvents:(UIControlEvents)controlEvents;

/** Removes all blocks for a particular event combination.
 @param controlEvents A bitmask specifying the control events for which the block will be removed.
 @see addEventHandler:forControlEvents:
 */
- (void)removeEventHandlersForControlEvents:(UIControlEvents)controlEvents;

/** Checks to see if the control has any blocks for a particular event combination.
 @param controlEvents A bitmask specifying the control events for which to check for blocks.
 @see addEventHandler:forControlEvents:
 @return Returns YES if there are blocks for these control events, NO otherwise.
 */
- (BOOL)hasEventHandlersForControlEvents:(UIControlEvents)controlEvents;

@end
