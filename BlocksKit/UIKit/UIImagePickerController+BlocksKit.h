//
//  UIImagePickerController+BlocksKit.h
//  BlocksKit
//
//  Contributed by Yas Kuraishi.
//

#import <UIKit/UIKit.h>

#if __has_feature(nullability) // Xcode 6.3+
#pragma clang assume_nonnull begin
#else
#define nullable
#define __nullable
#endif

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
@property (nonatomic, copy) void(^bk_didFinishPickingMediaBlock)(UIImagePickerController *, NSDictionary *);

/**
 *	The block that fires after the user cancels out of picker
 */
@property (nonatomic, copy, nullable) void(^bk_didCancelBlock)(UIImagePickerController *);

@end

#if __has_feature(nullability)
#pragma clang assume_nonnull end
#endif