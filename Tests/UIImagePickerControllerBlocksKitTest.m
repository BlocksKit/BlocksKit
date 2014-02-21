//
//  UIImagePickerControllerBlocksKitTest.m
//  BlocksKit
//
//  Created by Yas Kuraishi on 2/21/14.
//  Copyright (c) 2014 Pandamonia LLC. All rights reserved.
//

#import <BlocksKit/A2DynamicDelegate.h>
#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/BlocksKit+UIKit.h>
#import "UIImagePickerControllerBlocksKitTest.h"

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

- (void)testInit {
    STAssertTrue([_subject isKindOfClass:[UIImagePickerController class]],@"subject is UIImagePickerController");
    STAssertFalse([_subject.delegate isEqual:_subject.bk_dynamicDelegate], @"the delegate is not the dynamic delegate");
}

- (void)testDidFinishPickingMediaBlock {
    delegateWorked = NO;
    __block BOOL blockWorked = NO;
    
    _subject.delegate = self;
    _subject.bk_didFinishPickingMediaBlock = ^(UIImagePickerController *picker, NSDictionary *info) {
        blockWorked = YES;
    };
    
    [[_subject bk_dynamicDelegateForProtocol:@protocol(UIImagePickerControllerDelegate)] imagePickerController:_subject didFinishPickingMediaWithInfo:nil];
	STAssertTrue(delegateWorked, @"Delegate method 'imagePickerController:didFinishPickingMediaWithInfo:' not called.");
	STAssertTrue(blockWorked, @"Block handler 'bk_didFinishPickingMediaBlock' not called.");
}

- (void)testDidCancelBlock {
    delegateWorked = NO;
    __block BOOL blockWorked = NO;
    
    _subject.delegate = self;
    _subject.bk_didCancelBlock = ^(UIImagePickerController *picker) {
        blockWorked = YES;
    };
    
    [[_subject bk_dynamicDelegateForProtocol:@protocol(UIImagePickerControllerDelegate)] imagePickerControllerDidCancel:_subject];
	STAssertTrue(delegateWorked, @"Delegate method 'imagePickerControllerDidCancel:' not called.");
	STAssertTrue(blockWorked, @"Block handler 'bk_didCancelBlock' not called.");
}

@end
