//
//  UITextField+BlocksKit.h
//  BlocksKit
//
//  Created by Samuel E. Giddins on 7/24/13.
//  Copyright (c) 2013 Pandamonia LLC. All rights reserved.
//

#import <UIKit/UITextField.h>
#import "BlocksKit.h"

/** Block callbacks for UITextField.
 
 @warning UITextField is only available on a platform with UIKit.
 */
@interface UITextField (BlocksKit)

/**
 *	The block that fires before the receiver begins editing
 *
 *  The return value indicates whether the receiver should begin editing
 */
@property (nonatomic, copy) BOOL(^bk_shouldBeginEditingBlock)(UITextField *);

/**
 *	The block that fires after the receiver begins editing
 */
@property (nonatomic, copy) void(^bk_didBeginEditingBlock)(UITextField *);

/**
 *	The block that fires before the receiver ends editing
 *
 *  The return value indicates whether the receiver should end editing
 */
@property (nonatomic, copy) BOOL(^bk_shouldEndEditingBlock)(UITextField *);

/**
 *	The block that fires after the receiver ends editing
 */
@property (nonatomic, copy) void(^bk_didEndEditingBlock)(UITextField *);

/**
 *	The block that fires when the receiver's text will change
 *
 *  The return value indicates whether the receiver should replace the characters in the given range with the replacement string
 */
@property (nonatomic, copy) BOOL(^bk_shouldChangeCharactersInRangeWithReplacementStringBlock)(UITextField *, NSRange, NSString *);

/**
 *	The block that fires when the receiver's clear button is pressed
 *
 *  The return value indicates whether the receiver should clear its contents
 */
@property (nonatomic, copy) BOOL(^bk_shouldClearBlock)(UITextField *);

/**
 *	The block that fires when the keyboard's return button is pressed and the receiver is the first responder
 *
 *  The return value indicates whether the receiver should return
 */
@property (nonatomic, copy) BOOL(^bk_shouldReturnBlock)(UITextField *);

@end
