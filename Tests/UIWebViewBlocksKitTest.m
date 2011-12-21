//
//  UIWebViewBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "UIWebViewBlocksKitTest.h"

@implementation UIWebViewBlocksKitTest {
	UIWebView *_subject;
	BOOL shouldStartLoadDelegate, didStartLoadDelegate, didFinishLoadDelegate, didFinishWithErrorDelegate;
}

- (BOOL)shouldRunOnMainThread {
	return YES;
}

- (void)setUp {
	_subject = [[UIWebView alloc] initWithFrame:CGRectZero];
}

- (void)tearDown {
	[_subject release];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	shouldStartLoadDelegate = YES;
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	didStartLoadDelegate = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	didFinishLoadDelegate = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	didFinishWithErrorDelegate = YES;
}

- (void)testShouldStartLoad {
	_subject.delegate = self;
	
	__block BOOL shouldStartLoadBlock = NO;
	_subject.shouldStartLoadBlock = ^BOOL(UIWebView *view, NSURLRequest *req, UIWebViewNavigationType type){
		shouldStartLoadBlock = YES;
		return YES;
	};
	
	BOOL shouldStartLoad = [_subject.delegate webView:_subject shouldStartLoadWithRequest:nil navigationType:UIWebViewNavigationTypeLinkClicked];
	
	GHAssertTrue(shouldStartLoad, @"Web view is allowed to load");
	GHAssertTrue(shouldStartLoadBlock, @"Block handler was called");
	GHAssertTrue(shouldStartLoadDelegate, @"Delegate was called");
}

- (void)testDidStartLoad {
	_subject.delegate = self;
	
	__block BOOL didStartLoadBlock = NO;
	_subject.didStartLoadBlock = ^(UIWebView *view){
		didStartLoadBlock = YES;
	};
	
	[_subject.delegate webViewDidStartLoad:_subject];
	
	GHAssertTrue(didStartLoadBlock, @"Block handler was called");
	GHAssertTrue(didStartLoadDelegate, @"Delegate was called");
}

- (void)testDidFinishLoad {
	_subject.delegate = self;
	
	__block BOOL didFinishLoadBlock = NO;
	_subject.didFinishLoadBlock = ^(UIWebView *view){
		didFinishLoadBlock = YES;
	};
	
	[_subject.delegate webViewDidFinishLoad:_subject];
	
	GHAssertTrue(didFinishLoadBlock, @"Block handler was called");
	GHAssertTrue(didFinishLoadDelegate, @"Delegate was called");
}

- (void)testDidFinishWithError {
	_subject.delegate = self;
	
	__block BOOL didFinishWithErrorBlock = NO;
	_subject.didFinishWithErrorBlock = ^(UIWebView *view, NSError *err){
		didFinishWithErrorBlock = YES;
	};
	
	[_subject.delegate webView:_subject didFailLoadWithError:nil];
	
	GHAssertTrue(didFinishWithErrorBlock, @"Block handler was called");
	GHAssertTrue(didFinishWithErrorDelegate, @"Delegate was called");
}

@end
