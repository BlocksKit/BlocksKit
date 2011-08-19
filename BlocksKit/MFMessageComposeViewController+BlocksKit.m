//
//  MFMessageComposeViewController+BlocksKit.m
//  BlocksKit
//

#import "MFMessageComposeViewController+BlocksKit.h"
#import "NSObject+BlocksKit.h"
#import "BKDelegateProxy.h"

static char *kCompletionHandlerKey = "BKCompletionHandler";
static char *kBKMessageComposeDelegateKey = "MFMailComposeViewControllerDelegate";

#pragma mark Delegate

@interface BKMessageComposeViewControllerDelegate : BKDelegateProxy <MFMessageComposeViewControllerDelegate>
@end

@implementation BKMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    id delegate = controller.messageComposeDelegate;
    if (delegate && [delegate respondsToSelector:@selector(messageComposeViewController:didFinishWithResult:)]) {
        [delegate messageComposeViewController:controller didFinishWithResult:result];
    }
    
    BKMessageComposeViewControllerCompletionBlock block = controller.completionHandler;
    if (block)
        block(result);
}

@end

#pragma mark Category
@implementation MFMessageComposeViewController (BlocksKit)

+ (void)load {
    [self swizzleSelector:@selector(messageComposeDelegate) withSelector:@selector(bk_messageComposeDelegate)];
    [self swizzleSelector:@selector(setMessageComposeDelegate:) withSelector:@selector(bk_setMessageComposeDelegate:)];
}

#pragma mark Methods

- (id)bk_messageComposeDelegate {
    return [self associatedValueForKey:kBKMessageComposeDelegateKey];
}

- (void)bk_setMessageComposeDelegate:(id)delegate {
    [self weaklyAssociateValue:delegate withKey:kBKMessageComposeDelegateKey];
    
    [self bk_setMessageComposeDelegate:[BKMessageComposeViewControllerDelegate shared]];
}

#pragma mark Properties

- (BKMessageComposeViewControllerCompletionBlock)completionHandler {
    return [self associatedValueForKey:kCompletionHandlerKey];
}

- (void)setCompletionHandler:(BKMessageComposeViewControllerCompletionBlock)handler {
    // in case of using only blocks we still need to point our delegate
    // to proxy class
    [self bk_setMessageComposeDelegate:[BKMessageComposeViewControllerDelegate shared]];
    
    [self associateCopyOfValue:handler withKey:kCompletionHandlerKey];
}

@end

