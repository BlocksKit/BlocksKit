//
//  UIGestureRecognizer+BlocksKit.m
//  BlocksKit
//

#import <objc/runtime.h>
#import "UIGestureRecognizer+BlocksKit.h"
#import "A2DynamicDelegate.h"
#import "NSObject+A2BlockDelegate.h"
#import "NSObject+A2DynamicDelegate.h"

#pragma mark Delegate

@interface A2DynamicUIGestureRecognizerDelegate : A2DynamicDelegate <UIGestureRecognizerDelegate>

@end

@implementation A2DynamicUIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	BOOL should = YES;
	
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(gestureRecognizer:shouldBeRequiredToFailByGestureRecognizer:)])
		should &= [realDelegate gestureRecognizer:gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:otherGestureRecognizer];
	
	BOOL (^block)(UIGestureRecognizer*, UIGestureRecognizer*) = [self blockImplementationForMethod:_cmd];
	if (block)
		should &= block(gestureRecognizer, otherGestureRecognizer);
	
	return should;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	BOOL should = YES;
	
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(gestureRecognizer:shouldRequireFailureOfGestureRecognizer:)])
		should &= [realDelegate gestureRecognizer:gestureRecognizer shouldRequireFailureOfGestureRecognizer:otherGestureRecognizer];
	
	BOOL (^block)(UIGestureRecognizer*, UIGestureRecognizer*) = [self blockImplementationForMethod:_cmd];
	if (block)
		should &= block(gestureRecognizer, otherGestureRecognizer);
	
	return should;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	BOOL should = YES;
	
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)])
		should &= [realDelegate gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
	
	BOOL (^block)(UIGestureRecognizer*, UIGestureRecognizer*) = [self blockImplementationForMethod:_cmd];
	if (block)
		should &= block(gestureRecognizer, otherGestureRecognizer);
	
	return should;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	BOOL should = YES;
	
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(gestureRecognizer:shouldReceiveTouch:)])
		should &= [realDelegate gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
	
	BOOL (^block)(UIGestureRecognizer*, UITouch*) = [self blockImplementationForMethod:_cmd];
	if (block)
		should &= block(gestureRecognizer, touch);
	
	return should;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	BOOL should = YES;
	
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(gestureRecognizerShouldBegin:)])
		should &= [realDelegate gestureRecognizerShouldBegin:gestureRecognizer];
	
	BOOL (^block)(UIGestureRecognizer*) = [self blockImplementationForMethod:_cmd];
	if (block)
		should &= block(gestureRecognizer);
	
	return should;
}

@end

#pragma mark - Category

static const void *BKGestureRecognizerBlockKey = &BKGestureRecognizerBlockKey;
static const void *BKGestureRecognizerDelayKey = &BKGestureRecognizerDelayKey;
static const void *BKGestureRecognizerShouldHandleActionKey = &BKGestureRecognizerShouldHandleActionKey;

@interface UIGestureRecognizer (BlocksKitInternal)

@property (nonatomic, setter = bk_setShouldHandleAction:) BOOL bk_shouldHandleAction;

- (void)bk_handleAction:(UIGestureRecognizer *)recognizer;

@end

@implementation UIGestureRecognizer (BlocksKit)
@dynamic bk_shouldBeginBlock, bk_shouldReceiveTouchBlock, bk_shouldRecognizeSimultaneouslyBlock, bk_shouldBeRequiredToFailByGestureRecognizerBlock, bk_shouldRequireFailureOfGestureRecognizerBlock;

+ (void)load
{
	@autoreleasepool {
		[self bk_registerDynamicDelegate];
		[self bk_linkDelegateMethods:@{
		   @"bk_shouldBeginBlock": @"gestureRecognizerShouldBegin:",
		   @"bk_shouldReceiveTouchBlock": @"gestureRecognizer:shouldReceiveTouch:",
		   @"bk_shouldRecognizeSimultaneouslyBlock": @"gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:",
		   @"bk_shouldBeRequiredToFailByGestureRecognizerBlock": @"gestureRecognizer:shouldBeRequiredToFailByGestureRecognizer:",
		   @"bk_shouldRequireFailureOfGestureRecognizerBlock": @"gestureRecognizer:shouldRequireFailureOfGestureRecognizer:"
		}];
	}
}

+ (id)bk_recognizerWithHandler:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block delay:(NSTimeInterval)delay
{
	return [[[self class] alloc] bk_initWithHandler:block delay:delay];
}

- (id)bk_initWithHandler:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block delay:(NSTimeInterval)delay
{
	self = [self initWithTarget:self action:@selector(bk_handleAction:)];
	if (!self) return nil;

	self.bk_handler = block;
	self.bk_handlerDelay = delay;

	return self;
}

+ (id)bk_recognizerWithHandler:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block
{
	return [self bk_recognizerWithHandler:block delay:0.0];
}

- (id)bk_initWithHandler:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block
{
	return [self bk_initWithHandler:block delay:0.0];
}

- (void)bk_handleAction:(UIGestureRecognizer *)recognizer
{
	void (^handler)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) = recognizer.bk_handler;
	if (!handler) return;
	
	NSTimeInterval delay = self.bk_handlerDelay;
	CGPoint location = [self locationInView:self.view];
	void (^block)(void) = ^{
		if (!self.bk_shouldHandleAction) return;
		handler(self, self.state, location);
	};

	self.bk_shouldHandleAction = YES;

	if (!delay) {
		block();
		return;
	}

	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), block);
}

- (void)bk_setHandler:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))handler
{
	objc_setAssociatedObject(self, BKGestureRecognizerBlockKey, handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))bk_handler
{
	return objc_getAssociatedObject(self, BKGestureRecognizerBlockKey);
}

- (void)bk_setHandlerDelay:(NSTimeInterval)delay
{
	NSNumber *delayValue = delay ? @(delay) : nil;
	objc_setAssociatedObject(self, BKGestureRecognizerDelayKey, delayValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)bk_handlerDelay
{
	return [objc_getAssociatedObject(self, BKGestureRecognizerDelayKey) doubleValue];
}

- (void)bk_setShouldHandleAction:(BOOL)flag
{
	objc_setAssociatedObject(self, BKGestureRecognizerShouldHandleActionKey, @(flag), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)bk_shouldHandleAction
{
	return [objc_getAssociatedObject(self, BKGestureRecognizerShouldHandleActionKey) boolValue];
}

- (void)bk_cancel
{
	self.bk_shouldHandleAction = NO;
}

@end
