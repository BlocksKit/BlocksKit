//
//  UIWebView+BlocksKit.h
//  BlocksKit
//

#import "BlocksKit_Globals.h"

/** Delegation replacement for UIWebView.

 Unlike other block extensions like UIAlertView(BlocksKit) and
 UIActionSheet(BlocksKit), UIWebView does not have an initializer
 that we are overriding.  Using any of the blocks properties
 discussed here were result in the delegate being set to the
 web view itself.

 @warning UIWebView is only available on iOS or in a Mac app using Chameleon.

 Includes code by the following:

 - Zach Waldowski. <https://github.com/zwaldowski>.  2011. MIT.
 */

@interface UIWebView (BlocksKit) <UIWebViewDelegate>

/** The block to be decide whether a URL will be loaded. */
@property (nonatomic, copy) BKWebViewStartBlock shouldStartLoadBlock;

/** The block that is fired when the web view starts loading. */
@property (nonatomic, copy) BKBlock didStartLoadBlock;

/** The block that is fired when the web view finishes loading. */
@property (nonatomic, copy) BKBlock didFinishLoadBlock;

/** The block that is fired when the web view stops loading due to an error. */
@property (nonatomic, copy) BKErrorBlock didFinishWithErrorBlock;

@end
