//
//  UIImage+Blockskit.m
//  Best10
//

#import "UIImage+BlocksKit.h"

@interface BKImageWrapper : NSObject

- (instancetype)initWithBlock:(void (^)(NSError *, void *))block;

@property(nonatomic, strong) void (^block)(NSError *, void *);

@end

@implementation BKImageWrapper

- (instancetype)initWithBlock:(void (^)(NSError *, void *))block {
	self = [super init];
	if (self) {
		self.block = block;
	}
	return self;
}

- (void)onCompleteCapture:(UIImage *)screenImage
 didFinishSavingWithError:(NSError *)error
			  contextInfo:(void *)contextInfo {
	if (self.block) {
		self.block(error, contextInfo);
	}
}

@end

@implementation UIImage (BlocksKit)

- (void)bk_writeToSavedPhotosAlbumWithBlock:(void (^)(NSError *, void *))block contextInfo:(void *)contextInfo {
	BKImageWrapper *target = [[BKImageWrapper alloc] initWithBlock:block];
	SEL selector = @selector(onCompleteCapture:didFinishSavingWithError:contextInfo:);
	UIImageWriteToSavedPhotosAlbum(self, target, selector, contextInfo);
}

@end
