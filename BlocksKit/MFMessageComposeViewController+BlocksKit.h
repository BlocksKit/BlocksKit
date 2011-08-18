//
//  MFMessageComposeViewController+BlocksKit.h
//  %PROJECT
//

typedef void (^BKMessageComposeViewControllerCompletionBlock) (MessageComposeResult result);

/** MFMessageComposeViewController with block callback in addition to delegation
 
 Created by Igor Evsukov and contributed to BlocksKit.
 */
@interface MFMessageComposeViewController (BlocksKit)

/** Block callback analog for MFMessageComposeViewControllerDelegate 
 messageComposeViewController:didFinishWithResult method */
@property (nonatomic, copy) BKMessageComposeViewControllerCompletionBlock completionHandler;

@end
