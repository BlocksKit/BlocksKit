//
//  UIAlertView+BlocksKit.m
//  BlocksKit
//

#import "UIAlertView+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"
#import "NSObject+BlocksKit.h"

#pragma mark - Delegate proxy
@interface BKAlertViewDelegate : NSObject<UIAlertViewDelegate>

+ (id)shared;

@end

@implementation BKAlertViewDelegate

+ (id)shared {
    static id __strong proxyDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        proxyDelegate = [BKAlertViewDelegate new];
    });
    return proxyDelegate;
}

#pragma mark Responding to Actions
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.delegate && [alertView.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
        [alertView.delegate alertView:alertView clickedButtonAtIndex:buttonIndex];
    
    BKBlock block = [alertView handlerForButtonAtIndex:buttonIndex];
    if (block)
        block();
}

#pragma mark Customizing Behavior
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    if (alertView.delegate && [alertView.delegate respondsToSelector:@selector(alertViewShouldEnableFirstOtherButton:)])
        return [alertView.delegate alertViewShouldEnableFirstOtherButton:alertView];
    
    return YES;
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    if (alertView.delegate && [alertView.delegate respondsToSelector:@selector(willPresentAlertView:)])
        [alertView.delegate willPresentAlertView:alertView];    
    
    BKBlock block = alertView.willShowHandler;
    if (block)
        block();
}

- (void)didPresentAlertView:(UIAlertView *)alertView {
    if (alertView.delegate && [alertView.delegate respondsToSelector:@selector(didPresentAlertView:)])
        [alertView.delegate didPresentAlertView:alertView];
    
    BKBlock block = alertView.didShowHandler;
    if (block)
        block();
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.delegate && [alertView.delegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)])
        [alertView.delegate alertView:alertView willDismissWithButtonIndex:buttonIndex];
    
    BKIndexBlock block = alertView.willDismissHandler;
    if (block)
        block(buttonIndex);
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.delegate && [alertView.delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)])
        [alertView.delegate alertView:alertView didDismissWithButtonIndex:buttonIndex];    
    
    BKIndexBlock block = alertView.didDismissHandler;
    if (block)
        block(buttonIndex);
}

#pragma mark Canceling
- (void)alertViewCancel:(UIAlertView *)alertView {
    if (alertView.delegate && [alertView.delegate respondsToSelector:@selector(alertViewCancel)])
        [alertView.delegate alertViewCancel:alertView];
    
    BKBlock block = alertView.cancelHandler;
    if (block)
        block();
}

@end

#pragma mark - constants
static char *kAlertViewButtonHandlersDictionaryKey = "BKAlertViewButtonHandlersDictionary";

static char *kAlertViewWillShowHandlerKey    = "BKAlertViewWillShowHandler";
static char *kAlertViewDidShowHandlerKey     = "BKAlertViewDidShowHandler";
static char *kAlertViewWillDismissHandlerKey = "BKAlertViewWillDismissHandler";
static char *kAlertViewDidDismissHandlerKey  = "BKAlertViewDidDismissHandler";

static char *kDelegateKey = "BKAlertViewDelegate";

#pragma mark - Private
@interface UIAlertView (BlocksKitPrivate)
@property (nonatomic, retain) NSMutableDictionary *buttonHandlers;
@end

#pragma mark -
@implementation UIAlertView (BlocksKit)

#pragma mark Methods swizzling
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSelector:@selector(delegate) withSelector:@selector(bk_delegate)];
        [self swizzleSelector:@selector(setDelegate:) withSelector:@selector(bk_setDelegate:)];
    });
}

#pragma mark Delegation
- (id)bk_delegate {
    return [self associatedValueForKey:kDelegateKey];
}

- (void)bk_setDelegate:(id)delegate {
    [self weaklyAssociateValue:delegate withKey:kDelegateKey];
    [self bk_setDelegate:[BKAlertViewDelegate shared]];
}

#pragma mark Convenience
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonText handler:(BKBlock)block {
    UIAlertView *alert = [UIAlertView alertWithTitle:title message:message];
    if (!buttonText || !buttonText.length)
        buttonText = NSLocalizedString(@"Dismiss", nil);
    [alert addButtonWithTitle:buttonText];
    
    if (block)
        alert.didDismissHandler = ^(NSUInteger index){
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
    NSAssert(title.length, @"A button without a title cannot be added to the alert view.");
    NSInteger index = [self addButtonWithTitle:title];
    
    BKBlock handler = BK_AUTORELEASE([block copy]);
    [self.buttonHandlers setObject:handler forKey:[NSNumber numberWithInteger:index]];
    
    [self bk_setDelegate:[BKAlertViewDelegate shared]];
    
    return index;
}

- (NSInteger)setCancelButtonWithTitle:(NSString *)title handler:(BKBlock)block {    
    if (!title) title = NSLocalizedString(@"Cancel", nil);
    NSInteger index = [self addButtonWithTitle:title];
    self.cancelButtonIndex = index;
    
    BKBlock handler = BK_AUTORELEASE([block copy]);
    [self.buttonHandlers setObject:handler forKey:[NSNumber numberWithInteger:index]];
    
    [self bk_setDelegate:[BKAlertViewDelegate shared]];

    return index;
}

- (BKBlock)handlerForButtonAtIndex:(NSInteger)index {
    return BK_AUTORELEASE([[self.buttonHandlers objectForKey:[NSNumber numberWithInteger:index]] copy]);
}

#pragma mark Properties

- (NSMutableDictionary *)buttonHandlers {
    NSMutableDictionary *blocks = [self associatedValueForKey:kAlertViewButtonHandlersDictionaryKey];
    if (!blocks) {
        blocks = [NSMutableDictionary dictionary];
        [self associateValue:blocks withKey:kAlertViewButtonHandlersDictionaryKey];
    }
    return blocks;
}

- (void)setButtonHandlers:(NSMutableDictionary *)blocks {
    [self associateValue:blocks withKey:kAlertViewButtonHandlersDictionaryKey];
}

- (BKBlock)cancelHandler {
    NSNumber *key = [NSNumber numberWithInteger:self.cancelButtonIndex];
    return BK_AUTORELEASE([[self.buttonHandlers objectForKey:key] copy]);
}

- (void)setCancelHandler:(BKBlock)block {
    if (self.cancelButtonIndex == -1) {
        [self setCancelButtonWithTitle:nil handler:block];
    } 
    else {
        BKBlock handler = BK_AUTORELEASE([block copy]);
        NSNumber *key = [NSNumber numberWithInteger:self.cancelButtonIndex];
        
        [self.buttonHandlers setObject:handler forKey:key];
    }
    [self bk_setDelegate:[BKAlertViewDelegate shared]];
}

- (BKBlock)willShowHandler {
    return BK_AUTORELEASE([[self associatedValueForKey:kAlertViewWillShowHandlerKey] copy]);
}

- (void)setWillShowHandler:(BKBlock)block {
    [self associateCopyOfValue:block withKey:kAlertViewWillShowHandlerKey];
    [self bk_setDelegate:[BKAlertViewDelegate shared]];
}

- (BKBlock)didShowHandler {
    return BK_AUTORELEASE([[self associatedValueForKey:kAlertViewDidShowHandlerKey] copy]);
}

- (void)setDidShowHandler:(BKBlock)block {
    [self associateCopyOfValue:block withKey:kAlertViewDidShowHandlerKey];
    [self bk_setDelegate:[BKAlertViewDelegate shared]];
}

- (BKIndexBlock)willDismissHandler {
    return BK_AUTORELEASE([[self associatedValueForKey:kAlertViewWillDismissHandlerKey] copy]);
}

- (void)setWillDismissHandler:(BKIndexBlock)block {
    [self associateCopyOfValue:block withKey:kAlertViewWillDismissHandlerKey];
    [self bk_setDelegate:[BKAlertViewDelegate shared]];
}

- (BKIndexBlock)didDismissHandler {
    return BK_AUTORELEASE([[self associatedValueForKey:kAlertViewDidDismissHandlerKey] copy]);
}

- (void)setDidDismissHandler:(BKIndexBlock)block {
    [self associateCopyOfValue:block withKey:kAlertViewDidDismissHandlerKey];
    [self bk_setDelegate:[BKAlertViewDelegate shared]];
}

@end
