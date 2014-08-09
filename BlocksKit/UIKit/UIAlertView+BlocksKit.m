//
//  UIAlertView+BlocksKit.m
//  BlocksKit
//

#import "A2DynamicDelegate.h"
#import "NSObject+A2BlockDelegate.h"
#import "NSObject+A2DynamicDelegate.h"
#import "UIAlertView+BlocksKit.h"

#pragma mark Delegate

@interface A2DynamicUIAlertViewDelegate : A2DynamicDelegate <UIAlertViewDelegate>

@end

@implementation A2DynamicUIAlertViewDelegate

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
	BOOL should = YES;
	
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(alertViewShouldEnableFirstOtherButton:)])
		should &= [realDelegate alertViewShouldEnableFirstOtherButton:alertView];
	
	BOOL (^block)(UIAlertView *) = [self blockImplementationForMethod:_cmd];
	if (block)
		should &= block(alertView);
	
	return should;
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(alertViewCancel:)])
		[realDelegate alertViewCancel:alertView];
	
	id key = @(alertView.cancelButtonIndex);
	void (^cancelBlock)(void) = (self.handlers)[key];
	if (cancelBlock)
		cancelBlock();
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(willPresentAlertView:)])
		[realDelegate willPresentAlertView:alertView];
	
	void (^block)(UIAlertView *) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(alertView);
}

- (void)didPresentAlertView:(UIAlertView *)alertView
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(didPresentAlertView:)])
		[realDelegate didPresentAlertView:alertView];
	
	void (^block)(UIAlertView *) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(alertView);
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)])
		[realDelegate alertView:alertView willDismissWithButtonIndex:buttonIndex];
	
	void (^block)(UIAlertView *, NSInteger) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(alertView, buttonIndex);
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)])
		[realDelegate alertView:alertView didDismissWithButtonIndex:buttonIndex];
	
	void (^block)(UIAlertView *, NSInteger) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(alertView, buttonIndex);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
		[realDelegate alertView:alertView clickedButtonAtIndex:buttonIndex];
	
	void (^block)(UIAlertView *, NSInteger) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(alertView, buttonIndex);
	
	id key = @(buttonIndex);
	void (^buttonBlock)(void) = (self.handlers)[key];
	if (buttonBlock)
		buttonBlock();
}

@end

#pragma mark - Category

@implementation UIAlertView (BlocksKit)

@dynamic bk_willShowBlock, bk_didShowBlock, bk_willDismissBlock, bk_didDismissBlock, bk_shouldEnableFirstOtherButtonBlock;

+ (void)load
{
	@autoreleasepool {
		[self bk_registerDynamicDelegate];
		[self bk_linkDelegateMethods:@{
			@"bk_willShowBlock": @"willPresentAlertView:",
			@"bk_didShowBlock": @"didPresentAlertView:",
			@"bk_willDismissBlock": @"alertView:willDismissWithButtonIndex:",
			@"bk_didDismissBlock": @"alertView:didDismissWithButtonIndex:",
			@"bk_shouldEnableFirstOtherButtonBlock": @"alertViewShouldEnableFirstOtherButton:"
		}];
	}
}

#pragma mark Convenience

+ (UIAlertView*)bk_showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles handler:(void (^)(UIAlertView *alertView, NSInteger buttonIndex))block
{
	// If no buttons were specified, cancel button becomes "Dismiss"
	if (!cancelButtonTitle.length && !otherButtonTitles.count)
		cancelButtonTitle = NSLocalizedString(@"Dismiss", nil);
	
	UIAlertView *alertView = [[[self class] alloc] initWithTitle:title message:message delegate:self.bk_dynamicDelegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];

	// Set other buttons
	[otherButtonTitles enumerateObjectsUsingBlock:^(NSString *button, NSUInteger idx, BOOL *stop) {
		[alertView addButtonWithTitle:button];
	}];

	// Set `didDismissBlock`
	if (block) alertView.bk_didDismissBlock = block;
	
	// Show alert view
	[alertView show];
	
	return alertView;
}

#pragma mark Initializers

+ (id)bk_alertViewWithTitle:(NSString *)title
{
	return [self bk_alertViewWithTitle:title message:nil];
}

+ (id)bk_alertViewWithTitle:(NSString *)title message:(NSString *)message
{
	return [[[self class] alloc] bk_initWithTitle:title message:message];
}

- (id)bk_initWithTitle:(NSString *)title message:(NSString *)message
{
	self = [self initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
	if (!self) return nil;

	self.delegate = self.bk_dynamicDelegate;

	return self;
}

#pragma Actions

- (NSInteger)bk_addButtonWithTitle:(NSString *)title handler:(void (^)(void))block
{
	NSAssert(title.length, @"A button without a title cannot be added to the alert view.");
	NSInteger index = [self addButtonWithTitle:title];
	[self bk_setHandler:block forButtonAtIndex:index];
	return index;
}

- (NSInteger)bk_setCancelButtonWithTitle:(NSString *)title handler:(void (^)(void))block
{
	if (!title.length)
		title = NSLocalizedString(@"Cancel", nil);
	NSInteger cancelButtonIndex = [self addButtonWithTitle:title];
	self.cancelButtonIndex = cancelButtonIndex;
	[self bk_setHandler:block forButtonAtIndex:cancelButtonIndex];
	return cancelButtonIndex;
}

#pragma mark Properties

- (void)bk_setHandler:(void (^)(void))block forButtonAtIndex:(NSInteger)index
{
	id key = @(index);
	if (block)
		[self.bk_dynamicDelegate handlers][key] = [block copy];
	else
		[[self.bk_dynamicDelegate handlers] removeObjectForKey:key];
}

- (void (^)(void))bk_handlerForButtonAtIndex:(NSInteger)index
{
	return [self.bk_dynamicDelegate handlers][@(index)];
}

- (void (^)(void))bk_cancelBlock
{
	return [self bk_handlerForButtonAtIndex:self.cancelButtonIndex];
}

- (void)bk_setCancelBlock:(void (^)(void))block
{
	if (block && self.cancelButtonIndex == -1) {
		[self bk_setCancelButtonWithTitle:nil handler:block];
		return;
	}
	
	[self bk_setHandler:block forButtonAtIndex:self.cancelButtonIndex];
}

@end
