//
//  UIWebView+BlocksKit.m
//  BlocksKit
//

#import "UIWebView+BlocksKit.h"
#import "NSObject+BlocksKit.h"
#import "BKDelegateProxy.h"

static char *kWebViewShouldStartBlockKey = "UIWebViewShouldStartBlock";
static char *kWebViewDidStartBlockKey = "UIWebViewDidStartBlock";
static char *kWebViewDidFinishBlockKey = "UIWebViewDidFinishBlock";
static char *kWebViewDidErrorBlockKey = "UIWebViewDidErrorBlock";

#pragma mark Delegate

@interface BKWebViewDelegate : BKDelegateProxy <UIWebViewDelegate>

@end

@implementation BKWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    BOOL ret = YES;
    
    id delegate = webView.delegate;
    if (delegate && [delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
        [delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    
    BKWebViewStartBlock block = webView.shouldStartLoadBlock;
    if (block)
        ret = (ret && block(request, navigationType));

    return ret;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    id delegate = webView.delegate;
    if (delegate && [delegate respondsToSelector:@selector(webViewDidStartLoad:)])
        [delegate webViewDidStartLoad:webView];
    
    BKBlock block = webView.didStartLoadBlock;
    if (block)
        block();
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    id delegate = webView.delegate;
    if (delegate && [delegate respondsToSelector:@selector(webViewDidFinishLoad:)])
        [delegate webViewDidFinishLoad:webView];
    
    BKBlock block = webView.didFinishLoadBlock;
    if (block)
        block();
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    id delegate = webView.delegate;
    if (delegate && [delegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
        [delegate webView:webView didFailLoadWithError:error];
    
    BKErrorBlock block = webView.didFinishWithErrorBlock;
    if (block)
        block(error);
}

@end

#pragma mark Category

@implementation UIWebView (BlocksKit)

+ (void)load {
    [self swizzleSelector:@selector(delegate) withSelector:@selector(bk_delegate)];
    [self swizzleSelector:@selector(setDelegate:) withSelector:@selector(bk_setDelegate:)];
}

#pragma mark Delegate

- (id)bk_delegate {
    return [self associatedValueForKey:kBKDelegateKey];
}

- (void)bk_setDelegate:(id)delegate {
    [self weaklyAssociateValue:delegate withKey:kBKDelegateKey];
    
    [self bk_setDelegate:[BKWebViewDelegate shared]];
}

#pragma mark Properties

- (BKWebViewStartBlock)shouldStartLoadBlock {
    return [self associatedValueForKey:kWebViewShouldStartBlockKey];
}

- (void)setShouldStartLoadBlock:(BKWebViewStartBlock)block {
    [self bk_setDelegate:[BKWebViewDelegate shared]];
    [self associateCopyOfValue:block withKey:kWebViewShouldStartBlockKey];
}

- (BKBlock)didStartLoadBlock {
    return [self associatedValueForKey:kWebViewDidStartBlockKey];
}

- (void)setDidStartLoadBlock:(BKBlock)block {
    [self bk_setDelegate:[BKWebViewDelegate shared]];
    [self associateCopyOfValue:block withKey:kWebViewDidStartBlockKey];
}

- (BKBlock)didFinishLoadBlock {
    return [self associatedValueForKey:kWebViewDidFinishBlockKey];
}

- (void)setDidFinishLoadBlock:(BKBlock)block {
    [self bk_setDelegate:[BKWebViewDelegate shared]];
    [self associateCopyOfValue:block withKey:kWebViewDidFinishBlockKey];
}

- (BKErrorBlock)didFinishWithErrorBlock {
    return [self associatedValueForKey:kWebViewDidErrorBlockKey];
}

- (void)setDidFinishWithErrorBlock:(BKErrorBlock)block {
    [self bk_setDelegate:[BKWebViewDelegate shared]];
    [self associateCopyOfValue:block withKey:kWebViewDidErrorBlockKey];
}

@end
