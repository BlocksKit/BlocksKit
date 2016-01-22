//
//  UIWebViewBlocksKitTest.m
//  BlocksKit Unit Tests
//

@import XCTest;
@import BlocksKit.Dynamic.UIKit;

@interface UIWebViewBlocksKitTest : XCTestCase <UIWebViewDelegate>

@end

@implementation UIWebViewBlocksKitTest {
	UIWebView *_subject;
	BOOL shouldStartLoadDelegate, didStartLoadDelegate, didFinishLoadDelegate, didFinishWithErrorDelegate;
}

- (void)setUp {
	_subject = [[UIWebView alloc] initWithFrame:CGRectZero];
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
	_subject.bk_shouldStartLoadBlock = ^BOOL(UIWebView *view, NSURLRequest *req, UIWebViewNavigationType type) {
		shouldStartLoadBlock = YES;
		return YES;
	};
	
	BOOL shouldStartLoad = [_subject.bk_dynamicDelegate webView:_subject shouldStartLoadWithRequest:nil navigationType:UIWebViewNavigationTypeLinkClicked];
	
	XCTAssertTrue(shouldStartLoad, @"Web view is allowed to load");
	XCTAssertTrue(shouldStartLoadBlock, @"Block handler was called");
	XCTAssertTrue(shouldStartLoadDelegate, @"Delegate was called");
}

- (void)testDidStartLoad {
	_subject.delegate = self;
	
	__block BOOL didStartLoadBlock = NO;
	_subject.bk_didStartLoadBlock = ^(UIWebView *view) {
		didStartLoadBlock = YES;
	};
	
	[_subject.bk_dynamicDelegate webViewDidStartLoad:_subject];
	
	XCTAssertTrue(didStartLoadBlock, @"Block handler was called");
	XCTAssertTrue(didStartLoadDelegate, @"Delegate was called");
}

- (void)testDidFinishLoad {
	_subject.delegate = self;
	
	__block BOOL didFinishLoadBlock = NO;
	_subject.bk_didFinishLoadBlock = ^(UIWebView *view) {
		didFinishLoadBlock = YES;
	};
	
	[_subject.bk_dynamicDelegate webViewDidFinishLoad:_subject];
	
	XCTAssertTrue(didFinishLoadBlock, @"Block handler was called");
	XCTAssertTrue(didFinishLoadDelegate, @"Delegate was called");
}

- (void)testDidFinishWithError {
	_subject.delegate = self;
	
	__block BOOL didFinishWithErrorBlock = NO;
	_subject.bk_didFinishWithErrorBlock = ^(UIWebView *view, NSError *err) {
		didFinishWithErrorBlock = YES;
	};
	
	[_subject.bk_dynamicDelegate webView:_subject didFailLoadWithError:nil];
	
	XCTAssertTrue(didFinishWithErrorBlock, @"Block handler was called");
	XCTAssertTrue(didFinishWithErrorDelegate, @"Delegate was called");
}

@end
