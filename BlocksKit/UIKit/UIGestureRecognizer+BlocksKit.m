//
//  UIGestureRecognizer+BlocksKit.m
//  BlocksKit
//

#import "UIGestureRecognizer+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"
#import "NSObject+BlocksKit.h"

static char kGestureRecognizerBlockKey;
static char kGestureRecognizerDelayKey;
static char kGestureRecognizerCancelKey;

@interface UIGestureRecognizer (BlocksKitInternal)

- (void)bk_handleAction:(UIGestureRecognizer *)recognizer;

@end

@implementation UIGestureRecognizer (BlocksKit)

+ (id)bk_recognizerWithHandler:(BKGestureRecognizerBlock)block delay:(NSTimeInterval)delay
{
	return [[[self class] alloc] bk_initWithHandler:block delay:delay];
}

- (id)bk_initWithHandler:(BKGestureRecognizerBlock)block delay:(NSTimeInterval)delay
{
	self = [self initWithTarget:self action:@selector(bk_handleAction:)];
	if (!self) return nil;

	self.bk_handler = block;
	self.bk_handlerDelay = delay;

	return self;
}

+ (id)bk_recognizerWithHandler:(BKGestureRecognizerBlock)block
{
	return [self bk_recognizerWithHandler:block delay:0.0];
}

- (id)bk_initWithHandler:(BKGestureRecognizerBlock)block
{
	return [self bk_initWithHandler:block delay:0.0];
}

- (void)bk_handleAction:(UIGestureRecognizer *)recognizer
{
	BKGestureRecognizerBlock handler = recognizer.bk_handler;
	if (!handler) return;
	
	NSTimeInterval delay = self.bk_handlerDelay;
	CGPoint location = [self locationInView:self.view];
	BKBlock block = ^{
		handler(self, self.state, location);
	};
	
	if (!delay) {
		block();
		return;
	}
	
	id cancel = [NSObject bk_performBlock:block afterDelay:delay];
	[self bk_associateCopyOfValue:cancel withKey:&kGestureRecognizerCancelKey];
}

- (void)bk_setHandler:(BKGestureRecognizerBlock)handler
{
	[self bk_associateCopyOfValue:handler withKey:&kGestureRecognizerBlockKey];
}

- (BKGestureRecognizerBlock)bk_handler
{
	return [self bk_associatedValueForKey:&kGestureRecognizerBlockKey];
}

- (void)bk_setHandlerDelay:(NSTimeInterval)delay
{
	NSNumber *delayValue = delay ? @(delay) : nil;
	[self bk_associateValue:delayValue withKey:&kGestureRecognizerDelayKey];
}

- (NSTimeInterval)bk_handlerDelay
{
	return [[self bk_associatedValueForKey:&kGestureRecognizerDelayKey] doubleValue];
}

- (void)bk_cancel
{
	[NSObject bk_cancelBlock:[self bk_associatedValueForKey:&kGestureRecognizerCancelKey]];
}

@end
