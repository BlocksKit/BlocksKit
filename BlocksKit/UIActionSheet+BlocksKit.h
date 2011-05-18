//
//  UIActionSheet+BlocksKit.h
//  BlocksKit
//

/** UIActionSheet without delegates!
 
 This set of extensions and convenience classes allows
 for an instance of UIAlertView without the implementation
 of a delegate.  Any time you instantiate a UIAlertView
 using the methods here, you must add buttons using
 addButtonWithTitle:block: to make sure nothing breaks.
 
 A typical invocation might go like this:
     UIActionSheet *testSheet = [UIActionSheet sheetWithTitle:@"Please select one."];
     [testSheet addButtonWithTitle:@"Zip" block:^void() { NSLog(@"Zip!"); }];
     [testSheet addButtonWithTitle:@"Zap" block:^void() { NSLog(@"Zap!"); }];
     [testSheet addButtonWithTitle:@"Zop" block:^void() { NSLog(@"Zop!"); }];
     [testSheet setDestructiveButtonWithTitle:@"No!" block:^void() { NSLog(@"Fine!"); }];
     [testSheet setCancelButtonWithTitle:nil block:^void() { NSLog(@"Never mind, then!"); }];
     [testSheet showInView:self.view];
 
 Includes code by the following:
 
 - Landon Fuller, ["Using Blocks"](http://landonf.bikemonkey.org/code/iphone/Using_Blocks_1.20090704.html).
 - Peter Steinberger. <https://github.com/steipete>.   2011. MIT.
 - Zach Waldowski.    <https://github.com/zwaldowski>. 2011. MIT.
 */
@interface UIActionSheet (BlocksKit) <UIActionSheetDelegate>

///-----------------------------------
/// @name Creating action sheets
///-----------------------------------

/** Creates and returns a new action sheet with only a title and cancel button.

 @param title The header of the action sheet.
 @return A newly created action sheet.
 */
+ (UIActionSheet *)sheetWithTitle:(NSString *)title;

/** Returns a configured action sheet with only a title and cancel button.

 @param title The header of the action sheet.
 @return An instantiated actionSheet.
 @see initWithTitle:delegate:cancelButtonTitle:destructiveButtonTitle:otherButtonTitles:
 */
- (id)initWithTitle:(NSString *)title;

///-----------------------------------
/// @name Adding buttons
///-----------------------------------

/** Add a new button with an associated code block.

 @param title The text of the button.
 @param block A block of code.
 @see addButtonWithTitle:
 */
- (void)addButtonWithTitle:(NSString *)title block:(void (^)()) block;

/** Set the destructive (red) button with an associated code block.

 If setDestructiveButtonWithTitle:block: is called multiple times, the
 previously added destructive buttons will become normal buttons and
 will remain.

 @param title The text of the button.
 @param block A block of code.
 */
- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block;

/** Set the title and trigger of the cancel button.
 
 `block` can be set to `nil`, but this is generally useless as
 the cancel button is configured already to do nothing.
 
 If you are running on iPad, passing `nil` for the title will allow you
 to hide the cancel button but continue to use the cancel block.
 
 iPhone useers will have the button shown regardless; if the title is
 set to `nil`, it will automatically be localized.
 
 @param title The text of the button.
 @param block A block of code.
 @see addButtonWithTitle:
 */
- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block;

@end
