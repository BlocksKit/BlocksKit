//
//  UITextFieldBlocksKitTest.m
//  BlocksKit
//
//  Created by Samuel E. Giddins on 7/26/13.
//  Copyright (c) 2013 Pandamonia LLC. All rights reserved.
//

#import "UITextFieldBlocksKitTest.h"
#import "UITextField+BlocksKit.h"
#import "A2DynamicDelegate.h"

@interface UITextFieldBlocksKitTest ()

@property (nonatomic, retain) UITextField *subject;

@end

@implementation UITextFieldBlocksKitTest

- (void)setUp
{
    _subject = [[UITextField alloc] init];
}

- (void)testBlockDelegateMethods
{
    __block BOOL shouldBegin;
    __block BOOL didBegin;
    __block BOOL shouldEnd;
    __block BOOL didEnd;
    __block BOOL shouldChange;
    __block BOOL shouldClear;
    __block BOOL shouldReturn;
    
    self.subject.bk_shouldBeginEditingBlock = ^(UITextField *textField) { shouldBegin = YES; return YES; };
    self.subject.bk_didBeginEditingBlock = ^(UITextField *textField) { didBegin = YES; };
    self.subject.bk_shouldEndEditingBlock = ^(UITextField *textField) { shouldEnd = YES; return YES; };
    self.subject.bk_didEndEditingBlock = ^(UITextField *textField) { didEnd = YES; };
    self.subject.bk_shouldChangeCharactersInRangeWithReplacementStringBlock = ^(UITextField *textField, NSRange range, NSString *replacement) { shouldChange = YES; return YES; };
    self.subject.bk_shouldClearBlock = ^(UITextField *textField) { shouldClear = YES; return YES; };
    self.subject.bk_shouldReturnBlock = ^(UITextField *textField) { shouldReturn = YES; return YES; };
    
    [self.subject.bk_dynamicDelegate textFieldShouldBeginEditing:self.subject];
    [self.subject.bk_dynamicDelegate textFieldDidBeginEditing:self.subject];
    [self.subject.bk_dynamicDelegate textFieldShouldEndEditing:self.subject];
    [self.subject.bk_dynamicDelegate textFieldDidEndEditing:self.subject];
    [self.subject.bk_dynamicDelegate textField:self.subject shouldChangeCharactersInRange:NSMakeRange(0, 1) replacementString:@""];
    [self.subject.bk_dynamicDelegate textFieldShouldClear:self.subject];
    [self.subject.bk_dynamicDelegate textFieldShouldReturn:self.subject];
    
    STAssertTrue(shouldBegin, @"bk_shouldBeginEditingBlock didn't fire");
    STAssertTrue(didBegin, @"bk_didBeginEditingBlock didn't fire");
    STAssertTrue(shouldEnd, @"bk_shouldEndEditingBlock didn't fire");
    STAssertTrue(didEnd, @"bk_didEndEditingBlock didn't fire");
    STAssertTrue(shouldChange, @"bk_shouldChangeCharactersInRangeWithReplacementStringBlock didn't fire");
    STAssertTrue(shouldClear, @"bk_shouldClearBlock didn't fire");
    STAssertTrue(shouldReturn, @"bk_shouldReturnBlock didn't fire");
}

@end
