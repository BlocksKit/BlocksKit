//
//  MFMailComposeViewController+BlocksKit.h
//  %PROJECT
//

typedef void (^BKMailComposeBlock) (MFMailComposeResult result, NSError *error);

/** MFMailComposeViewController with block callbacks.

 Created by Igor Evsukov and contributed to BlocksKit.

 @warning UIWebView is only available on iOS or in a Mac app using Chameleon.
 */
@interface MFMailComposeViewController (BlocksKit)

/** The block fired on the dismissal of the mail composition interface.
 
 This block callback is an analog for the
 mailComposeController:didFinishWithResult:error: method
 of MFMailComposeViewControllerDelegate.
*/
@property (copy) BKMailComposeBlock completionHandler;

@end