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

static char *kAlertViewBlockDictionaryKey = "UIAlertViewBlockHandlers";
static NSString *kAlertViewCancelBlockKey = @"UIAlertViewCancelBlock";
static NSString *kAlertViewWillShowBlockKey = @"UIAlertViewWillShowBlock";
static NSString *kAlertViewDidShowBlockKey = @"UIAlertViewDidShowBlock";
static NSString *kAlertViewWillDismissBlockKey = @"UIAlertViewWillDismissBlock";
static NSString *kAlertViewDidDismissBlockKey = @"UIAlertViewDidDismissBlock";

#pragma mark Initializers

+ (id)alertWithTitle:(NSString *)title {
    return [[[UIAlertView alloc] initWithTitle:title message:nil] autorelease];
}

+ (id)alertWithTitle:(NSString *)title message:(NSString *)message {
    return [[[UIAlertView alloc] initWithTitle:title message:message] autorelease];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
    return [self initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
}

#pragma mark Public methods

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

#pragma mark Delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSMutableDictionary *blocks = self.blocks;
    
    BKBlock block = nil;
    
    if (buttonIndex == 0)
        block = [blocks objectForKey:kAlertViewCancelBlockKey];
    else
        block = [blocks objectForKey:[NSNumber numberWithInteger:buttonIndex]];
    
    if (block && (![block isEqual:[NSNull null]]))
        block();
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    BKBlock block = [self.blocks objectForKey:kAlertViewWillShowBlockKey];
    if (block && (![block isEqual:[NSNull null]]))
        block();
}

- (void)didPresentAlertView:(UIAlertView *)alertView {
    BKBlock block = [self.blocks objectForKey:kAlertViewDidShowBlockKey];
    if (block && (![block isEqual:[NSNull null]]))
        block();
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    BKIndexBlock block = [self.blocks objectForKey:kAlertViewWillDismissBlockKey];
    if (block && (![block isEqual:[NSNull null]]))
        block(buttonIndex);
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    BKIndexBlock block = [self.blocks objectForKey:kAlertViewDidDismissBlockKey];
    if (block && (![block isEqual:[NSNull null]]))
        block(buttonIndex);
}

#pragma mark Properties

- (NSMutableDictionary *)blocks {
    NSMutableDictionary *blocks = [self associatedValueForKey:kAlertViewBlockDictionaryKey];
    if (!blocks)
        self.blocks = [NSMutableDictionary dictionary];
    return blocks;
}

- (void)setBlocks:(NSMutableDictionary *)blocks {
    [self associateValue:blocks withKey:kAlertViewBlockDictionaryKey];
}

- (BKBlock)cancelBlock {
    return [self.blocks objectForKey:kAlertViewCancelBlockKey];
}

- (void)setCancelBlock:(BKBlock)block {
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    if (!self.delegate)
        self.delegate = self;
    if (self.cancelButtonIndex == -1)
        [self setCancelButtonWithTitle:nil handler:block];
    else
        [self.blocks setObject:(block ? [[block copy] autorelease] : [NSNull null]) forKey:kAlertViewCancelBlockKey];
}

- (BKBlock)willShowBlock {
    return [self.blocks objectForKey:kAlertViewWillShowBlockKey];    
}

- (void)setWillShowBlock:(BKBlock)block {
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    if (!self.delegate)
        self.delegate = self;
    [self.blocks setObject:(block ? [[block copy] autorelease] : [NSNull null]) forKey:kAlertViewWillShowBlockKey];
}

- (BKBlock)didShowBlock {
    return [self.blocks objectForKey:kAlertViewDidShowBlockKey];
}

- (void)setDidShowBlock:(BKBlock)block {
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    if (!self.delegate)
        self.delegate = self;
    [self.blocks setObject:(block ? [[block copy] autorelease] : [NSNull null]) forKey:kAlertViewDidShowBlockKey];
}

- (BKIndexBlock)willDismissBlock {
    return [self.blocks objectForKey:kAlertViewWillDismissBlockKey];
}

- (void)setWillDismissBlock:(BKIndexBlock)block {
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    if (!self.delegate)
        self.delegate = self;
    [self.blocks setObject:(block ? [[block copy] autorelease] : [NSNull null]) forKey:kAlertViewWillDismissBlockKey];
}

- (BKIndexBlock)didDismissBlock {
    return [self.blocks objectForKey:kAlertViewDidDismissBlockKey];
}

- (void)setDidDismissBlock:(BKIndexBlock)block {
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    if (!self.delegate)
        self.delegate = self;
    [self.blocks setObject:(block ? [[block copy] autorelease] : [NSNull null]) forKey:kAlertViewDidDismissBlockKey];
}

@end
