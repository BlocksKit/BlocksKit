//
//  UIAlertView+BlocksKit.m
//  BlocksKit
//

#import "UIAlertView+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"

@interface UIAlertView (BlocksKitPrivate)
@property (nonatomic, retain) NSMutableDictionary *blocks;
@end

@implementation UIAlertView (BlocksKit)

static char kAlertViewBlockDictionaryKey; 
static NSString *kAlertViewCancelBlockKey = @"UIAlertViewCancelBlock";

+ (UIAlertView *)alertWithTitle:(NSString *)title {
    return [[[UIAlertView alloc] initWithTitle:title message:nil] autorelease];
}

+ (UIAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message {
    return [[[UIAlertView alloc] initWithTitle:title message:message] autorelease];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
    return [self initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:nil];
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block {
    NSAssert(title.length, @"A button without a title cannot be added to the alert view.");
    NSInteger index = [self addButtonWithTitle:title];
    [self.blocks setObject:(block ? [[block copy] autorelease] : [NSNull null]) forKey:[NSNumber numberWithInteger:index]];
}

- (void)setCancelBlock:(void (^)())block {
    [self.blocks setObject:(block ? [[block copy] autorelease] : [NSNull null]) forKey:kAlertViewCancelBlockKey];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSMutableDictionary *blocks = self.blocks;
    
    void (^actionBlock)() = nil;
    
    if (buttonIndex == 0)
        actionBlock = [blocks objectForKey:kAlertViewCancelBlockKey];
    else
        actionBlock = [blocks objectForKey:[NSNumber numberWithInteger:buttonIndex]];
    
    if (actionBlock && (![actionBlock isEqual:[NSNull null]]))
        actionBlock();
                       
    self.blocks = nil;
}

- (NSMutableDictionary *)blocks {
    NSMutableDictionary *blocks = [self associatedValueForKey:&kAlertViewBlockDictionaryKey];
    if (!blocks) {
        blocks = [[NSMutableDictionary alloc] init];
        self.blocks = blocks;
        [blocks release];
    }
    return blocks;
}

- (void)setBlocks:(NSMutableDictionary *)blocks {
    [self associateValue:blocks withKey:&kAlertViewBlockDictionaryKey];
}

@end
