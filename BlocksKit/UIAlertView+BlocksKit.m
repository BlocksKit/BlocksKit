//
//  UIAlertView+BlocksKit.m
//  BlocksKit
//

#import "UIAlertView+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"

@implementation UIAlertView (BlocksKit)

static char kAlertViewBlockArrayKey; 
static char kAlertViewCancelBlockKey; 

+ (UIAlertView *)alertWithTitle:(NSString *)title {
    return [[[UIAlertView alloc] initWithTitle:title message:nil] autorelease];
}

+ (UIAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message {
    return [[[UIAlertView alloc] initWithTitle:title message:message] autorelease];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
    self = [self initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:nil];
    return self;
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block {
    NSAssert(title.length, @"A button without a title cannot be added to the alert view.");
    
    NSMutableArray *blocks = [self associatedValueForKey:&kAlertViewBlockArrayKey];
    if (!blocks) {
        blocks = [[NSMutableArray alloc] init];
        [self associateValue:blocks withKey:&kAlertViewBlockArrayKey];
        [blocks release];
    }
    
    if (block)
        [blocks addObject:[[block copy] autorelease]];
    else
        [blocks addObject:[NSNull null]];
    
    [self addButtonWithTitle:title];
}

- (void)setCancelBlock:(void (^)())block {
    void (^cancel)() = [self associatedValueForKey:&kAlertViewCancelBlockKey];
    if (cancel != block) {
        [self associateCopyOfValue:block withKey:&kAlertViewCancelBlockKey];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {    
    if (buttonIndex == 0) {
        void (^cancelBlock)() = [self associatedValueForKey:&kAlertViewCancelBlockKey];
        if (cancelBlock)
            cancelBlock();
    } else {
        NSMutableArray *blocks = [self associatedValueForKey:&kAlertViewBlockArrayKey];
        if (blocks) {
            if (buttonIndex <= blocks.count) {
                void (^actionBlock)() = [blocks objectAtIndex:buttonIndex-1];
                if (actionBlock && (![actionBlock isEqual:[NSNull null]]))
                    actionBlock();
            }
        }
    }
    [self associateValue:nil withKey:&kAlertViewCancelBlockKey];
    [self associateValue:nil withKey:&kAlertViewBlockArrayKey];
}

@end
