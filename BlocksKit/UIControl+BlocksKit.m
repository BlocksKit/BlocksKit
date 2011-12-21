//
//  UIControl+BlocksKit.m
//  BlocksKit
//

#import "UIControl+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"
#import "NSSet+BlocksKit.h"

static char kControlHandlersKey;

#pragma mark Private

@interface BKControlWrapper : NSObject <NSCopying>

- (id)initWithHandler:(BKSenderBlock)aHandler forControlEvents:(UIControlEvents)someControlEvents;
@property (nonatomic, copy) BKSenderBlock handler;
@property (nonatomic) UIControlEvents controlEvents;

@end

@implementation BKControlWrapper

@synthesize handler, controlEvents;

- (id)initWithHandler:(BKSenderBlock)aHandler forControlEvents:(UIControlEvents)someControlEvents {
	if ((self = [super init])) {
		self.handler = aHandler;
		self.controlEvents = someControlEvents;
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	return [[BKControlWrapper alloc] initWithHandler:self.handler forControlEvents:self.controlEvents];
}

- (void)invoke:(id)sender {
	self.handler(sender);
}

- (void)dealloc {
	self.handler = nil;
	[super dealloc];
}

@end

#pragma mark Category

@implementation UIControl (BlocksKit)

- (void)addEventHandler:(BKSenderBlock)handler forControlEvents:(UIControlEvents)controlEvents {
	NSParameterAssert(handler);
	
	NSMutableDictionary *events = [self associatedValueForKey:&kControlHandlersKey];
	if (!events) {
		events = [NSMutableDictionary dictionary];
		[self associateValue:events withKey:&kControlHandlersKey];
	}
	
	NSNumber *key = [NSNumber numberWithUnsignedInteger:controlEvents];
	NSMutableSet *handlers = [events objectForKey:key];
	if (!handlers) {
		handlers = [NSMutableSet set];
		[events setObject:handlers forKey:key];
	}
	
	BKControlWrapper *target = [[BKControlWrapper alloc] initWithHandler:handler forControlEvents:controlEvents];
	[handlers addObject:target];
	[self addTarget:target action:@selector(invoke:) forControlEvents:controlEvents];
	[target release];
}

- (void)removeEventHandlersForControlEvents:(UIControlEvents)controlEvents {
	NSMutableDictionary *events = [self associatedValueForKey:&kControlHandlersKey];
	if (!events) {
		events = [NSMutableDictionary dictionary];
		[self associateValue:events withKey:&kControlHandlersKey];
	}
	
	NSNumber *key = [NSNumber numberWithUnsignedInteger:controlEvents];
	NSSet *handlers = [events objectForKey:key];

	if (!handlers)
		return;
	
	[handlers each:^(id sender) {
		[self removeTarget:sender action:NULL forControlEvents:controlEvents];
	}];
	
	[events removeObjectForKey:key];
}

- (BOOL)hasEventHandlersForControlEvents:(UIControlEvents)controlEvents {
	NSMutableDictionary *events = [self associatedValueForKey:&kControlHandlersKey];
	if (!events) {
		events = [NSMutableDictionary dictionary];
		[self associateValue:events withKey:&kControlHandlersKey];
	}
	
	NSNumber *key = [NSNumber numberWithUnsignedInteger:controlEvents];
	NSSet *handlers = [events objectForKey:key];
	
	if (!handlers)
		return NO;
	
	return handlers.count;
}

@end
