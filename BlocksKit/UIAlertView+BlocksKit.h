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

 - Loosely based on Landon Fullers ["Using Blocks"](http://landonf.bikemonkey.org/code/iphone/Using_Blocks_1.20090704.html).
 - Peter Steinberger. <https://github.com/steipete>.   2011. MIT.
 - Zach Waldowski.    <https://github.com/zwaldowski>. 2011. MIT.
 */
@interface UIAlertView (BlocksKit) <UIAlertViewDelegate>

+ (UIAlertView *)alertWithTitle:(NSString *)title;
+ (UIAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message;

- (id)initWithTitle:(NSString *)title message:(NSString *)message;

- (void)setCancelBlock:(void (^)())block;
- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block;

@end
