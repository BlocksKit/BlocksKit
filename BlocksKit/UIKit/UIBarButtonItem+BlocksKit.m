//
//  UIBarButtonItem+BlocksKit.m
//  BlocksKit
//

#import "UIBarButtonItem+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"

static char kBarButtonItemBlockKey;

@interface UIBarButtonItem (BlocksKitPrivate)
- (void)bk__handleAction:(UIBarButtonItem *)sender;
@end

@implementation UIBarButtonItem (BlocksKit)

- (id)bk_initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem handler:(BKSenderBlock)action
{
	self = [self initWithBarButtonSystemItem:systemItem target:self action:@selector(bk_handleAction:)];
	if (!self) return nil;
	
	[self bk_associateCopyOfValue:action withKey:&kBarButtonItemBlockKey];
	
	return self;
}

- (id)bk_initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style handler:(BKSenderBlock)action
{
	self = [self initWithImage:image style:style target:self action:@selector(bk_handleAction:)];
	if (!self) return nil;
	
	[self bk_associateCopyOfValue:action withKey:&kBarButtonItemBlockKey];
	
	return self;
}

- (id)bk_initWithImage:(UIImage *)image landscapeImagePhone:(UIImage *)landscapeImagePhone style:(UIBarButtonItemStyle)style handler:(BKSenderBlock)action
{
	self = [self initWithImage:image landscapeImagePhone:landscapeImagePhone style:style target:self action:@selector(bk_handleAction:)];
	if (!self) return nil;
	
	[self bk_associateCopyOfValue:action withKey:&kBarButtonItemBlockKey];
	
	return self;
}

- (id)bk_initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style handler:(BKSenderBlock)action
{
	self = [self initWithTitle:title style:style target:self action:@selector(bk_handleAction:)];
	if (!self) return nil;
	
	[self bk_associateCopyOfValue:action withKey:&kBarButtonItemBlockKey];
	
	return self;
}

- (void)bk_handleAction:(UIBarButtonItem *)sender
{
	BKSenderBlock block = [self bk_associatedValueForKey:&kBarButtonItemBlockKey];
	if (block) block(self);
}

@end
