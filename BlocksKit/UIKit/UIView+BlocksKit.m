//
//  UIView+BlocksKit.m
//  BlocksKit
//

#import "UIGestureRecognizer+BlocksKit.h"
#import "UIView+BlocksKit.h"
#import "NSArray+BlocksKit.h"

@implementation UIView (BlocksKit)

- (void)bk_whenTouches:(NSUInteger)numberOfTouches tapped:(NSUInteger)numberOfTaps handler:(void (^)(void))block
{
	if (!block) return;
	
	UITapGestureRecognizer *gesture = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
		if (state == UIGestureRecognizerStateRecognized) block();
	}];
	
	gesture.numberOfTouchesRequired = numberOfTouches;
	gesture.numberOfTapsRequired = numberOfTaps;

	[self.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if (![obj isKindOfClass:[UITapGestureRecognizer class]]) return;

		UITapGestureRecognizer *tap = obj;
		BOOL rightTouches = (tap.numberOfTouchesRequired == numberOfTouches);
		BOOL rightTaps = (tap.numberOfTapsRequired == numberOfTaps);
		if (rightTouches && rightTaps) {
			[gesture requireGestureRecognizerToFail:tap];
		}
	}];

	[self addGestureRecognizer:gesture];
}

- (void)bk_whenTapped:(void (^)(void))block
{
	[self bk_whenTouches:1 tapped:1 handler:block];
}

- (void)bk_whenDoubleTapped:(void (^)(void))block
{
	[self bk_whenTouches:2 tapped:1 handler:block];
}

- (void)bk_eachSubview:(void (^)(UIView *subview))block
{
	NSParameterAssert(block != nil);

	[self.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
		block(subview);
	}];
}

- (void)bk_whenPanned:(void (^)(UIPanGestureRecognizer *))block; {
    if(block){
        UIPanGestureRecognizer *r = [UIPanGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            block(sender);
        }];
        [self addGestureRecognizer:r];

    }else{

        [self removeGestureRecognizersByClass:[UIPanGestureRecognizer class]];
    }
}

- (void)bk_whenSwiped:(void (^)(UISwipeGestureRecognizer *))block; {

    if(block){
        __weak UIView * blockSelf = self;
        [@[@(UISwipeGestureRecognizerDirectionRight),
                @(UISwipeGestureRecognizerDirectionLeft),
                @(UISwipeGestureRecognizerDirectionUp),
                @(UISwipeGestureRecognizerDirectionDown)] bk_each:^(id direction) {

            UISwipeGestureRecognizer * r = [UISwipeGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
                if(state == UIGestureRecognizerStateRecognized)
                    block(sender);
            }];
            r.direction = (UISwipeGestureRecognizerDirection) [direction integerValue];

            [blockSelf addGestureRecognizer:r];
        }];
    }else{
        [self removeGestureRecognizersByClass:[UISwipeGestureRecognizer class]];
    }
}

- (void)removeGestureRecognizersByClass:(Class) class {
    __weak UIView * blockSelf = self;
    [[self gestureRecognizers] bk_each:^(id obj) {
        if ([obj isKindOfClass: class]){
            [blockSelf removeGestureRecognizer:obj];
        }
    }];
}

@end
