//
//  UITextView+BlocksKit.h
//  BlocksKit
//

#import "UITextView+BlocksKit.h"
#import "A2DynamicDelegate.h"
#import "NSObject+A2BlockDelegate.h"

#pragma mark Delegate

@interface A2DynamicUITextViewDelegate : A2DynamicDelegate

@end

@implementation A2DynamicUITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
	BOOL ret = YES;
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(textViewShouldBeginEditing:)])
		ret = [realDelegate textViewShouldBeginEditing:textView];
	BOOL (^block)(UITextView *) = [self blockImplementationForMethod:_cmd];
	if (block)
		ret &= block(textView);
	return ret;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(textViewDidBeginEditing:)])
		[realDelegate textViewDidBeginEditing:textView];
	void (^block)(UITextView *) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(textView);
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
	BOOL ret = YES;
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(textViewShouldEndEditing:)])
		ret = [realDelegate textViewShouldEndEditing:textView];
	BOOL (^block)(UITextView *) = [self blockImplementationForMethod:_cmd];
	if (block)
		ret &= block(textView);
	return ret;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(textViewDidEndEditing:)])
		[realDelegate textViewDidEndEditing:textView];
	void (^block)(UITextView *) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(textView);
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	BOOL ret = YES;
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)])
		ret = [realDelegate textView:textView shouldChangeTextInRange:range replacementText:text];
	BOOL (^block)(UITextView *, NSRange, NSString *) = [self blockImplementationForMethod:_cmd];
	if (block)
		ret &= block(textView, range, text);
	return ret;
}

- (void)textViewDidChange:(UITextView *)textView
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(textViewDidChange:)])
		[realDelegate textViewDidChange:textView];
	void (^block)(UITextView *) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(textView);
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(textViewDidChangeSelection:)])
		[realDelegate textViewDidChangeSelection:textView];
	void (^block)(UITextView *) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(textView);
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange
{
	BOOL ret = YES;
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(textView:shouldInteractWithTextAttachment:inRange:)])
		ret = [realDelegate textView:textView shouldInteractWithTextAttachment:textAttachment inRange:characterRange];
	BOOL (^block)(UITextView *, NSTextAttachment *, NSRange) = [self blockImplementationForMethod:_cmd];
	if (block)
		ret &= block(textView, textAttachment, characterRange);
	return ret;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
	BOOL ret = YES;
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:)])
		ret = [realDelegate textView:textView shouldInteractWithURL:URL inRange:characterRange];
	BOOL (^block)(UITextView *, NSURL *, NSRange) = [self blockImplementationForMethod:_cmd];
	if (block)
		ret &= block(textView, URL, characterRange);
	return ret;
}

@end

#pragma mark - Category

@implementation UITextView (BlocksKit)

@dynamic bk_shouldBeginEditingBlock, bk_didBeginEditingBlock, bk_shouldEndEditingBlock, bk_didEndEditingBlock, bk_shouldChangeCharactersInRangeWithReplacementTextBlock, bk_didChangeBlock, bk_didChangeSelecionBlock, bk_shouldInteractWithTextAttachmentInRangeBlock, bk_shouldInteractWithURLInRangeBlock;

+ (void)load {
	[self bk_registerDynamicDelegate];
	[self bk_linkDelegateMethods: @{
									@"bk_shouldBeginEditingBlock":
										@"textViewShouldBeginEditing:",
									
									@"bk_didBeginEditingBlock":
										@"textViewDidBeginEditing:",
									
									@"bk_shouldEndEditingBlock":
										@"textViewDidBeginEditing:",
									
									@"bk_didEndEditingBlock" :
										@"textViewDidEndEditing:",
									
									@"bk_shouldChangeCharactersInRangeWithReplacementTextBlock" :
										@"textView:shouldChangeTextInRange:replacementText:",
									
									@"bk_didChangeBlock" :
										@"textViewDidChange:",
									
									@"bk_didChangeSelecionBlock" :
										@"textViewDidChangeSelection:",
									
									@"bk_shouldInteractWithTextAttachmentInRangeBlock" :
										@"textView:shouldInteractWithTextAttachment:inRange:",
									
									@"bk_shouldInteractWithURLInRangeBlock" :
										@"textView:shouldInteractWithURL:inRange:",
									}];
}

@end
