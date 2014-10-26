//
//  UIImagePickerControllerBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import <BlocksKit/A2DynamicDelegate.h>
#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/BlocksKit+UIKit.h>

@interface UIImagePickerControllerBlocksKitTest : XCTestCase <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (void)testDidFinishPickingMediaBlock;
- (void)testDidCancelBlock;

@end

@implementation UIImagePickerControllerBlocksKitTest {
    UIImagePickerController *_subject;
	BOOL delegateWorked;
}

- (void)setUp {
    _subject = [UIImagePickerController new];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    delegateWorked = YES;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    delegateWorked = YES;
}

- (void)testDidFinishPickingMediaBlock {
    delegateWorked = NO;
    __block BOOL blockWorked = NO;

    _subject.delegate = self;
    _subject.bk_didFinishPickingMediaBlock = ^(UIImagePickerController *picker, NSDictionary *info) {
        blockWorked = YES;
    };

    [[_subject bk_dynamicDelegateForProtocol:@protocol(UIImagePickerControllerDelegate)] imagePickerController:_subject didFinishPickingMediaWithInfo:nil];
	XCTAssertTrue(delegateWorked, @"Delegate method 'imagePickerController:didFinishPickingMediaWithInfo:' not called.");
	XCTAssertTrue(blockWorked, @"Block handler 'bk_didFinishPickingMediaBlock' not called.");
}

- (void)testDidCancelBlock {
    delegateWorked = NO;
    __block BOOL blockWorked = NO;

    _subject.delegate = self;
    _subject.bk_didCancelBlock = ^(UIImagePickerController *picker) {
        blockWorked = YES;
    };

    [[_subject bk_dynamicDelegateForProtocol:@protocol(UIImagePickerControllerDelegate)] imagePickerControllerDidCancel:_subject];
	XCTAssertTrue(delegateWorked, @"Delegate method 'imagePickerControllerDidCancel:' not called.");
	XCTAssertTrue(blockWorked, @"Block handler 'bk_didCancelBlock' not called.");
}

@end
