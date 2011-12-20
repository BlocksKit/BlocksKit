//
//  MFMailComposeViewController+BlocksKit.h
//  %PROJECT
//

#import "BKGlobals.h"

/** MFMailComposeViewController with block callbacks.

 If you provide a completion handler to an instance of
 MFMailComposeViewController but do not implement a delegate
 callback for mailComposeController:didFinishWithResult:error:,
 the mail compose view controller will automatically be
 dismissed if it was launched modally.

 Created by Igor Evsukov and contributed to BlocksKit.

 @warning UIWebView is only available on iOS or in a Mac app using Chameleon.
 */
@interface MFMailComposeViewController (BlocksKit)

/**  The block fired on the dismissal of the mail composition interface.

 This block callback is an analog for the
 mailComposeController:didFinishWithResult:error: method
 of MFMailComposeViewControllerDelegate.
*/
@property (nonatomic, copy) void(^completionBlock)(MFMailComposeViewController *, MFMailComposeResult, NSError *);

@end