//
//  UIGestureRecognizer+BlocksKit.m
//  BlocksKit
//

#import "UIGestureRecognizer+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"

static char kGestureRecognizerBlockKey;

@interface UIGestureRecognizer (BlocksKitInternal)
- (void)_handleAction:(id)recognizer;
@end

@implementation UIGestureRecognizer (BlocksKit)

+ (id)recognizerWithHandler:(BKSenderBlock)block {
    return [[[[self class] alloc] initWithHandler:block] autorelease];
}

- (id)initWithHandler:(BKSenderBlock)block {
    if ((self = [self initWithTarget:self action:@selector(_handleAction:)])) {
        [self associateCopyOfValue:block withKey:&kGestureRecognizerBlockKey];
    }
    return self;
}
                 
- (void)_handleAction:(id)recognizer {
    __block BKSenderBlock handler = [self associatedValueForKey:&kGestureRecognizerBlockKey];
    if (handler)
        dispatch_async(dispatch_get_main_queue(), ^{ handler(recognizer); });
}

@end
