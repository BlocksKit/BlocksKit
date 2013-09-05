//
//  UIImagePickerController+BlocksKit.m
//  BlocksKit
//
//  Created by Jesper on 9/1/13.
//  Copyright (c) 2013 Pandamonia LLC. All rights reserved.
//

#import "UIImagePickerController+BlocksKit.h"

#pragma mark Custom delegate

@interface A2DynamicUIImagePickerControllerDelegate : A2DynamicDelegate
@end

@implementation A2DynamicUIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:)])
		[realDelegate imagePickerController:picker didFinishPickingMediaWithInfo:info];
	
	void(^block)(UIImagePickerController *, NSDictionary *) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(picker, info);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(imagePickerControllerDidCancel:)])
		[realDelegate imagePickerControllerDidCancel:picker];
	
	void(^block)(UIImagePickerController *) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(picker);
}

@end

@implementation UIImagePickerController (BlocksKit)

@dynamic didFinishPickingMedia, didCancel;

+ (void)load {
	@autoreleasepool {
		[self registerDynamicDelegate];
		[self linkDelegateMethods: @{
									 @"didFinishPickingMedia": @"imagePickerController:didFinishPickingMediaWithInfo:",
									 @"didCancel": @"imagePickerControllerDidCancel:"
									 }];
	}
}

@end
