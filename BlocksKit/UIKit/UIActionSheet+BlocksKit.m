//
//  UIActionSheet+BlocksKit.m
//  BlocksKit
//

#import "UIActionSheet+BlocksKit.h"

#pragma mark Custom delegate

@interface A2DynamicUIActionSheetDelegate : A2DynamicDelegate

@end

@implementation A2DynamicUIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)])
		[realDelegate actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
	
	id key = @(buttonIndex);
	BKBlock block = (self.handlers)[key];
	if (block)
		block();
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(willPresentActionSheet:)])
		[realDelegate willPresentActionSheet:actionSheet];

	void (^block)(UIActionSheet *) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(actionSheet);
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet {
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(didPresentActionSheet:)])
		[realDelegate didPresentActionSheet:actionSheet];
	
	void (^block)(UIActionSheet *) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(actionSheet);
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(actionSheet:willDismissWithButtonIndex:)])
		[realDelegate actionSheet:actionSheet willDismissWithButtonIndex:buttonIndex];
	
	void (^block)(UIActionSheet *, NSInteger) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(actionSheet, buttonIndex);
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)])
		[realDelegate actionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];

	void (^block)(UIActionSheet *, NSInteger) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(actionSheet, buttonIndex);
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(actionSheetCancel:)])
		[realDelegate actionSheetCancel:actionSheet];
	
	BKBlock block = actionSheet.cancelBlock;
	if (block)
		block();
}

@end

#pragma mark - Category

@implementation UIActionSheet (BlocksKit)

@dynamic willShowBlock, didShowBlock, willDismissBlock, didDismissBlock;

+ (void)load {
	@autoreleasepool {
		[self registerDynamicDelegate];
		[self linkDelegateMethods: @{
		 @"willShowBlock": @"willPresentActionSheet:",
		 @"didShowBlock": @"didPresentActionSheet:",
		 @"willDismissBlock": @"actionSheet:willDismissWithButtonIndex:",
		 @"didDismissBlock": @"actionSheet:didDismissWithButtonIndex:"
		}];
	}
}

#pragma mark Initializers

+ (id)actionSheetWithTitle:(NSString *)title {
	return [[[self class] alloc] initWithTitle:title];
}

- (id)initWithTitle:(NSString *)title {
	return [self initWithTitle:title delegate:self.dynamicDelegate cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
}

#pragma mark Actions

- (NSInteger)addButtonWithTitle:(NSString *)title handler:(BKBlock)block {
	NSAssert(title.length, @"A button without a title cannot be added to an action sheet.");
	NSInteger index = [self addButtonWithTitle:title];
	[self setHandler:block forButtonAtIndex:index];
	return index;
}

- (NSInteger)setDestructiveButtonWithTitle:(NSString *)title handler:(BKBlock)block {
	NSInteger index = [self addButtonWithTitle:title handler:block];
	self.destructiveButtonIndex = index;
	return index;
}
											
- (NSInteger)setCancelButtonWithTitle:(NSString *)title handler:(BKBlock)block {
	NSInteger cancelButtonIndex = self.cancelButtonIndex;

	if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && !title.length)
		title = NSLocalizedString(@"Cancel", nil);

	if (title.length)
		cancelButtonIndex = [self addButtonWithTitle:title];

	[self setHandler:block forButtonAtIndex:cancelButtonIndex];
	self.cancelButtonIndex = cancelButtonIndex;
	return cancelButtonIndex;
}

#pragma mark Properties

- (void)setHandler:(BKBlock)block forButtonAtIndex:(NSInteger)index {
	id key = @(index);
	
	if (block)
		[self.dynamicDelegate handlers][key] = [block copy];
	else
		[[self.dynamicDelegate handlers] removeObjectForKey:key];
}

- (BKBlock)handlerForButtonAtIndex:(NSInteger)index {
	id key = @(index);
	return [self.dynamicDelegate handlers][key];
}

- (BKBlock)cancelBlock {
	return [self handlerForButtonAtIndex:self.cancelButtonIndex];
}

- (void)setCancelBlock:(BKBlock)block {
	[self setHandler:block forButtonAtIndex:self.cancelButtonIndex];
}

@end
