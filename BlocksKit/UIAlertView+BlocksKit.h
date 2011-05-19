//
//  UIAlertView+BlocksKit.h
//  BlocksKit
//

/** UIAlertView without delegates!

 This set of extensions and convenience classes allows
 for an instance of UIAlertView without the implementation
 of a delegate.  Any time you instantiate a UIAlertView
 using the methods here, you must add buttons using
 addButtonWithTitle:handler: otherwise nothing will happen.
 
 A typical invocation will go like this:
     UIAlertView *testView = [UIAlertView alertWithTitle:@"Application Alert" message:@"This app will explode in 42 seconds."];
     [testView setCancelButtonWithTitle:@"Oh No!" handler:^void() { NSLog(@"Boom!"); }];
     [testView show];
 
 A more traditional, and more useful, modal dialog looks like so:
    UIAlertView *testView = [UIAlertView alertWithTitle:@"Very important!" message:@"Do you like chocolate?"];
    [testView addButtonWithTitle:@"Yes" handler:^void() { NSLog(@"Yay!"); }];
    [testView addButtonWithTitle:@"No" handler:^void() { NSLog(@"We hate you."); }];
    [testView show];

 @warning UIAlertView is only available on iOS or in a Mac app using Chameleon.

 Includes code by the following:

 - Landon Fuller, "Using Blocks".  <http://landonf.bikemonkey.org>.
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
+ (id)alertWithTitle:(NSString *)title;

/** Creates and returns a new alert view with only a title, message, and cancel button.

 @param title The title of the alert view.
 @param message The message content of the alert.
 @return A newly created alert view.
 */
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message;

/** Returns a configured alert view with only a title, message, and cancel button.
 
 @param title The title of the alert view.
 @param message The message content of the alert.
 @return An instantiated alert view.
 */
- (id)initWithTitle:(NSString *)title message:(NSString *)message;

///-----------------------------------
/// @name Adding buttons
///-----------------------------------

/** Add a new button with an associated code block.
 
 @param title The text of the button.
 @param block A block of code.
 */
- (void)addButtonWithTitle:(NSString *)title handler:(BKBlock)block;

/** Set the title and trigger of the cancel button.

 `block` can be set to `nil`, but this is generally useless as
 the cancel button is configured already to do nothing.

 @param title The text of the button.
 @param block A block of code.
 */
- (void)setCancelButtonWithTitle:(NSString *)title handler:(BKBlock)block;


@end
