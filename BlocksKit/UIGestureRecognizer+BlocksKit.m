//
//  UIGestureRecognizer+BlocksKit.m
//  BlocksKit
//

#import "UIGestureRecognizer+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"

static char *kGestureRecognizerBlockKey = "BKGestureRecognizerBlock";

@interface UIGestureRecognizer (BlocksKitInternal)
- (void)_handleAction:(id)recognizer;
@end

@implementation UIGestureRecognizer (BlocksKit)

+ (id)recognizerWithHandler:(BKSenderBlock)block {
    return [[[[self class] alloc] initWithHandler:block] autorelease];
}

- (id)initWithHandler:(BKSenderBlock)block {
    self = [self initWithTarget:self action:@selector(_handleAction:)];
    [self setHandler:block];
    return self;
}
                 
- (void)_handleAction:(id)recognizer {
    BKSenderBlock block = self.handler;
    if (block)
        block(self);
}

- (void)setHandler:(BKSenderBlock)handler {
    [self associateCopyOfValue:handler withKey:kGestureRecognizerBlockKey];
}

- (BKSenderBlock)handler {
    return [self associatedValueForKey:kGestureRecognizerBlockKey];
}

@end
