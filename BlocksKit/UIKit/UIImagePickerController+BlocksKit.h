//
//  UIImagePickerController+BlocksKit.h
//  BlocksKit
//
//  Created by Yas Kuraishi on 2/20/14.
//  Copyright (c) 2014 Pandamonia LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImagePickerController (BlocksKit)

/**
 *	The block that fires after the receiver finished picking up an image
 */
@property (nonatomic, copy) void(^bk_didFinishPickingMediaBlock)(UIImagePickerController *, NSDictionary *);

/**
 *	The block that fires after the user cancels out of picker
 */
@property (nonatomic, copy) void(^bk_didCancelBlock)(UIImagePickerController *);

@end
