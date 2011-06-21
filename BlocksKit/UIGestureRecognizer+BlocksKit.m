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

+ (id)recognizerWithHandler:(BKGestureRecognizerBlock)block delay:(NSTimeInterval)delay {
    return BK_AUTORELEASE([[[self class] alloc] initWithHandler:block delay:delay]);
}

- (id)initWithHandler:(BKGestureRecognizerBlock)block delay:(NSTimeInterval)delay {
    self = [self init];
    [self setHandler:block];
    [self setDelay:delay];
    return self;
}

+ (id)recognizerWithHandler:(BKGestureRecognizerBlock)block {
    return [self recognizerWithHandler:block delay:0.0];
}

- (id)initWithHandler:(BKGestureRecognizerBlock)block {
    return [self initWithHandler:block delay:0.0];
}

- (void)_handleAction:(id)recognizer {
    BKGestureRecognizerBlock block = self.handler;
    if (block) {
        UIGestureRecognizerState state = self.state;
        CGPoint location = [self locationInView:self.view];
        block(self, state, location);
    }
}

- (void)_handleActionUsingDelay:(id)recognizer {
    BKGestureRecognizerBlock block = self.handler;
    if (block) {
        UIGestureRecognizerState state = self.state;
        CGPoint location = [self locationInView:self.view];
        
        id cancel = [NSObject performBlock:^{
            block(self, state, location);
        } afterDelay:self.delay];
        [self associateCopyOfValue:cancel withKey:kGestureRecognizerCancelRefKey];
    }
}

- (void)setHandler:(BKGestureRecognizerBlock)handler {
    [self associateCopyOfValue:handler withKey:kGestureRecognizerBlockKey];
}

- (BKGestureRecognizerBlock)handler {
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
