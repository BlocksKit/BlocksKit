//
//  UIControl+BlocksKit.m
//  BlocksKit
//

#import "UIControl+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"
#import "NSSet+BlocksKit.h"

static char *kControlHandlersKey = "UIControlBlockHandlers";

#pragma mark Private

@interface BKControlWrapper : NSObject <NSCopying>
- (id)initWithHandler:(BKSenderBlock)aHandler forControlEvents:(UIControlEvents)someControlEvents;
@property (retain) BKSenderBlock handler;
@property (assign) UIControlEvents controlEvents;
- (void)invoke:(id)sender;
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
    BKSenderBlock block = self.handler;
    if (block) dispatch_async(dispatch_get_main_queue(), ^{ block(sender); });
}

#if BK_SHOULD_DEALLOC
- (void)dealloc {
    self.handler = nil;
    [super dealloc];
}
#endif

@end

#pragma mark Category

@implementation UIControl (BlocksKit)

- (void)addEventHandler:(BKSenderBlock)handler forControlEvents:(UIControlEvents)controlEvents {
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
    
    BKSenderBlock blockCopy = BK_AUTORELEASE([handler copy]);
    BKControlWrapper *target = [[BKControlWrapper alloc] initWithHandler:blockCopy forControlEvents:controlEvents];
    [handlers addObject:target];
    [self addTarget:target action:@selector(invoke:) forControlEvents:controlEvents];
    BK_RELEASE(target);
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
    
    return (handlers.count);
}

@end
