//
//  UIView+BlocksKit.m
//  BlocksKit
//
//  Created by Zachary Waldowski on 5/17/11.
//  Copyright 2011 Dizzy Technology. All rights reserved.
//

#import "UIView+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"
#import "UIGestureRecognizer+BlocksKit.h"
#import "NSArray+BlocksKit.h"

static char *kViewTouchDownBlockKey = "UIViewTouchDownBlock";
static char *kViewTouchMoveBlockKey = "UIViewTouchMoveBlock";
static char *kViewTouchUpBlockKey = "UIViewTouchDownBlock";

@implementation UIView (BlocksKit)

- (void)whenTouches:(NSUInteger)numberOfTouches tapped:(NSUInteger)numberOfTaps handler:(BKBlock)block {
    self.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithHandler:^(id recognizer) {
        block();
    }];
    
    [[self.gestureRecognizers select:^BOOL(id obj) {
        if ([obj isKindOfClass:[UITapGestureRecognizer class]]) {
            BOOL rightTouches = ([(UITapGestureRecognizer *)obj numberOfTouchesRequired] == numberOfTouches);
            BOOL rightTaps = ([(UITapGestureRecognizer *)obj numberOfTapsRequired] == numberOfTaps);
            return (rightTouches && rightTaps);
        }
        return NO;
    }] each:^(id obj) {
        [gesture requireGestureRecognizerToFail:(UITapGestureRecognizer *)obj];
    }];
    
    [gesture setNumberOfTouchesRequired:numberOfTouches];
    [gesture setNumberOfTapsRequired:numberOfTaps];
    
    [self addGestureRecognizer:gesture];
    [gesture release];    
}

- (void)whenTapped:(BKBlock)block {
    [self whenTouches:1 tapped:1 handler:block];
}

- (void)whenDoubleTapped:(BKBlock)block {
    [self whenTouches:2 tapped:1 handler:block];
}

- (void)whenTouchedDown:(BKTouchBlock)block {
    self.userInteractionEnabled = YES;
    [self associateCopyOfValue:block withKey:kViewTouchDownBlockKey];
}

- (void)whenTouchMove:(BKTouchBlock)block {
	self.userInteractionEnabled = YES;
    [self associateCopyOfValue:block withKey:kViewTouchMoveBlockKey];
}	

- (void)whenTouchedUp:(BKTouchBlock)block {
    self.userInteractionEnabled = YES;
    [self associateCopyOfValue:block withKey:kViewTouchUpBlockKey];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    BKTouchBlock block = [self associatedValueForKey:kViewTouchDownBlockKey];
    if (block) dispatch_async(dispatch_get_main_queue(), ^{ block(touches, event); });
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    BKTouchBlock block = [self associatedValueForKey:kViewTouchMoveBlockKey];
    if (block) dispatch_async(dispatch_get_main_queue(), ^{ block(touches, event); });
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    BKTouchBlock block = [self associatedValueForKey:kViewTouchUpBlockKey];
    if (block) dispatch_async(dispatch_get_main_queue(), ^{ block(touches, event); });
}

@end
