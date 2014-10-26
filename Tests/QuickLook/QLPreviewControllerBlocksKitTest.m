//
//  QLPreviewControllerBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import <XCTest/XCTest.h>
#import <BlocksKit/QLPreviewController+BlocksKit.h>
#import <BlocksKit/A2DynamicDelegate.h>

@interface QLPreviewControllerBlocksKitTest : XCTestCase

@end

@implementation QLPreviewControllerBlocksKitTest {
	QLPreviewController *_subject;
}

- (void)setUp {
	_subject = [[QLPreviewController alloc] init];
}

- (void)testDelegationBlocks
{
	__block BOOL willShow = NO;
	__block BOOL didShow = NO;
	__block BOOL shouldOpenURL = NO;
	__block BOOL transitionImageForPreviewItem = NO;
	__block BOOL frameForPreviewItem = NO;

	_subject.bk_willDismissBlock = ^(QLPreviewController *controller) { willShow = YES; };
	_subject.bk_didDismissBlock = ^(QLPreviewController *controller) { didShow = YES; };

	_subject.bk_shouldOpenURLForPreviewItem = ^BOOL(QLPreviewController *controller, NSURL *url, id<QLPreviewItem> item) {
		shouldOpenURL = YES;
		return YES;
	};

	_subject.bk_transitionImageForPreviewItem = ^UIImage *(QLPreviewController *controller, id <QLPreviewItem> item, CGRect *contentRect) {
		transitionImageForPreviewItem = YES;
		return nil;
	};

	_subject.bk_frameForPreviewItem = ^CGRect(QLPreviewController *controller, id <QLPreviewItem> item, UIView **view) {
		frameForPreviewItem = YES;
		return CGRectZero;
	};

	[_subject.bk_dynamicDelegate previewControllerWillDismiss:_subject];
	[_subject.bk_dynamicDelegate previewControllerDidDismiss:_subject];
	[_subject.bk_dynamicDelegate previewController:_subject shouldOpenURL:nil forPreviewItem:nil];
	[_subject.bk_dynamicDelegate previewController:_subject transitionImageForPreviewItem:nil contentRect:nil];
	[_subject.bk_dynamicDelegate previewController:_subject frameForPreviewItem:nil inSourceView:nil];

	XCTAssertTrue(willShow, @"willShowBlock not fired.");
	XCTAssertTrue(didShow, @"didShowblock not fired.");
	XCTAssertTrue(shouldOpenURL, @"shouldOpenURLForPreviewItem was not fired");
	XCTAssertTrue(transitionImageForPreviewItem, @"transitionImageForPreivewItem was not fired");
	XCTAssertTrue(frameForPreviewItem, @"frameForPreviewItem was not fired");
}

@end
