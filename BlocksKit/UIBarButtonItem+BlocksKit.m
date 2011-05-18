//
//  UIBarButtonItem+BlocksKit.m
//  BlocksKit
//

#import "UIBarButtonItem+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"

static char kBarButtonItemBlockKey; 

@interface UIBarButtonItem (BlocksKitPrivate)
- (void)_handleAction:(UIBarButtonItem *)sender;
@end

@implementation UIBarButtonItem (BlocksKit)

- (id)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem handler:(void (^)(id sender))action {
    if ((self = [self initWithBarButtonSystemItem:systemItem target:self action:@selector(_handleAction:)])) {
        [self associateCopyOfValue:action withKey:&kBarButtonItemBlockKey];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style handler:(void (^)(id sender))action {
    if ((self = [self initWithImage:image style:style target:self action:@selector(_handleAction:)])) {
        [self associateCopyOfValue:action withKey:&kBarButtonItemBlockKey];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style handler:(void (^)(id sender))action {
    if ((self = [self initWithTitle:title style:style target:self action:@selector(_handleAction:)])) {
        [self associateCopyOfValue:action withKey:&kBarButtonItemBlockKey];
    }
    return self;
}

- (void)_handleAction:(UIBarButtonItem *)sender {
    __block void (^handler)(id sender) = [self associatedValueForKey:&kBarButtonItemBlockKey];
    if (handler)
        handler(sender);
}

@end
