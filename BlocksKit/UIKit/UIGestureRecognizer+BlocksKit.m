//
//  UIGestureRecognizer+BlocksKit.m
//  BlocksKit
//

#import <objc/runtime.h>
#import "UIGestureRecognizer+BlocksKit.h"

static const void *BKGestureRecognizerBlockKey = &BKGestureRecognizerBlockKey;
static const void *BKGestureRecognizerDelayKey = &BKGestureRecognizerDelayKey;
static const void *BKGestureRecognizerShouldHandleActionKey = &BKGestureRecognizerShouldHandleActionKey;

@interface UIGestureRecognizer (BlocksKitInternal)

@property (nonatomic, setter = bk_setShouldHandleAction:) BOOL bk_shouldHandleAction;

- (void)bk_handleAction:(UIGestureRecognizer *)recognizer;

@end

@implementation UIGestureRecognizer (BlocksKit)

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
	return (self = [self bk_initWithHandler:block delay:0.0]);
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
