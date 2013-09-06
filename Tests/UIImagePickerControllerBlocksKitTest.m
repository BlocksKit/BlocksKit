//
//  UIImagePickerControllerBlocksKitTest.m
//  BlocksKit
//
//  Created by Jesper on 9/6/13.
//  Copyright (c) 2013 Pandamonia LLC. All rights reserved.
//

#import "UIImagePickerControllerBlocksKitTest.h"

@implementation UIImagePickerControllerBlocksKitTest {
	UIImagePickerController *_subject;
}

- (void)setUp {
	_subject = [[UIImagePickerController alloc] init];
}

- (void)testInit {
	STAssertTrue([_subject isKindOfClass:[UIImagePickerController class]],@"subject is UIImagePickerController");
	STAssertFalse([_subject.delegate isEqual: _subject.dynamicDelegate], @"the delegate is not the dynamic delegate");
}

- (void)testDidFinishPickingMedia {
	_subject.delegate = self;
	
	__block BOOL didFinishPickingMedia = NO;
	_subject.didFinishPickingMediaBlock = ^(UIImagePickerController *picker, NSDictionary *info) {
		didFinishPickingMedia = YES;
	};
	
	[_subject.dynamicDelegate imagePickerController:_subject didFinishPickingMediaWithInfo:nil];
	
	STAssertTrue(didFinishPickingMedia, @"");
}

- (void)testDidCancel {
	_subject.delegate = self;
	
	__block BOOL didCancel = NO;
	_subject.didCancelBlock = ^(UIImagePickerController *picker) {
		didCancel = YES;
	};
	
	[_subject.dynamicDelegate imagePickerControllerDidCancel:_subject];
	
	STAssertTrue(didCancel, @"");
}

@end
