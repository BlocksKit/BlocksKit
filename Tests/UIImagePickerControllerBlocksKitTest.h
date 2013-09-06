//
//  UIImagePickerControllerBlocksKitTest.h
//  BlocksKit
//
//  Created by Jesper on 9/6/13.
//  Copyright (c) 2013 Pandamonia LLC. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <BlocksKit/UIImagePickerController+BlocksKit.h>

@interface UIImagePickerControllerBlocksKitTest : SenTestCase <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

- (void)testInit;
- (void)testDidFinishPickingMedia;
- (void)testDidCancel;

@end
