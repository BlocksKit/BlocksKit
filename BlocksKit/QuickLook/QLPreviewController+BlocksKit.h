//
//  QLPreviewController+BlocksKit.h
//  BlocksKit
//

#import "BKDefines.h"
#import <QuickLook/QuickLook.h>

NS_ASSUME_NONNULL_BEGIN

@interface QLPreviewController (BlocksKit)

@property (nonatomic, copy, setter = bk_setFrameForPreviewItemInSourceView:, nullable) CGRect (^bk_frameForPreviewItem)(QLPreviewController *controller, id<QLPreviewItem>item, UIView *_Nullable *_Nonnull);

@property (nonatomic, copy, setter = bk_setTransitionImageForPreviewItem:, nullable) UIImage *(^bk_transitionImageForPreviewItem)(QLPreviewController *controller, id<QLPreviewItem> item, CGRect *contentRect);

@property (nonatomic, copy, setter = bk_setShouldOpenURLForPreviewItem:, nullable) BOOL (^bk_shouldOpenURLForPreviewItem)(QLPreviewController *controller, NSURL *url, id<QLPreviewItem> item);

/** The block to be fired before the Quick Look controller will dismiss. */
@property (nonatomic, copy, setter = bk_setWillDismissBlock:, nullable) void (^bk_willDismissBlock)(QLPreviewController *controller);

/** The block to be fired after the Quick Look controller did dismiss. */
@property (nonatomic, copy, setter = bk_setDidDismissBlock:, nullable) void (^bk_didDismissBlock)(QLPreviewController *controller);

@end

NS_ASSUME_NONNULL_END
