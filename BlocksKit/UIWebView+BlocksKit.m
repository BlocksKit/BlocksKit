//
//  UIWebView+BlocksKit.m
//  BlocksKit
//

#import "UIWebView+BlocksKit.h"
#import "A2BlockDelegate+BlocksKit.h"

#pragma mark Custom delegate

@interface A2DynamicUIWebViewDelegate : A2DynamicDelegate
@end

@implementation A2DynamicUIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	BOOL ret = YES;

	id delegate = webView.delegate;
	if (delegate && [delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
		ret = [delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];

	BOOL (^block)(UIWebView *, NSURLRequest *, UIWebViewNavigationType) = [self blockImplementationForMethod:_cmd];
	if (block)
		ret = (ret && block(webView, request, navigationType));

	return ret;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	id delegate = webView.delegate;
	if (delegate && [delegate respondsToSelector:@selector(webViewDidStartLoad:)])
		[delegate webViewDidStartLoad:webView];

	BOOL(^block)(UIWebView *) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(webView);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	id delegate = webView.delegate;
	if (delegate && [delegate respondsToSelector:@selector(webViewDidFinishLoad:)])
		[delegate webViewDidFinishLoad:webView];

	BOOL(^block)(UIWebView *) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(webView);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	id delegate = webView.delegate;
	if (delegate && [delegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
		[delegate webView:webView didFailLoadWithError:error];

	BOOL(^block)(UIWebView *, NSError *) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(webView, error);
}

@end

#pragma mark Category

@implementation UIWebView (BlocksKit)

@dynamic shouldStartLoadBlock, didStartLoadBlock, didFinishLoadBlock, didFinishWithErrorBlock;

+ (void)load {
	@autoreleasepool {
		[self swizzleDelegateProperty];
		NSDictionary *methods = [NSDictionary dictionaryWithObjectsAndKeys:
								 @"shouldStartLoadBlock", @"webView:shouldStartLoadWithRequest:navigationType:",
								 @"didStartLoadBlock", @"webViewDidStartLoad:",
								 @"didFinishLoadBlock", @"webViewDidFinishLoad:",
								 @"didFinishWithErrorBlock", @"webView:didFailLoadWithError:",
								 nil];
		[self linkDelegateMethods:methods];
	}
}

@end
