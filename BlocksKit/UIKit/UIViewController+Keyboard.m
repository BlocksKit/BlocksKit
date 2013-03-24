//
//  NSNotificationCenter+BlocksKit.m
//  BlocksKit
//
//  Created by Adam Kirk on 3/22/13.
//  Copyright (c) 2013 Mysterious Trousers LLC. All rights reserved.
//

#import "UIViewController+Keyboard.h"
#import <objc/runtime.h>


static char statusKey;

typedef NS_ENUM(NSInteger, UIViewControllerKeyboardStatus) {
    UIViewControllerKeyboardStatusHidden,
    UIViewControllerKeyboardStatusShowing,
    UIViewControllerKeyboardStatusShown,
    UIViewControllerKeyboardStatusHiding
};



@implementation UIViewController (Keyboard)

- (void)bk_keyboardWillShow:(void (^)(CGRect beginFrame, CGRect endFrame, CGFloat animationDuration, UIViewAnimationCurve animationCurve))block
{
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {

                                                           if ([self bk_keyboardStatus] != UIViewControllerKeyboardStatusHidden) return;
                                                           [self bk_setKeyboardStatus:UIViewControllerKeyboardStatusShowing];

                                                           NSDictionary *dictionary = [note userInfo];
                                                           if (block) block([self bk_beginFrameFromDictionay:dictionary],
                                                                            [self bk_endFrameFromDictionay:dictionary],
                                                                            [self bk_animationDurationFromDictionay:dictionary],
                                                                            [self bk_animationCurveFromDictionay:dictionary]);
                                                       }];
}

- (void)bk_keyboardDidShow: (void (^)(CGRect beginFrame, CGRect endFrame, CGFloat animationDuration, UIViewAnimationCurve animationCurve))block
{
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidShowNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {

                                                           if ([self bk_keyboardStatus] != UIViewControllerKeyboardStatusShowing) return;
                                                           [self bk_setKeyboardStatus:UIViewControllerKeyboardStatusShown];

                                                           NSDictionary *dictionary = [note userInfo];
                                                           if (block) block([self bk_beginFrameFromDictionay:dictionary],
                                                                            [self bk_endFrameFromDictionay:dictionary],
                                                                            [self bk_animationDurationFromDictionay:dictionary],
                                                                            [self bk_animationCurveFromDictionay:dictionary]);
                                                       }];
}

- (void)bk_keyboardWillHide:(void (^)(CGRect beginFrame, CGRect endFrame, CGFloat animationDuration, UIViewAnimationCurve animationCurve))block
{
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {

                                                           if ([self bk_keyboardStatus] != UIViewControllerKeyboardStatusShown) return;
                                                           [self bk_setKeyboardStatus:UIViewControllerKeyboardStatusHiding];

                                                           NSDictionary *dictionary = [note userInfo];
                                                           if (block) block([self bk_beginFrameFromDictionay:dictionary],
                                                                            [self bk_endFrameFromDictionay:dictionary],
                                                                            [self bk_animationDurationFromDictionay:dictionary],
                                                                            [self bk_animationCurveFromDictionay:dictionary]);
                                                       }];
}

- (void)bk_keyboardDidHide: (void (^)(CGRect beginFrame, CGRect endFrame, CGFloat animationDuration, UIViewAnimationCurve animationCurve))block
{
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidHideNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {

                                                           if ([self bk_keyboardStatus] != UIViewControllerKeyboardStatusHiding) return;
                                                           [self bk_setKeyboardStatus:UIViewControllerKeyboardStatusHidden];

                                                           NSDictionary *dictionary = [note userInfo];
                                                           if (block) block([self bk_beginFrameFromDictionay:dictionary],
                                                                            [self bk_endFrameFromDictionay:dictionary],
                                                                            [self bk_animationDurationFromDictionay:dictionary],
                                                                            [self bk_animationCurveFromDictionay:dictionary]);
                                                       }];
}



#pragma mark - Private

- (CGRect)bk_beginFrameFromDictionay:(NSDictionary *)dictionary
{
    NSValue *beginFrameValue = dictionary[UIKeyboardFrameBeginUserInfoKey];
    return [beginFrameValue CGRectValue];
}

- (CGRect)bk_endFrameFromDictionay:(NSDictionary *)dictionary
{
    NSValue *endFrameValue = dictionary[UIKeyboardFrameEndUserInfoKey];
    return [endFrameValue CGRectValue];
}

- (CGFloat)bk_animationDurationFromDictionay:(NSDictionary *)dictionary
{
    NSNumber *animationDuration = dictionary[UIKeyboardAnimationDurationUserInfoKey];
    return [animationDuration floatValue];
}

- (UIViewAnimationCurve)bk_animationCurveFromDictionay:(NSDictionary *)dictionary
{
    NSNumber *animationCurve = dictionary[UIKeyboardAnimationCurveUserInfoKey];
    return [animationCurve integerValue];
}


- (void)bk_setKeyboardStatus:(UIViewControllerKeyboardStatus)status
{
    objc_setAssociatedObject(self, &statusKey, @(status), OBJC_ASSOCIATION_COPY);
}

- (UIViewControllerKeyboardStatus)bk_keyboardStatus
{
    NSNumber *number = objc_getAssociatedObject(self, &statusKey);
    if (number) return [number integerValue];
    else        return UIViewControllerKeyboardStatusHidden;
}




@end
