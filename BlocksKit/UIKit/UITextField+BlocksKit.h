//
//  UITextField+BlocksKit.h
//  BlocksKit
//
//  Contributed by Samuel E. Giddins.
//

#import "BKDefines.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** Block callbacks for UITextField.

 @warning UITextField is only available on a platform with UIKit.

 Created by [Samuel E. Giddins](https://github.com/segiddins) and
 contributed to BlocksKit.
 */
@interface UITextField (BlocksKit)

/**
 *	The block that fires before the receiver begins editing
 *
 *  The return value indicates whether the receiver should begin editing
 */
@property (nonatomic, copy, nullable) BOOL(^bk_shouldBeginEditingBlock)(UITextField *textField);

/**
 *	The block that fires after the receiver begins editing
 */
@property (nonatomic, copy, nullable) void(^bk_didBeginEditingBlock)(UITextField *textField);

/**
 *	The block that fires before the receiver ends editing
 *
 *  The return value indicates whether the receiver should end editing
 */
@property (nonatomic, copy, nullable) BOOL(^bk_shouldEndEditingBlock)(UITextField *textField);

/**
 *	The block that fires after the receiver ends editing
 */
@property (nonatomic, copy, nullable) void(^bk_didEndEditingBlock)(UITextField *textField);

/**
 *	The block that fires when the receiver's text will change
 *
 *  The return value indicates whether the receiver should replace the characters in the given range with the replacement string
 */
@property (nonatomic, copy, nullable) BOOL(^bk_shouldChangeCharactersInRangeWithReplacementStringBlock)(UITextField *textField, NSRange range, NSString *string);

/**
 *	The block that fires when the receiver's clear button is pressed
 *
 *  The return value indicates whether the receiver should clear its contents
 */
@property (nonatomic, copy, nullable) BOOL(^bk_shouldClearBlock)(UITextField *textField);

/**
 *	The block that fires when the keyboard's return button is pressed and the receiver is the first responder
 *
 *  The return value indicates whether the receiver should return
 */
@property (nonatomic, copy, nullable) BOOL(^bk_shouldReturnBlock)(UITextField *textField);

@end

NS_ASSUME_NONNULL_END
