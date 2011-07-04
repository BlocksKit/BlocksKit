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
static NSString *kAlertViewWillShowBlockKey = @"UIAlertViewWillShowBlock";
static NSString *kAlertViewDidShowBlockKey = @"UIAlertViewDidShowBlock";
static NSString *kAlertViewWillDismissBlockKey = @"UIAlertViewWillDismissBlock";
static NSString *kAlertViewDidDismissBlockKey = @"UIAlertViewDidDismissBlock";

#pragma mark Initializers

+ (id)alertWithTitle:(NSString *)title {
    return [self alertWithTitle:title message:nil];
}

+ (id)alertWithTitle:(NSString *)title message:(NSString *)message {
    return BK_AUTORELEASE([[UIAlertView alloc] initWithTitle:title message:message]);
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
    return [self initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
}

#pragma mark Public methods

- (NSInteger)addButtonWithTitle:(NSString *)title handler:(BKBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    
    NSAssert(title.length, @"A button without a title cannot be added to the alert view.");
    NSInteger index = [self addButtonWithTitle:title];
    
    BKBlock handler = BK_AUTORELEASE([block copy]);
    [self.blocks setObject:handler forKey:[NSNumber numberWithInteger:index]];
    
    return index;
}

- (NSInteger)setCancelButtonWithTitle:(NSString *)title handler:(BKBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");    
    
    if (!title) title = NSLocalizedString(@"Cancel", nil);
    NSInteger index = [self addButtonWithTitle:title];
    self.cancelButtonIndex = index;
    
    BKBlock handler = BK_AUTORELEASE([block copy]);
    [self.blocks setObject:handler forKey:[NSNumber numberWithInteger:index]];

    return index;
}

#pragma mark Properties

- (NSMutableDictionary *)blocks {
    NSMutableDictionary *blocks = [self associatedValueForKey:kAlertViewBlockDictionaryKey];
    if (!blocks) {
        blocks = [NSMutableDictionary dictionary];
        [self associateValue:blocks withKey:kAlertViewBlockDictionaryKey];
    }
    return blocks;
}

- (void)setBlocks:(NSMutableDictionary *)blocks {
    [self associateValue:blocks withKey:kAlertViewBlockDictionaryKey];
}

- (BKBlock)cancelBlock {
    NSNumber *key = [NSNumber numberWithInteger:self.cancelButtonIndex];
    return [self.blocks objectForKey:key];
}

- (void)setCancelBlock:(BKBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    
    if (self.cancelButtonIndex == -1) {
        [self setCancelButtonWithTitle:nil handler:block];
    } else {
        BKBlock handler = BK_AUTORELEASE([block copy]);
        NSNumber *key = [NSNumber numberWithInteger:self.cancelButtonIndex];
        
        [self.blocks setObject:handler forKey:key];
    }
}

- (BKBlock)willShowBlock {
    return [self.blocks objectForKey:kAlertViewWillShowBlockKey];    
}

- (void)setWillShowBlock:(BKBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    
    BKBlock handler = BK_AUTORELEASE([block copy]);
    [self.blocks setObject:handler forKey:kAlertViewWillShowBlockKey];
}

- (BKBlock)didShowBlock {
    return [self.blocks objectForKey:kAlertViewDidShowBlockKey];
}

- (void)setDidShowBlock:(BKBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");

    BKBlock handler = BK_AUTORELEASE([block copy]);
    [self.blocks setObject:handler forKey:kAlertViewDidShowBlockKey];
}

- (BKIndexBlock)willDismissBlock {
    return [self.blocks objectForKey:kAlertViewWillDismissBlockKey];
}

- (void)setWillDismissBlock:(BKIndexBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    
    BKIndexBlock handler = BK_AUTORELEASE([block copy]);
    [self.blocks setObject:handler forKey:kAlertViewWillDismissBlockKey];
}

- (BKIndexBlock)didDismissBlock {
    return [self.blocks objectForKey:kAlertViewDidDismissBlockKey];
}

- (void)setDidDismissBlock:(BKIndexBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    
    BKIndexBlock handler = BK_AUTORELEASE([block copy]);
    [self.blocks setObject:handler forKey:kAlertViewDidDismissBlockKey];
}

#pragma mark Delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    BKBlock block = [self.blocks objectForKey:[NSNumber numberWithInteger:buttonIndex]];
    if (block)
        block();
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    BKBlock block = [self.blocks objectForKey:kAlertViewWillShowBlockKey];
    if (block)
        block();
}

- (void)didPresentAlertView:(UIAlertView *)alertView {
    BKBlock block = [self.blocks objectForKey:kAlertViewDidShowBlockKey];
    if (block)
        block();
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    BKIndexBlock block = [self.blocks objectForKey:kAlertViewWillDismissBlockKey];
    if (block)
        block(buttonIndex);
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    BKIndexBlock block = [self.blocks objectForKey:kAlertViewDidDismissBlockKey];
    if (block)
        block(buttonIndex);
}

@end
