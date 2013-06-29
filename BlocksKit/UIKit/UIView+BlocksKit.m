//
//  UIView+BlocksKit.m
//  BlocksKit
//

#import "UIView+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"
#import "UIGestureRecognizer+BlocksKit.h"
#import "NSArray+BlocksKit.h"

static char kViewTouchDownBlockKey;
static char kViewTouchMoveBlockKey;
static char kViewTouchUpBlockKey;

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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];

	void (^block)(NSSet *set, UIEvent *event) = [self bk_associatedValueForKey:&kViewTouchDownBlockKey];
	if (block) block(touches, event);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];

	void (^block)(NSSet *set, UIEvent *event) = [self bk_associatedValueForKey:&kViewTouchMoveBlockKey];
	if (block) block(touches, event);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];

	void (^block)(NSSet *set, UIEvent *event) = [self bk_associatedValueForKey:&kViewTouchUpBlockKey];
	if (block) block(touches, event);
}

- (void)bk_eachSubview:(void(^)(UIView *subview))block
{
	[self.subviews bk_each:block];
}

#pragma mark Properties

- (void)bk_setOnTouchDownBlock:(void (^)(NSSet *set, UIEvent *event))block
{
	[self bk_associateCopyOfValue:block withKey:&kViewTouchDownBlockKey];
}

- (void (^)(NSSet *set, UIEvent *event))bk_onTouchDownBlock
{
	return [self bk_associatedValueForKey:&kViewTouchDownBlockKey];
}

- (void)bk_setOnTouchMoveBlock:(void (^)(NSSet *set, UIEvent *event))block
{
	[self bk_associateCopyOfValue:block withKey:&kViewTouchMoveBlockKey];
}

- (void (^)(NSSet *set, UIEvent *event))bk_onTouchMoveBlock
{
	return [self bk_associatedValueForKey:&kViewTouchMoveBlockKey];
}

- (void)bk_setOnTouchUpBlock:(void (^)(NSSet *set, UIEvent *event))block
{
	[self bk_associateCopyOfValue:block withKey:&kViewTouchUpBlockKey];
}

- (void (^)(NSSet *set, UIEvent *event))bk_onTouchUpBlock
{
	return [self bk_associatedValueForKey:&kViewTouchUpBlockKey];
}

@end
