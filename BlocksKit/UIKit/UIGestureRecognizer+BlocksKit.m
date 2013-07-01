//
//  UIGestureRecognizer+BlocksKit.m
//  BlocksKit
//

#import "NSObject+BKAssociatedObjects.h"
#import "NSObject+BKBlockExecution.h"
#import "UIGestureRecognizer+BlocksKit.h"

static const void *BKGestureRecognizerBlockKey = &BKGestureRecognizerBlockKey;
static const void *BKGestureRecognizerDelayKey = &BKGestureRecognizerDelayKey;
static const void *BKGestureRecognizerCancelKey = &BKGestureRecognizerCancelKey;

@interface UIGestureRecognizer (BlocksKitInternal)

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
	return [self bk_initWithHandler:block delay:0.0];
}

- (void)bk_handleAction:(UIGestureRecognizer *)recognizer
{
	void (^handler)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) = recognizer.bk_handler;
	if (!handler) return;
	
	NSTimeInterval delay = self.bk_handlerDelay;
	CGPoint location = [self locationInView:self.view];
	void (^block)(void) = ^{
		handler(self, self.state, location);
	};
	
	if (!delay) {
		block();
		return;
	}
	
	id cancel = [NSObject bk_performBlock:block afterDelay:delay];
	[self bk_associateCopyOfValue:cancel withKey:BKGestureRecognizerCancelKey];
}

- (void)bk_setHandler:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))handler
{
	[self bk_associateCopyOfValue:handler withKey:BKGestureRecognizerBlockKey];
}

- (void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))bk_handler
{
	return [self bk_associatedValueForKey:BKGestureRecognizerBlockKey];
}

- (void)bk_setHandlerDelay:(NSTimeInterval)delay
{
	NSNumber *delayValue = delay ? @(delay) : nil;
	[self bk_associateValue:delayValue withKey:BKGestureRecognizerDelayKey];
}

- (NSTimeInterval)bk_handlerDelay
{
	return [[self bk_associatedValueForKey:BKGestureRecognizerDelayKey] doubleValue];
}

- (void)bk_cancel
{
	[NSObject bk_cancelBlock:[self bk_associatedValueForKey:BKGestureRecognizerCancelKey]];
}

@end
