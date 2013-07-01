//
//  UIBarButtonItem+BlocksKit.m
//  BlocksKit
//

#import "NSObject+BKAssociatedObjects.h"
#import "UIBarButtonItem+BlocksKit.h"

static const void *BKBarButtonItemBlockKey = &BKBarButtonItemBlockKey;

@interface UIBarButtonItem (BlocksKitPrivate)

- (void)bk_handleAction:(UIBarButtonItem *)sender;

@end

@implementation UIBarButtonItem (BlocksKit)

- (id)bk_initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem handler:(void (^)(id sender))action
{
	self = [self initWithBarButtonSystemItem:systemItem target:self action:@selector(bk_handleAction:)];
	if (!self) return nil;
	
	[self bk_associateCopyOfValue:action withKey:BKBarButtonItemBlockKey];
	
	return self;
}

- (id)bk_initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style handler:(void (^)(id sender))action
{
	self = [self initWithImage:image style:style target:self action:@selector(bk_handleAction:)];
	if (!self) return nil;
	
	[self bk_associateCopyOfValue:action withKey:BKBarButtonItemBlockKey];
	
	return self;
}

- (id)bk_initWithImage:(UIImage *)image landscapeImagePhone:(UIImage *)landscapeImagePhone style:(UIBarButtonItemStyle)style handler:(void (^)(id sender))action
{
	self = [self initWithImage:image landscapeImagePhone:landscapeImagePhone style:style target:self action:@selector(bk_handleAction:)];
	if (!self) return nil;
	
	[self bk_associateCopyOfValue:action withKey:BKBarButtonItemBlockKey];
	
	return self;
}

- (id)bk_initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style handler:(void (^)(id sender))action
{
	self = [self initWithTitle:title style:style target:self action:@selector(bk_handleAction:)];
	if (!self) return nil;
	
	[self bk_associateCopyOfValue:action withKey:BKBarButtonItemBlockKey];
	
	return self;
}

- (void)bk_handleAction:(UIBarButtonItem *)sender
{
	void (^block)(id) = [self bk_associatedValueForKey:BKBarButtonItemBlockKey];
	if (block) block(self);
}

@end
