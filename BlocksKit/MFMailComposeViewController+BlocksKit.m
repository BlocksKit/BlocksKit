//
//  MFMailComposeViewController+BlocksKit.m
//  BlocksKit
//

#import "MFMailComposeViewController+BlocksKit.h"
#import "NSObject+BlocksKit.h"
#import "BKDelegateProxy.h"

static char *kCompletionHandlerKey = "BKCompletionHandler";
static char *kBKMailComposeDelegateKey = "MFMailComposeViewControllerDelegate";

#pragma mark Delegate

@interface BKMailComposeViewControllerDelegate : BKDelegateProxy <MFMailComposeViewControllerDelegate>
@end

@implementation BKMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    id delegate = controller.mailComposeDelegate;
    if (delegate && [delegate respondsToSelector:@selector(mailComposeController:didFinishWithResult:error:)]) {
        [controller.mailComposeDelegate mailComposeController:controller didFinishWithResult:result error:error];
    }
    
    BKMailComposeViewControllerCompletionBlock block = controller.completionHandler;
    if (block)
        block(result, error);
}

@end

#pragma mark Category
@implementation MFMailComposeViewController (BlocksKit)

+ (void)load {
    [self swizzleSelector:@selector(mailComposeDelegate) withSelector:@selector(bk_mailComposeDelegate)];
    [self swizzleSelector:@selector(setMailComposeDelegate:) withSelector:@selector(bk_setMailComposeDelegate:)];
}

#pragma mark Methods

- (id)bk_mailComposeDelegate {
    return [self associatedValueForKey:kBKMailComposeDelegateKey];
}

- (void)bk_setMailComposeDelegate:(id)delegate {
    [self weaklyAssociateValue:delegate withKey:kBKMailComposeDelegateKey];
    
    [self bk_setMailComposeDelegate:[BKMailComposeViewControllerDelegate shared]];
}

#pragma mark Properties
 
- (BKMailComposeViewControllerCompletionBlock)completionHandler {
    return [self associatedValueForKey:kCompletionHandlerKey];
}

- (void)setCompletionHandler:(BKMailComposeViewControllerCompletionBlock)handler {
    // in case of using only blocks we still need to point our delegate
    // to proxy class
    [self bk_setMailComposeDelegate:[BKMailComposeViewControllerDelegate shared]];
    
    [self associateCopyOfValue:handler withKey:kCompletionHandlerKey];
}

@end
