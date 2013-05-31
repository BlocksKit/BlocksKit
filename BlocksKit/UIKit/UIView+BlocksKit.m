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

- (void)whenTouches:(NSUInteger)numberOfTouches tapped:(NSUInteger)numberOfTaps handler:(BKBlock)block {
	if (!block)
		return;
	
	UITapGestureRecognizer *gesture = [UITapGestureRecognizer recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
		if (state == UIGestureRecognizerStateRecognized) block();
	}];
	
	[gesture setNumberOfTouchesRequired:numberOfTouches];
	[gesture setNumberOfTapsRequired:numberOfTaps];
	
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
	
	[self addGestureRecognizer:gesture];
}

- (void)whenTapped:(BKBlock)block {
	[self whenTouches:1 tapped:1 handler:block];
}

- (void)whenDoubleTapped:(BKBlock)block {
	[self whenTouches:2 tapped:1 handler:block];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	BKTouchBlock block = [self associatedValueForKey:&kViewTouchDownBlockKey];
	if (block)
		block(touches, event);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesMoved:touches withEvent:event];
	BKTouchBlock block = [self associatedValueForKey:&kViewTouchMoveBlockKey];
	if (block)
		block(touches, event);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	BKTouchBlock block = [self associatedValueForKey:&kViewTouchUpBlockKey];
	if (block)
		block(touches, event);
}

- (void)eachSubview:(void(^)(UIView *))block {
	[self.subviews each:(BKSenderBlock)block];
}

#pragma mark Properties

- (void)setOnTouchDownBlock:(BKTouchBlock)block {
	[self associateCopyOfValue:block withKey:&kViewTouchDownBlockKey];
}

- (BKTouchBlock)onTouchDownBlock {
	return [self associatedValueForKey:&kViewTouchDownBlockKey];
}

- (void)setOnTouchMoveBlock:(BKTouchBlock)block {
	[self associateCopyOfValue:block withKey:&kViewTouchMoveBlockKey];
}

- (BKTouchBlock)onTouchMoveBlock {
	return [self associatedValueForKey:&kViewTouchMoveBlockKey];
}

- (void)setOnTouchUpBlock:(BKTouchBlock)block {
	[self associateCopyOfValue:block withKey:&kViewTouchUpBlockKey];
}

- (BKTouchBlock)onTouchUpBlock {
	return [self associatedValueForKey:&kViewTouchUpBlockKey];
}

@end
