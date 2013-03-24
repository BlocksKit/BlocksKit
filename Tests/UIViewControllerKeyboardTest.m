//
//  NSNotificationCenterBlocksKitTest.m
//  BlocksKit
//
//  Created by Adam Kirk on 3/22/13.
//  Copyright (c) 2013 Mysterious Trousers LLC. All rights reserved.
//

#import "UIViewControllerKeyboardTest.h"
#import "UIViewController+Keyboard.h"

#define STALL(c) while (c) { [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]]; }

@implementation UIViewControllerBlocksKitTest {
    UIViewController    *_viewController;
    UITextField         *_textField;
}

- (void)setUp
{
    _textField      = [UITextField new];
    _viewController = [UIViewController new];
    [[UIApplication sharedApplication].keyWindow addSubview:_textField];
}

- (void)testKeyboardNotifications
{
    __block BOOL keyboardWillShowCalled = NO;
    __block BOOL keyboardDidShowCalled  = NO;
    __block BOOL keyboardWillHideCalled = NO;
    __block BOOL keyboardDidHideCalled  = NO;

    // test keyboard will show
    [_viewController bk_keyboardWillShow:^(CGRect beginFrame,
                                           CGRect endFrame,
                                           CGFloat animationDuration,
                                           UIViewAnimationCurve animationCurve) {
        STAssertTrue(beginFrame.size.width  > 0, nil);
        STAssertTrue(endFrame.size.width    > 0, nil);
        STAssertTrue(animationDuration      > 0, nil);
        STAssertTrue(animationCurve         == UIViewAnimationCurveEaseInOut, nil);
        keyboardWillShowCalled              = YES;
    }];

    [_viewController bk_keyboardDidShow:^(CGRect beginFrame,
                                          CGRect endFrame,
                                          CGFloat animationDuration,
                                          UIViewAnimationCurve animationCurve) {
        STAssertTrue(beginFrame.size.width  > 0, nil);
        STAssertTrue(endFrame.size.width    > 0, nil);
        STAssertTrue(animationDuration      > 0, nil);
        STAssertTrue(animationCurve         == UIViewAnimationCurveEaseInOut, nil);
        keyboardDidShowCalled               = YES;
    }];

    [_textField becomeFirstResponder];
    STALL(!keyboardWillShowCalled);
    STALL(!keyboardDidShowCalled);


    [_viewController bk_keyboardWillHide:^(CGRect beginFrame,
                                           CGRect endFrame,
                                           CGFloat animationDuration,
                                           UIViewAnimationCurve animationCurve) {
        STAssertTrue(beginFrame.size.width  > 0, nil);
        STAssertTrue(endFrame.size.width    > 0, nil);
        STAssertTrue(animationDuration      > 0, nil);
        STAssertTrue(animationCurve         == UIViewAnimationCurveEaseInOut, nil);
        keyboardWillHideCalled              = YES;
    }];

    [_viewController bk_keyboardDidHide:^(CGRect beginFrame,
                                          CGRect endFrame,
                                          CGFloat animationDuration,
                                          UIViewAnimationCurve animationCurve) {
        STAssertTrue(beginFrame.size.width  > 0, nil);
        STAssertTrue(endFrame.size.width    > 0, nil);
        STAssertTrue(animationDuration      > 0, nil);
        STAssertTrue(animationCurve         == UIViewAnimationCurveEaseInOut, nil);
        keyboardDidHideCalled               = YES;
    }];

    [_textField resignFirstResponder];
    STALL(!keyboardWillHideCalled);
    STALL(!keyboardDidHideCalled);
}


@end
