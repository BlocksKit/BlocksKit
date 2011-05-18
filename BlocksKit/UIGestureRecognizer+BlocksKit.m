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

+ (id)recognizerWithHandler:(void (^)(id recognizer))block {
    return [[[[self class] alloc] initWithHandler:block] autorelease];
}

- (id)initWithHandler:(void (^)(id recognizer))block {
    if ((self = [self initWithTarget:self action:@selector(_handleAction:)])) {
        [self associateCopyOfValue:block withKey:&kGestureRecognizerBlockKey];
    }
    return self;
}
                 
- (void)_handleAction:(id)recognizer {
    void (^handler)(id recognizer) = [self associatedValueForKey:&kGestureRecognizerBlockKey];
    if (handler)
        handler(recognizer);
}

@end
