//
//  UIAlertView+BlocksKit.h
//  BlocksKit
//

/** UIAlertView without delegates!

 This set of extensions and convenience classes allows
 for an instance of UIAlertView without the implementation
 of a delegate.  Any time you instantiate a UIAlertView
 using the methods here, you must add buttons using
 addButtonWithTitle:block: to make sure nothing breaks.

 Includes code by the following:

 - Landon Fuller, ["Using Blocks"](http://landonf.bikemonkey.org/code/iphone/Using_Blocks_1.20090704.html).
 - Peter Steinberger. <https://github.com/steipete>.   2011. MIT.
 - Zach Waldowski.    <https://github.com/zwaldowski>. 2011. MIT.
 */
@interface UIAlertView (BlocksKit) <UIAlertViewDelegate>

///-----------------------------------
/// @name Creating alert views
///-----------------------------------

/** Creates and returns a new alert view with only a title and cancel button.

 @param title The title of the alert view.
 @return A newly created alert view.
 */
+ (UIAlertView *)alertWithTitle:(NSString *)title;

/** Creates and returns a new alert view with only a title, message, and cancel button.

 @param title The title of the alert view.
 @param message The message content of the alert.
 @return A newly created alert view.
 */
+ (UIAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message;

/** Returns a configured alert view with only a title, message, and cancel button.
 
 @param title The title of the alert view.
 @param message The message content of the alert.
 @return An instantiated alert view.
 @see initWithTitle:message:delegate:cancelButtonTitle:otherButtonTitles:
 */
- (id)initWithTitle:(NSString *)title message:(NSString *)message;

///-----------------------------------
/// @name Adding buttons
///-----------------------------------

/** Add a new button with an associated code block.
 
 @warning *Important:* Even if you intend for a button to do nothing,
 do not use the regular addButtonWithTitle: method.  Pass `nil` in
 place of the block argument instead.
 
 @param title The text of the button.
 @param block A block of code.
 */
- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block;

/** Set the block triggered by the cancel button.

 `block` can be set to `nil`, but this is generally useless as
 the cancel button is configured already to do nothing.

 @param block A block of code.
 */
- (void)setCancelBlock:(void (^)())block;


@end
