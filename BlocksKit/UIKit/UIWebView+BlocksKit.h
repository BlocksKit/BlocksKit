//
//  UIWebView+BlocksKit.h
//  BlocksKit
//

#import "BKGlobals.h"

/** Block callbacks for UIWebView.

 @warning UIWebView is only available on a platform with UIKit.
*/

@interface UIWebView (BlocksKit)

/** The block to be decide whether a URL will be loaded. 
 
 @warning If the delegate implements webView:shouldStartLoadWithRequest:navigationType:,
 the return values of both the delegate method and the block will be considered.
*/
@property (nonatomic, copy, setter = bk_setShouldStartLoadBlock:) BOOL(^bk_shouldStartLoadBlock)(UIWebView *webView, NSURLRequest *request, UIWebViewNavigationType navigationType);

/** The block that is fired when the web view starts loading. */
@property (nonatomic, copy, setter = bk_setDidStartLoadBlock:) void(^bk_didStartLoadBlock)(UIWebView *webView);

/** The block that is fired when the web view finishes loading. */
@property (nonatomic, copy, setter = bk_setDidFinishLoadBlock:) void(^bk_didFinishLoadBlock)(UIWebView *webView);

/** The block that is fired when the web view stops loading due to an error. */
@property (nonatomic, copy, setter = bk_setDidFinishWithErrorBlock:) void(^bk_didFinishWithErrorBlock)(UIWebView *webView, NSError *error);

@end
