//
//  UIWebView+BlocksKit.h
//  %PROJECT
//

#import "BKGlobals.h"

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
@property (nonatomic, copy) BOOL(^shouldStartLoadBlock)(UIWebView *, NSURLRequest *, UIWebViewNavigationType);

/** The block that is fired when the web view starts loading. */
@property (nonatomic, copy) void(^didStartLoadBlock)(UIWebView *);

/** The block that is fired when the web view finishes loading. */
@property (nonatomic, copy) void(^didFinishLoadBlock)(UIWebView *);

/** The block that is fired when the web view stops loading due to an error. */
@property (nonatomic, copy) void(^didFinishWithErrorBlock)(UIWebView *, NSError *);

@end