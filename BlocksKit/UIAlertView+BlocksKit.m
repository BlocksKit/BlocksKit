//
//  UIAlertView+BlocksKit.m
//  BlocksKit
//

#import "UIAlertView+BlocksKit.h"
#import "A2BlockDelegate+BlocksKit.h"

#pragma mark Delegate

@interface A2DynamicUIAlertViewDelegate : A2DynamicDelegate <UIAlertViewDelegate>

@end

@implementation A2DynamicUIAlertViewDelegate

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
	BOOL should = YES;
	
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(alertViewShouldEnableFirstOtherButton:)])
		should &= [realDelegate alertViewShouldEnableFirstOtherButton:alertView];
	
	BOOL (^block)(UIAlertView *) = [self blockImplementationForMethod:_cmd];
	if (block)
		should &= block(alertView);
	
	return should;
}

- (void)alertViewCancel:(UIAlertView *)alertView {
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(alertViewCancel:)])
		return [realDelegate alertViewCancel:alertView];
	
	id key = [NSNumber numberWithInteger:alertView.cancelButtonIndex];
	BKBlock cancelBlock = [self.handlers objectForKey:key];
	if (cancelBlock)
		cancelBlock();
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(willPresentAlertView:)])
		return [realDelegate willPresentAlertView:alertView];
	
	void (^block)(UIAlertView *) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(alertView);
}

- (void)didPresentAlertView:(UIAlertView *)alertView {
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(didPresentAlertView:)])
		return [realDelegate didPresentAlertView:alertView];
	
	void (^block)(UIAlertView *) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(alertView);
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)])
		[realDelegate alertView:alertView willDismissWithButtonIndex:buttonIndex];
	
	void (^block)(UIAlertView *, NSInteger) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(alertView, buttonIndex);
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)])
		[realDelegate alertView:alertView didDismissWithButtonIndex:buttonIndex];
	
	void (^block)(UIAlertView *, NSInteger) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(alertView, buttonIndex);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
		[realDelegate alertView:alertView clickedButtonAtIndex:buttonIndex];
	
	void (^block)(UIAlertView *, NSInteger) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(alertView, buttonIndex);
	
	if (buttonIndex == alertView.cancelButtonIndex)
		return;
	
	id key = [NSNumber numberWithInteger:buttonIndex];
	BKBlock buttonBlock = [self.handlers objectForKey: key];
	if (buttonBlock)
		buttonBlock();
}

@end

#pragma mark - Category

@implementation UIAlertView (BlocksKit)

@dynamic willShowBlock, didShowBlock, willDismissBlock, didDismissBlock, shouldEnableFirstOtherButtonBlock;

+ (void)load {
	@autoreleasepool {
		[self registerDynamicDelegate];
		NSDictionary *methods = [NSDictionary dictionaryWithObjectsAndKeys:
								 @"willPresentAlertView:", @"willShowBlock",
								 @"didPresentAlertView:", @"didShowBlock",
								 @"alertView:willDismissWithButtonIndex:", @"willDismissBlock",
								 @"alertView:didDismissWithButtonIndex:", @"didDismissBlock",
								 @"alertViewShouldEnableFirstOtherButton:", @"shouldEnableFirstOtherButtonBlock",
								 nil];
		[self linkDelegateMethods:methods];
	}
}

#pragma mark Convenience

+ (void) showAlertViewWithTitle: (NSString *) title message: (NSString *) message didDismissHandler: (void (^)(UIAlertView *, NSInteger)) block cancelButtonTitle: (NSString *) cancelButtonTitle otherButtonTitles: (NSString *) otherButtonTitles, ...
{
	UIAlertView *alertView = [UIAlertView alertViewWithTitle: title message: message];
	
	// If no buttons were specified, cancel button becomes "Dismiss"
	if (!cancelButtonTitle.length && !otherButtonTitles)
		cancelButtonTitle = NSLocalizedString(@"Dismiss", nil);
	
	// Set cancel button
	alertView.cancelButtonIndex = [alertView addButtonWithTitle: cancelButtonTitle];
	
	// Set the rest of the buttons
	va_list buttons;
	va_start(buttons, otherButtonTitles);
	NSString *button = otherButtonTitles;
	do
	{
		[alertView addButtonWithTitle: button];
	}
	while ((button = va_arg(buttons, NSString *)));
	
	// Set `didDismissBlock`
	if (block) alertView.didDismissBlock = block;
	
	// Show alert view
	[alertView show];
}

#pragma mark Initializers

+ (id)alertViewWithTitle:(NSString *)title {
	return [self alertViewWithTitle:title message:nil];
}

+ (id)alertViewWithTitle:(NSString *)title message:(NSString *)message {
	return BK_AUTORELEASE([[UIAlertView alloc] initWithTitle:title message:message]);
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
	return [self initWithTitle:title message:message delegate:self.dynamicDelegate cancelButtonTitle:nil otherButtonTitles:nil];
}

#pragma Actions

- (NSInteger)addButtonWithTitle:(NSString *)title handler:(BKBlock)block {
	NSAssert(title.length, @"A button without a title cannot be added to the alert view.");
	NSInteger index = [self addButtonWithTitle:title];
	
	id key = [NSNumber numberWithInteger:index];

	if (block)
		[[self.dynamicDelegate handlers] setObject:block forKey:key];
	else
		[[self.dynamicDelegate handlers] removeObjectForKey:key];
	
	return index;
}

- (NSInteger)setCancelButtonWithTitle:(NSString *)title handler:(BKBlock)block {
	if (!title) title = NSLocalizedString(@"Cancel", nil);
	NSInteger cancelButtonIndex = [self addButtonWithTitle:title];
	self.cancelButtonIndex = cancelButtonIndex;
	[self setCancelBlock:block];
	return cancelButtonIndex;
}

#pragma mark Properties

- (BKBlock)handlerForButtonAtIndex:(NSInteger)index {
	id key = [NSNumber numberWithInteger:index];
	return [[self.dynamicDelegate handlers] objectForKey:key];
}

- (BKBlock)cancelBlock {
	return [self handlerForButtonAtIndex:self.cancelButtonIndex];
}

- (void)setCancelBlock:(BKBlock)block {
	if (self.cancelButtonIndex == -1) {
		[self setCancelButtonWithTitle:nil handler:block];
	} else {
		id key = [NSNumber numberWithInteger:self.cancelButtonIndex];
		
		if (block)
			[[self.dynamicDelegate handlers] setObject:block forKey:key];
		else
			[[self.dynamicDelegate handlers] removeObjectForKey:key];
	}
}

@end