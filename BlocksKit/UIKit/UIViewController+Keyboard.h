//
//  NSNotificationCenter+BlocksKit.h
//  BlocksKit
//
//  Created by Adam Kirk on 3/22/13.
//  Copyright (c) 2013 Mysterious Trousers LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>


@interface UIViewController (Keyboard)



///-------------------------------------
/// @name Getting Keyboard Notifications
///-------------------------------------

/** Calls the block before the keyboard shows.
 @param block The block that should be called when the keyboard is about to show.
 */
- (void)bk_keyboardWillShow:(void (^)(CGRect beginFrame, CGRect endFrame, CGFloat animationDuration, UIViewAnimationCurve animationCurve))block;

/** Calls the block after the keyboard shows.
 @param block The block that should be called when the keyboard has shown.
 */
- (void)bk_keyboardDidShow:(void (^)(CGRect beginFrame, CGRect endFrame, CGFloat animationDuration, UIViewAnimationCurve animationCurve))block;

/** Calls the block before the keyboard hides.
 @param block The block that should be called when the keyboard is about to hide.
 */
- (void)bk_keyboardWillHide:(void (^)(CGRect beginFrame, CGRect endFrame, CGFloat animationDuration, UIViewAnimationCurve animationCurve))block;

/** Calls the block after the keyboard hides.
 @param block The block that should be called when the keyboard has hidden.
 */
- (void)bk_keyboardDidHide:(void (^)(CGRect beginFrame, CGRect endFrame, CGFloat animationDuration, UIViewAnimationCurve animationCurve))block;



@end
