//
//  UIImagePickerController+BlocksKit.h
//  BlocksKit
//
//  Contributed by Yas Kuraishi.
//

#import "BKDefines.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** UIImagePickerController with block callback.

 Created by [Yas Kuraishi](https://github.com/YasKuraishi) and contributed to
 BlocksKit.

 @warning UIImagePickerController is only available on a platform with
 UIKit.
*/
@interface UIImagePickerController (BlocksKit)

/**
 *	The block that fires after the receiver finished picking up an image
 */
@property (nonatomic, copy, nullable) void(^bk_didFinishPickingMediaBlock)(UIImagePickerController *, NSDictionary *);

/**
 *	The block that fires after the user cancels out of picker
 */
@property (nonatomic, copy, nullable) void(^bk_didCancelBlock)(UIImagePickerController *);

@end

NS_ASSUME_NONNULL_END
