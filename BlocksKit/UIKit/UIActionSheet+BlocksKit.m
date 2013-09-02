//
//  UIActionSheet+BlocksKit.m
//  BlocksKit
//

#import "NSObject+A2BlockDelegate.h"
#import "NSObject+A2DynamicDelegate.h"
#import "UIActionSheet+BlocksKit.h"

#pragma mark Custom delegate

@interface A2DynamicUIActionSheetDelegate : A2DynamicDelegate <UIActionSheetDelegate>

@end

@implementation A2DynamicUIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)])
		[realDelegate actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
	
	void (^block)(void) = self.handlers[@(buttonIndex)];
	if (block) block();
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

+ (id)bk_actionSheetWithTitle:(NSString *)title {
	return [[[self class] alloc] bk_initWithTitle:title];
}

- (id)bk_initWithTitle:(NSString *)title {
	return [self initWithTitle:title delegate:self.bk_dynamicDelegate cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
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
	[self bk_setHandler:block forButtonAtIndex:self.cancelButtonIndex];
}

@end
