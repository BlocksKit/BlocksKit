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
- (void)_handleAction:(id)recognizer;
- (void)_handleActionUsingDelay:(id)recognizer;
@end

@implementation UIGestureRecognizer (BlocksKit)

+ (id)recognizerWithHandler:(BKGestureRecognizerBlock)block delay:(NSTimeInterval)delay {
	return [[[[self class] alloc] initWithHandler:block delay:delay] autorelease];
}

- (id)initWithHandler:(BKGestureRecognizerBlock)block delay:(NSTimeInterval)delay {
	self = [self init];
	[self setHandler:block];
	[self setDelay:delay];
	return self;
}

+ (id)recognizerWithHandler:(BKGestureRecognizerBlock)block {
	return [self recognizerWithHandler:block delay:0.0];
}

- (id)initWithHandler:(BKGestureRecognizerBlock)block {
	return [self initWithHandler:block delay:0.0];
}

- (void)_handleAction:(id)recognizer {
	BKGestureRecognizerBlock block = self.handler;
	if (!block)
		return;
	
	CGPoint location = [self locationInView:self.view];
	block(self, self.state, location);
}

- (void)_handleActionUsingDelay:(id)recognizer {
	BKGestureRecognizerBlock block = self.handler;
	if (!block)
		return;
	
	CGPoint location = [self locationInView:self.view];
	
	id cancel = [NSObject performBlock:^{
		block(self, self.state, location);
	} afterDelay:self.delay];
	[self associateCopyOfValue:cancel withKey:&kGestureRecognizerCancelKey];
}

- (void)setHandler:(BKGestureRecognizerBlock)handler {
	[self associateCopyOfValue:handler withKey:&kGestureRecognizerBlockKey];
}

- (BKGestureRecognizerBlock)handler {
	return [self associatedValueForKey:&kGestureRecognizerBlockKey];
}

- (void)setDelay:(NSTimeInterval)delay {
	[self removeTarget:self action:NULL];
	[self addTarget:self action:delay ? @selector(_handleActionUsingDelay:) : @selector(_handleAction:)];
	[self associateValue:[NSNumber numberWithDouble:delay] withKey:&kGestureRecognizerDelayKey];
}

- (NSTimeInterval)delay {
	NSNumber *delay = [self associatedValueForKey:&kGestureRecognizerDelayKey];
	return delay ? [delay doubleValue] : 0.0;
}

- (void)cancel {
	[NSObject cancelBlock:[self associatedValueForKey:&kGestureRecognizerCancelKey]];
}

@end
