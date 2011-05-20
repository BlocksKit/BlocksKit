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
    BKSenderBlock block = [self associatedValueForKey:&kGestureRecognizerBlockKey];
    if (block) dispatch_async(dispatch_get_main_queue(), ^{ block(block); });
}

@end
