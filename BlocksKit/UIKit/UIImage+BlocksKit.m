//
//  UIImage+Blockskit.m
//  BlocksKit
//

#import "UIImage+BlocksKit.h"

@implementation UIImage (BKPhotoLibraryExport)

+ (void)bk_image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    void(^block)(NSError *) = (__bridge_transfer id)contextInfo;
    if (!block) { return; }
    block(error);
}

+ (void)bk_videoAtPath:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    void(^block)(NSError *) = (__bridge_transfer id)contextInfo;
    if (!block) { return; }
    block(error);
}

@end

void BKImageWriteToSavedPhotosAlbum(UIImage *image, void(^completionBlock)(NSError *))
{
    void *blockAsContext = (__bridge_retained void *)[completionBlock copy];
    UIImageWriteToSavedPhotosAlbum(image, UIImage.class, @selector(bk_image:didFinishSavingWithError:contextInfo:), blockAsContext);
}

void BKSaveVideoAtURLToSavedPhotosAlbum(NSURL *videoURL, void(^completionBlock)(NSError *))
{
    void *blockAsContext = (__bridge_retained void *)[completionBlock copy];
    UISaveVideoAtPathToSavedPhotosAlbum(videoURL.path, UIImage.class, @selector(bk_videoAtPath:didFinishSavingWithError:contextInfo:), blockAsContext);
}
