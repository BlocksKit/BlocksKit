//
//  UIGestureRecognizer+BlocksKit.m
//  BlocksKit
//

#import "UIGestureRecognizer+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"
#import "NSObject+BlocksKit.h"

static char *kGestureRecognizerBlockKey = "BKGestureRecognizerBlock";
static char *kGestureRecognizerDelayKey = "BKGestureRecognizerDelay";
static char *kGestureRecognizerCancelRefKey = "BKGestureRecognizerCancellationBlock";

@interface UIGestureRecognizer (BlocksKitInternal)
- (void)_handleAction:(id)recognizer;
- (void)_handleActionUsingDelay:(id)recognizer;
@end

@implementation UIGestureRecognizer (BlocksKit)

+ (id)recognizerWithHandler:(BKSenderBlock)block delay:(NSTimeInterval)delay {
    return [[[[self class] alloc] initWithHandler:block delay:delay] autorelease];
}

- (id)initWithHandler:(BKSenderBlock)block delay:(NSTimeInterval)delay {
    self = [self init];
    [self setHandler:block];
    [self setDelay:delay];
    return self;
}

+ (id)recognizerWithHandler:(BKSenderBlock)block {
    return [self recognizerWithHandler:block delay:0.0];
}

- (id)initWithHandler:(BKSenderBlock)block {
    return [self initWithHandler:block delay:0.0];
}

- (void)_handleAction:(id)recognizer {
    BKSenderBlock block = self.handler;
    if (block)
        block(self);
}

- (void)_handleActionUsingDelay:(id)recognizer {
    BKSenderBlock block = self.handler;
    if (block) {
        id cancel = [NSObject performBlock:^{ block(self); } afterDelay:self.delay];
        [self weaklyAssociateValue:cancel withKey:kGestureRecognizerCancelRefKey];
    }
}

- (void)setHandler:(BKSenderBlock)handler {
    [self associateCopyOfValue:handler withKey:kGestureRecognizerBlockKey];
}

- (BKSenderBlock)handler {
    return [self associatedValueForKey:kGestureRecognizerBlockKey];
}

- (void)setDelay:(NSTimeInterval)delay {
    [self removeTarget:self action:NULL];
    if (delay)
        [self addTarget:self action:@selector(_handleActionUsingDelay:)];
    else
        [self addTarget:self action:@selector(_handleAction:)];
    [self associateValue:[NSNumber numberWithDouble:(delay) ? delay : 0.0] withKey:kGestureRecognizerDelayKey];
}

- (NSTimeInterval)delay {
    NSNumber *delay = [self associatedValueForKey:kGestureRecognizerDelayKey];
    if (delay)
        return [delay doubleValue];
    else
        return 0.0;
}

- (void)cancel {
    id cancel = [self associatedValueForKey:kGestureRecognizerCancelRefKey];
    if (cancel)
        [NSObject cancelBlock:cancel];
}

@end
