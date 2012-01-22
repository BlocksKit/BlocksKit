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
	if ((self = [self initWithTarget:self action:@selector(_handleAction:)])) {
		if (delay)
			[self associateValue:[NSNumber numberWithDouble:delay] withKey:&kGestureRecognizerDelayKey];
		self.handler = block;
	}
	return self;
}

+ (id)recognizerWithHandler:(BKGestureRecognizerBlock)block {
	return [self recognizerWithHandler:block delay:0.0];
}

- (id)initWithHandler:(BKGestureRecognizerBlock)block {
	return [self initWithHandler:block delay:0.0];
}

- (void)_handleAction:(UIGestureRecognizer *)recognizer {
	BKGestureRecognizerBlock handler = recognizer.handler;
	if (!handler)
		return;
	
	NSTimeInterval delay = self.delay;
	CGPoint location = [self locationInView:self.view];
	BKBlock block = ^{
		handler(self, self.state, location);
	};
	
	if (!delay) {
		block();
	}
    else {
        id cancel = [NSObject performBlock:block afterDelay:delay];
        [self associateCopyOfValue:cancel withKey:&kGestureRecognizerCancelKey];
    }
}

- (void)setHandler:(BKGestureRecognizerBlock)handler {
	[self associateCopyOfValue:handler withKey:&kGestureRecognizerBlockKey];
}

- (BKGestureRecognizerBlock)handler {
	return [self associatedValueForKey:&kGestureRecognizerBlockKey];
}

- (void)setDelay:(NSTimeInterval)delay {
	NSNumber *delayValue = delay ? [NSNumber numberWithDouble:delay] : nil;
	[self associateValue:delayValue withKey:&kGestureRecognizerDelayKey];
}

- (NSTimeInterval)delay {
	NSNumber *delay = [self associatedValueForKey:&kGestureRecognizerDelayKey];
	return delay ? [delay doubleValue] : 0.0;
}

- (void)cancel {
	[NSObject cancelBlock:[self associatedValueForKey:&kGestureRecognizerCancelKey]];
}

@end
