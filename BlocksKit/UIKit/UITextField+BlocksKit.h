//
//  UITextField+BlocksKit.h
//  BlocksKit
//
//  Created by Samuel E. Giddins on 7/24/13.
//  Copyright (c) 2013 Pandamonia LLC. All rights reserved.
//

#import "BKGlobals.h"

/** Block callbacks for UITextField.
 
 @warning UITextField is only available on a platform with UIKit.
 */
@interface UITextField (BlocksKit)

@property (nonatomic, copy) BOOL(^shouldBeginEditingBlock)(UITextField *);
@property (nonatomic, copy) void(^didBeginEditingBlock)(UITextField *);
@property (nonatomic, copy) BOOL(^shouldEndEditingBlock)(UITextField *);
@property (nonatomic, copy) void(^didEndEditingBlock)(UITextField *);
@property (nonatomic, copy) BOOL(^shouldChangeCharactersInRangeWithReplacementStringBlock)(UITextField *, NSRange, NSString *);
@property (nonatomic, copy) BOOL(^shouldClearBlock)(UITextField *);
@property (nonatomic, copy) BOOL(^shouldReturnBlock)(UITextField *);

@end
