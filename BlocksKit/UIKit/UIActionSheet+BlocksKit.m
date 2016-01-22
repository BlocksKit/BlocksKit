//
//  UIActionSheet+BlocksKit.m
//  BlocksKit
//

#import "UIActionSheet+BlocksKit.h"
#import "A2DynamicDelegate.h"
#import "NSObject+A2DynamicDelegate.h"
#import "NSObject+A2BlockDelegate.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#pragma mark Custom delegate

@interface A2DynamicUIActionSheetDelegate : A2DynamicDelegate <UIActionSheetDelegate>

@property (nonatomic, assign) BOOL didHandleButtonClick;

@end

@implementation A2DynamicUIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)])
		[realDelegate actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];

	void (^handler)(void) = self.handlers[@(buttonIndex)];

	// Note: On iPad with iOS 8 GM seed, `actionSheet:clickedButtonAtIndex:` always gets called twice if you tap any button other than Cancel;
	// In other words, assume you have two buttons: OK and Cancel; if you tap OK, this method will be called once for the OK button and once
	// for the Cancel button. This could result in some really obscure bugs, so adding `didHandleButtonClick` property maintains iOS 7 compatibility.
	if (handler && self.didHandleButtonClick == NO) {
		self.didHandleButtonClick = YES;

		// Presenting view controllers from within action sheet delegate does not work on iPad running iOS 8 GM seed, without delay
		dispatch_async(dispatch_get_main_queue(), handler);
	}
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(willPresentActionSheet:)])
		[realDelegate willPresentActionSheet:actionSheet];

	void (^block)(UIActionSheet *) = [self blockImplementationForMethod:_cmd];
	if (block) block(actionSheet);
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(didPresentActionSheet:)])
		[realDelegate didPresentActionSheet:actionSheet];

	void (^block)(UIActionSheet *) = [self blockImplementationForMethod:_cmd];
	if (block) block(actionSheet);
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(actionSheet:willDismissWithButtonIndex:)])
		[realDelegate actionSheet:actionSheet willDismissWithButtonIndex:buttonIndex];

	void (^block)(UIActionSheet *, NSInteger) = [self blockImplementationForMethod:_cmd];
	if (block) block(actionSheet, buttonIndex);
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)])
		[realDelegate actionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];

	void (^block)(UIActionSheet *, NSInteger) = [self blockImplementationForMethod:_cmd];
	if (block) block(actionSheet, buttonIndex);
	self.didHandleButtonClick = NO;
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(actionSheetCancel:)])
		[realDelegate actionSheetCancel:actionSheet];

	void (^block)(void) = actionSheet.bk_cancelBlock;
	if (block) block();
}

@end

#pragma mark - Category

@implementation UIActionSheet (BlocksKit)

@dynamic bk_willShowBlock, bk_didShowBlock, bk_willDismissBlock, bk_didDismissBlock;

+ (void)load
{
	@autoreleasepool {
		[self bk_registerDynamicDelegate];
		[self bk_linkDelegateMethods:@{
			@"bk_willShowBlock": @"willPresentActionSheet:",
			@"bk_didShowBlock": @"didPresentActionSheet:",
			@"bk_willDismissBlock": @"actionSheet:willDismissWithButtonIndex:",
			@"bk_didDismissBlock": @"actionSheet:didDismissWithButtonIndex:"
		}];
	}
}

#pragma mark Initializers

+ (instancetype)bk_actionSheetWithTitle:(NSString *)title {
	return [[[self class] alloc] bk_initWithTitle:title];
}

- (instancetype)bk_initWithTitle:(NSString *)title {
	self = [self initWithTitle:title delegate:self.bk_dynamicDelegate cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	if (!self) { return nil; }
	self.delegate = self.bk_dynamicDelegate;
	return self;
}

#pragma mark Actions

- (NSInteger)bk_addButtonWithTitle:(NSString *)title handler:(void (^)(void))block {
	NSAssert(title.length, @"A button without a title cannot be added to an action sheet.");
	NSInteger index = [self addButtonWithTitle:title];
	[self bk_setHandler:block forButtonAtIndex:index];
	return index;
}

- (NSInteger)bk_setDestructiveButtonWithTitle:(NSString *)title handler:(void (^)(void))block {
	NSInteger index = [self bk_addButtonWithTitle:title handler:block];
	self.destructiveButtonIndex = index;
	return index;
}

- (NSInteger)bk_setCancelButtonWithTitle:(NSString *)title handler:(void (^)(void))block {
	NSInteger cancelButtonIndex = self.cancelButtonIndex;

	if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && !title.length)
		title = NSLocalizedString(@"Cancel", nil);

	if (title.length)
		cancelButtonIndex = [self addButtonWithTitle:title];

	[self bk_setHandler:block forButtonAtIndex:cancelButtonIndex];
	self.cancelButtonIndex = cancelButtonIndex;
	return cancelButtonIndex;
}

#pragma mark Properties

- (void)bk_setHandler:(void (^)(void))block forButtonAtIndex:(NSInteger)index {
	A2DynamicUIActionSheetDelegate *delegate = self.bk_ensuredDynamicDelegate;

	if (block) {
		delegate.handlers[@(index)] = [block copy];
	} else {
		[delegate.handlers removeObjectForKey:@(index)];
	}
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
	[self bk_setHandler:block forButtonAtIndex:self.cancelButtonIndex];
}

@end

#pragma clang diagnostic pop
