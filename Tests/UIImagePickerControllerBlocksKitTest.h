//
//  UIImagePickerControllerBlocksKitTest.m
//  BlocksKit
//
//  Created by Yas Kuraishi on 2/21/14.
//  Copyright (c) 2014 Pandamonia LLC. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@interface UIImagePickerControllerBlocksKitTest : SenTestCase <UIImagePickerControllerDelegate, UINavigationControllerDelegate>


- (void)testInit;
- (void)testDidFinishPickingMediaBlock;
- (void)testDidCancelBlock;

@end