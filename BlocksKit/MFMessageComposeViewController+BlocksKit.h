//
//  MFMessageComposeViewController+BlocksKit.h
//  %PROJECT
//

typedef void (^BKMessageComposeBlock) (MessageComposeResult result);

/** MFMessageComposeViewController with block callback in addition to delegation

 Created by Igor Evsukov and contributed to BlocksKit.

 @warning UIWebView is only available on iOS or in a Mac app using Chameleon.
*/
@interface MFMessageComposeViewController (BlocksKit)

/** The block fired on the dismissal of the SMS composition interface.

 This block callback is an analog for the
 messageComposeViewController:didFinishWithResult method
 of MFMessageComposeViewControllerDelegate.
*/
@property (copy) BKMessageComposeBlock completionHandler;

@end
