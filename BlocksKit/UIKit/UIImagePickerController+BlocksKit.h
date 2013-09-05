//
//  UIImagePickerController+BlocksKit.h
//  BlocksKit
//
//  Created by Jesper on 9/1/13.
//  Copyright (c) 2013 Pandamonia LLC. All rights reserved.
//

#import "BKGlobals.h"

/** Block callbacks for UIImagePickerController.
 
 @warning UIImagePickerController is only available on a platform with UIKit.
 */

@interface UIImagePickerController (BlocksKit)

@property (nonatomic, copy) void(^didFinishPickingMedia)(UIImagePickerController *, NSDictionary *);
@property (nonatomic, copy) void(^didCancel)(UIImagePickerController *);

@end
