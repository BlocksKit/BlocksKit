//
//  UIWebView+BlocksKit.h
//  %PROJECT
//

#import "BKGlobals.h"

typedef BOOL(^BKWebViewStartBlock)(NSURLRequest *request, UIWebViewNavigationType navigationType);

/** Block callbacks for UIWebView.

 Includes code by the following:

 - Zach Waldowski. <https://github.com/zwaldowski>.  2011. MIT.

 @warning UIWebView is only available on iOS or in a Mac app using Chameleon.
*/

@interface UIWebView (BlocksKit)

/** The block to be decide whether a URL will be loaded. 
 
 @warning If the delegate implements webView:shouldStartLoadWithRequest:navigationType:,
 the return values of both the delegate method and the block will be considered.
*/
@property (copy) BKWebViewStartBlock shouldStartLoadBlock;

/** The block that is fired when the web view starts loading. */
@property (copy) BKBlock didStartLoadBlock;

/** The block that is fired when the web view finishes loading. */
@property (copy) BKBlock didFinishLoadBlock;

/** The block that is fired when the web view stops loading due to an error. */
@property (copy) BKErrorBlock didFinishWithErrorBlock;

@end
