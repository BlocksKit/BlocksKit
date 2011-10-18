//
//  UIWebView+BlocksKit.m
//  BlocksKit
//

#import "UIWebView+BlocksKit.h"
#import "NSObject+BlocksKit.h"
#import "BKDelegate.h"

static char *kWebViewShouldStartBlockKey = "UIWebViewShouldStartBlock";
static char *kWebViewDidStartBlockKey = "UIWebViewDidStartBlock";
static char *kWebViewDidFinishBlockKey = "UIWebViewDidFinishBlock";
static char *kWebViewDidErrorBlockKey = "UIWebViewDidErrorBlock";
static char *kDelegateKey = "UIWebViewDelegate";

#pragma mark Delegate

@interface BKWebViewDelegate : BKDelegate <UIWebViewDelegate>

@end

@implementation BKWebViewDelegate

+ (Class)targetClass {
    return [UIWebView class];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    BOOL ret = YES;
    
    id delegate = webView.delegate;
    if (delegate && [delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
        ret = [delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    
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
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSelector:@selector(delegate) withSelector:@selector(bk_delegate)];
        [self swizzleSelector:@selector(setDelegate:) withSelector:@selector(bk_setDelegate:)];
    });
}

#pragma mark Delegate

- (id)bk_delegate {
    return [self associatedValueForKey:kDelegateKey];
}

- (void)bk_setDelegate:(id)delegate {
    [self weaklyAssociateValue:delegate withKey:kDelegateKey];
    [self bk_setDelegate:[BKWebViewDelegate shared]];
}

#pragma mark Properties

- (BKWebViewStartBlock)shouldStartLoadBlock {
    BKWebViewStartBlock block = [self associatedValueForKey:kWebViewShouldStartBlockKey];
    return BK_AUTORELEASE([block copy]);
}

- (void)setShouldStartLoadBlock:(BKWebViewStartBlock)block {
    [self bk_setDelegate:[BKWebViewDelegate shared]];
    [self associateCopyOfValue:block withKey:kWebViewShouldStartBlockKey];
}

- (BKBlock)didStartLoadBlock {
    BKBlock block = [self associatedValueForKey:kWebViewDidStartBlockKey];
    return BK_AUTORELEASE([block copy]);
}

- (void)setDidStartLoadBlock:(BKBlock)block {
    [self bk_setDelegate:[BKWebViewDelegate shared]];
    [self associateCopyOfValue:block withKey:kWebViewDidStartBlockKey];
}

- (BKBlock)didFinishLoadBlock {
    BKBlock block = [self associatedValueForKey:kWebViewDidFinishBlockKey];
    return BK_AUTORELEASE([block copy]);
}

- (void)setDidFinishLoadBlock:(BKBlock)block {
    [self bk_setDelegate:[BKWebViewDelegate shared]];
    [self associateCopyOfValue:block withKey:kWebViewDidFinishBlockKey];
}

- (BKErrorBlock)didFinishWithErrorBlock {
    BKErrorBlock block = [self associatedValueForKey:kWebViewDidErrorBlockKey];
    return BK_AUTORELEASE([block copy]);
}

- (void)setDidFinishWithErrorBlock:(BKErrorBlock)block {
    [self bk_setDelegate:[BKWebViewDelegate shared]];
    [self associateCopyOfValue:block withKey:kWebViewDidErrorBlockKey];
}

@end
