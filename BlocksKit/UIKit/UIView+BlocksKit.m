//
//  UIView+BlocksKit.m
//  BlocksKit
//

#import "UIView+BlocksKit.h"
#import "NSObject+BKAssociatedObjects.h"
#import "UIGestureRecognizer+BlocksKit.h"
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
	
	[[self.gestureRecognizers bk_select:^BOOL(id obj) {
		if ([obj isKindOfClass:[UITapGestureRecognizer class]]) {
			BOOL rightTouches = ([(UITapGestureRecognizer *)obj numberOfTouchesRequired] == numberOfTouches);
			BOOL rightTaps = ([(UITapGestureRecognizer *)obj numberOfTapsRequired] == numberOfTaps);
			return (rightTouches && rightTaps);
		}
		return NO;
	}] bk_each:^(id obj) {
		[gesture requireGestureRecognizerToFail:(UITapGestureRecognizer *)obj];
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
	[self.subviews bk_each:block];
}

@end
