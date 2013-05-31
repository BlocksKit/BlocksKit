//
//  UIActionSheet+BlocksKit.h
//  BlocksKit
//

#import "BKGlobals.h"

/** UIActionSheet without delegates!

 This set of extensions and convenience classes allows
 for an instance of UIAlertView without the implementation
 of a delegate.  Any time you instantiate a UIAlertView
 using the methods here, you must add buttons using
 addButtonWithTitle:handler: to make sure nothing breaks.

 A typical invocation might go like this:
	 UIActionSheet *testSheet = [UIActionSheet actionSheetWithTitle:@"Please select one."];
	 [testSheet addButtonWithTitle:@"Zip" handler:^{ NSLog(@"Zip!"); }];
	 [testSheet addButtonWithTitle:@"Zap" handler:^{ NSLog(@"Zap!"); }];
	 [testSheet addButtonWithTitle:@"Zop" handler:^{ NSLog(@"Zop!"); }];
	 [testSheet setDestructiveButtonWithTitle:@"No!" handler:^{ NSLog(@"Fine!"); }];
	 [testSheet setCancelButtonWithTitle:nil handler:^{ NSLog(@"Never mind, then!"); }];
	 [testSheet showInView:self.view];

 Includes code by the following:

 - [Landon Fuller](http://landonf.bikemonkey.org), "Using Blocks".
 - [Peter Steinberger](https://github.com/steipete)
 - [Zach Waldowski](https://github.com/zwaldowski)

 @warning UIActionSheet is only available on a platform with UIKit.
 */
@interface UIActionSheet (BlocksKit) <UIActionSheetDelegate>

///-----------------------------------
/// @name Creating action sheets
///-----------------------------------

/** Creates and returns a new action sheet with only a title and cancel button.

 @param title The header of the action sheet.
 @return A newly created action sheet.
 */
+ (id)actionSheetWithTitle:(NSString *)title;

/** Returns a configured action sheet with only a title and cancel button.

 @param title The header of the action sheet.
 @return An instantiated actionSheet.
 */
- (id)initWithTitle:(NSString *)title;

///-----------------------------------
/// @name Adding buttons
///-----------------------------------

/** Add a new button with an associated code block.

 @param title The text of the button.
 @param block A block of code.
 */
- (NSInteger)addButtonWithTitle:(NSString *)title handler:(BKBlock)block;

/** Set the destructive (red) button with an associated code block.
 
 @warning Because buttons cannot be removed from an action sheet,
 be aware that the effects of calling this method are cumulative.
 Previously added destructive buttons will become normal buttons.

 @param title The text of the button.
 @param block A block of code.
 */
- (NSInteger)setDestructiveButtonWithTitle:(NSString *)title handler:(BKBlock)block;

/** Set the title and trigger of the cancel button.
 
 `block` can be set to `nil`, but this is generally useless as
 the cancel button is configured already to do nothing.
 
 iPhone users will have the button shown regardless; if the title is
 set to `nil`, it will automatically be localized.
 
 @param title The text of the button.
 @param block A block of code.
 */
- (NSInteger)setCancelButtonWithTitle:(NSString *)title handler:(BKBlock)block;

///-----------------------------------
/// @name Altering actions
///-----------------------------------

/** Sets the block that is to be fired when a button is pressed.
 
 @param block A code block, or nil to set no response.
 @param index The index of a button already added to the action sheet.
*/
- (void)setHandler:(BKBlock)block forButtonAtIndex:(NSInteger)index;

/** The block that is to be fired when a button is pressed.
 
 @param index The index of a button already added to the action sheet.
 @return A code block, or nil if no block is assigned.
 */
- (BKBlock)handlerForButtonAtIndex:(NSInteger)index;

/** The block to be fired when the action sheet is dismissed with the cancel
 button and/or action.

 This property performs the same action as setCancelButtonWithTitle:handler:
 but with `title` set to nil.  Contrary to setCancelButtonWithTitle:handler:,
 you can set this property multiple times and multiple cancel buttons will
 not be generated.
 */
@property (nonatomic, copy) BKBlock cancelBlock;

/** The block to be fired before the action sheet will show. */
@property (nonatomic, copy) void (^willShowBlock)(UIActionSheet *);

/** The block to be fired when the action sheet shows. */
@property (nonatomic, copy) void (^didShowBlock)(UIActionSheet *);

/** The block to be fired before the action sheet will dismiss. */
@property (nonatomic, copy) void (^willDismissBlock)(UIActionSheet *, NSInteger);

/** The block to be fired after the action sheet dismisses. */
@property (nonatomic, copy) void (^didDismissBlock)(UIActionSheet *, NSInteger);

@end
