//
//  MFMessageComposeViewController+BlocksKit.h
//  %PROJECT
//

typedef void (^BKMessageComposeBlock) (MessageComposeResult result);

/** MFMessageComposeViewController with block callback in addition to delegation.
 
 If you provide a completion handler to an instance of
 MFMessageComposeViewController but do not implement a delegate
 callback for messageComposeViewController:didFinishWithResult:error:,
 the message compose view controller will automatically be
 dismissed if it was launched modally.

 Created by Igor Evsukov and contributed to BlocksKit.

 @warning UIWebView is only available on iOS or in a Mac app using Chameleon.
*/
@interface MFMessageComposeViewController (BlocksKit)

/** The block fired on the dismissal of the SMS composition interface.
 Deprecated in favor of completionBlock. */
@property (copy) BKMessageComposeBlock completionHandler DEPRECATED_ATTRIBUTE;

/** The block fired on the dismissal of the SMS composition interface.
 
 This block callback is an analog for the
 messageComposeViewController:didFinishWithResult method
 of MFMessageComposeViewControllerDelegate.
 */
@property (copy) BKMessageComposeBlock completionBlock;

@end
