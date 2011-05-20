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

+ (id)alertWithTitle:(NSString *)title {
    return [[[UIAlertView alloc] initWithTitle:title message:nil] autorelease];
}

+ (id)alertWithTitle:(NSString *)title message:(NSString *)message {
    return [[[UIAlertView alloc] initWithTitle:title message:message] autorelease];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
    return [self initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
}

- (void)addButtonWithTitle:(NSString *)title handler:(BKBlock)block {
    NSAssert(title.length, @"A button without a title cannot be added to the alert view.");
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    if (!self.delegate)
        self.delegate = self;
    
    NSInteger index = [self addButtonWithTitle:title];
    [self.blocks setObject:(block ? [[block copy] autorelease] : [NSNull null]) forKey:[NSNumber numberWithInteger:index]];
}

- (void)setCancelButtonWithTitle:(NSString *)title handler:(BKBlock)block {
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    if (!self.delegate)
        self.delegate = self;
    
    if (!title) title = NSLocalizedString(@"Cancel", nil);
    NSInteger index = [self addButtonWithTitle:title];
    [self.blocks setObject:(block ? [[block copy] autorelease] : [NSNull null]) forKey:kAlertViewCancelBlockKey];
    self.cancelButtonIndex = index;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSMutableDictionary *blocks = self.blocks;
    
    __block BKBlock actionBlock = nil;
    
    if (buttonIndex == 0)
        actionBlock = [blocks objectForKey:kAlertViewCancelBlockKey];
    else
        actionBlock = [blocks objectForKey:[NSNumber numberWithInteger:buttonIndex]];
    
    if (actionBlock && (![actionBlock isEqual:[NSNull null]]))
        dispatch_async(dispatch_get_main_queue(), actionBlock);
                       
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
