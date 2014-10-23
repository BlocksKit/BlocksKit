//
//  UIImage+Blockskit.h
//  BlocksKit
//

#import <UIKit/UIKit.h>

/** UIImage without selector.

 Includes code by the following:

 - [Yusuke Murata](https://github.com/muratayusuke)

 @warning UIImage is only available on a platform with UIKit.
 */
@interface UIImage (BlocksKit)

/** UIImageWriteToSavedPhotosAlbum with block.

 @param block A block called after UIImageWriteToSavedPhotosAlbum() complete.
 */
- (void)bk_writeToSavedPhotosAlbumWithBlock:(void (^)(NSError *error, void *contextInfo))block contextInfo:(void *)contextInfo;

@end
