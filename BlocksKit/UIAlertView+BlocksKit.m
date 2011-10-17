//
//  UIAlertView+BlocksKit.m
//  BlocksKit
//

#import "UIAlertView+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"

@interface UIAlertView (BlocksKitPrivate)
@property (nonatomic, readonly) NSMutableDictionary *handlers;
@end

@implementation UIAlertView (BlocksKit)

static char *kAlertViewHandlerDictionaryKey = "UIAlertViewBlockHandlers";
static NSString *kAlertViewWillShowBlockKey = @"UIAlertViewWillShowBlock";
static NSString *kAlertViewDidShowBlockKey = @"UIAlertViewDidShowBlock";
static NSString *kAlertViewWillDismissBlockKey = @"UIAlertViewWillDismissBlock";
static NSString *kAlertViewDidDismissBlockKey = @"UIAlertViewDidDismissBlock";

#pragma mark - Convenience

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonText handler:(BKBlock)block {
    UIAlertView *alert = [UIAlertView alertWithTitle:title message:message];
    if (!buttonText || !buttonText.length)
        buttonText = NSLocalizedString(@"Dismiss", nil);
    [alert addButtonWithTitle:buttonText];
    if (block)
        alert.didDismissBlock = ^(NSUInteger index){
            block();
        };
    [alert show];
}

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
    [self.handlers setObject:handler forKey:[NSNumber numberWithInteger:index]];
    
    return index;
}

- (NSInteger)setCancelButtonWithTitle:(NSString *)title handler:(BKBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");    
    
    if (!title) title = NSLocalizedString(@"Cancel", nil);
    NSInteger index = [self addButtonWithTitle:title];
    self.cancelButtonIndex = index;
    
    block = BK_AUTORELEASE([block copy]);
    [self.handlers setObject:block forKey:[NSNumber numberWithInteger:index]];

    return index;
}

#pragma mark Properties

- (NSMutableDictionary *)handlers {
    NSMutableDictionary *handlers = [self associatedValueForKey:kAlertViewHandlerDictionaryKey];
    if (!handlers) {
        handlers = [NSMutableDictionary dictionary];
        [self associateValue:handlers withKey:kAlertViewHandlerDictionaryKey];
    }
    return handlers;
}

- (BKBlock)handlerForButtonAtIndex:(NSInteger)index {
    NSNumber *key = [NSNumber numberWithInteger:index];
    BKBlock block = [self.handlers objectForKey:key];
    return BK_AUTORELEASE([block copy]);
}

- (BKBlock)cancelBlock {
    NSNumber *key = [NSNumber numberWithInteger:self.cancelButtonIndex];
    BKBlock block = [self.handlers objectForKey:key];
    return BK_AUTORELEASE([block copy]);
}

- (void)setCancelBlock:(BKBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    
    if (self.cancelButtonIndex == -1) {
        [self setCancelButtonWithTitle:nil handler:block];
    } else {
        block = BK_AUTORELEASE([block copy]);
        NSNumber *key = [NSNumber numberWithInteger:self.cancelButtonIndex];
        [self.handlers setObject:block forKey:key];
    }
}

- (BKBlock)willShowBlock {
    BKBlock handler = [self.handlers objectForKey:kAlertViewWillShowBlockKey];
    return BK_AUTORELEASE([handler copy]);
}

- (void)setWillShowBlock:(BKBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    
    block = BK_AUTORELEASE([block copy]);
    [self.handlers setObject:block forKey:kAlertViewWillShowBlockKey];
}

- (BKBlock)didShowBlock {
    BKBlock block = [self.handlers objectForKey:kAlertViewDidShowBlockKey];
    return BK_AUTORELEASE([block copy]);
}

- (void)setDidShowBlock:(BKBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");

    block = BK_AUTORELEASE([block copy]);
    [self.handlers setObject:block forKey:kAlertViewDidShowBlockKey];
}

- (BKIndexBlock)willDismissBlock {
    BKBlock block = [self.handlers objectForKey:kAlertViewWillDismissBlockKey];
    return BK_AUTORELEASE([block copy]);
}

- (void)setWillDismissBlock:(BKIndexBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    
    block = BK_AUTORELEASE([block copy]);
    [self.handlers setObject:block forKey:kAlertViewWillDismissBlockKey];
}

- (BKIndexBlock)didDismissBlock {
    BKBlock block = [self.handlers objectForKey:kAlertViewDidDismissBlockKey];
    return BK_AUTORELEASE([block copy]);
}

- (void)setDidDismissBlock:(BKIndexBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    
    block = BK_AUTORELEASE([block copy]);
    [self.handlers setObject:block forKey:kAlertViewDidDismissBlockKey];
}

#pragma mark Delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    BKBlock block = [self.handlers objectForKey:[NSNumber numberWithInteger:buttonIndex]];
    if (block)
        block();
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    BKBlock block = [self.handlers objectForKey:kAlertViewWillShowBlockKey];
    if (block)
        block();
}

- (void)didPresentAlertView:(UIAlertView *)alertView {
    BKBlock block = [self.handlers objectForKey:kAlertViewDidShowBlockKey];
    if (block)
        block();
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    BKIndexBlock block = [self.handlers objectForKey:kAlertViewWillDismissBlockKey];
    if (block)
        block(buttonIndex);
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    BKIndexBlock block = [self.handlers objectForKey:kAlertViewDidDismissBlockKey];
    if (block)
        block(buttonIndex);
}

@end
