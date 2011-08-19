//
//  MFMailComposeViewController+BlocksKit.h
//  %PROJECT
//

typedef void (^BKMailComposeViewControllerCompletionBlock) (MFMailComposeResult result, NSError *error);

/** MFMailComposeViewController with block callback in addition to delegation
  
 Created by Igor Evsukov and contributed to BlocksKit.
 */
@interface MFMailComposeViewController (BlocksKit)

/** Block callback analog for MFMailComposeViewControllerDelegate 
 mailComposeController:didFinishWithResult:error: method */
@property (nonatomic, copy) BKMailComposeViewControllerCompletionBlock completionHandler;

@end

