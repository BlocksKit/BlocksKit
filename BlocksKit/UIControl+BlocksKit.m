//
//  UIControl+BlocksKit.m
//  BlocksKit
//

#import "UIControl+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"
#import "NSArray+BlocksKit.h"

static char kControlBlockArrayKey; 

@interface BKBlockWrapper : NSObject {
@private
    void (^action)(id sender);
    UIControlEvents controlEvents;
}

+ (BKBlockWrapper *)wrapperWithAction:(void (^)(id sender))action forControlEvents:(UIControlEvents)controlEvents;

@property (nonatomic, copy) void (^action)(id sender);
@property (nonatomic, assign) UIControlEvents controlEvents;

- (void)invokeWithSender:(id)sender;

@end

@implementation BKBlockWrapper

@synthesize action, controlEvents;

+ (BKBlockWrapper *)wrapperWithAction:(void (^)(id sender))action forControlEvents:(UIControlEvents)controlEvents {
    BKBlockWrapper *instance = [[BKBlockWrapper alloc] init];
    instance.action = action;
    instance.controlEvents = controlEvents;
    return [instance autorelease];
}

- (void)dealloc {
    [action release]; action = nil;
    [super dealloc];
}

- (void)invokeWithSender:(id)sender {
    self.action(sender);
}

@end


@implementation UIControl (BlocksKit)

- (void)addEventHandler:(void (^)(id sender))handler forControlEvents:(UIControlEvents)controlEvents {
    NSMutableArray *actions = [self associatedValueForKey:&kControlBlockArrayKey];
    
    if (!actions) {
        actions = [[NSMutableArray alloc] init];
        [self associateValue:actions withKey:&kControlBlockArrayKey];
        [actions release];
    }
    
    BKBlockWrapper *target = [BKBlockWrapper wrapperWithAction:handler forControlEvents:controlEvents];
    [actions addObject:target];
    [self addTarget:target action:@selector(invokeWithSender:) forControlEvents:controlEvents];
    [target release];    
}

- (void)removeEventHandlersForControlEvents:(UIControlEvents)controlEvents {
    NSMutableArray *actions = [self associatedValueForKey:&kControlBlockArrayKey];
    
    if (!actions)
        return;
    
    [actions removeObjectsInArray:[actions select:^BOOL(id obj) {
        if ([obj isKindOfClass:[BKBlockWrapper class]])
            return ([(BKBlockWrapper*)obj controlEvents] == controlEvents);
        return NO;
    }]];
}

@end
