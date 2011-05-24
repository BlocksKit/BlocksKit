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
    BKSenderBlock action;
    UIControlEvents controlEvents;
}

- (id)initWithAction:(BKSenderBlock)anAction forControlEvents:(UIControlEvents)someControlEvents;

@property (nonatomic, copy) BKSenderBlock action;
@property (nonatomic, assign) UIControlEvents controlEvents;

- (void)invokeWithSender:(id)sender;

@end

@implementation BKBlockWrapper

@synthesize action, controlEvents;

- (id)initWithAction:(BKSenderBlock)anAction forControlEvents:(UIControlEvents)someControlEvents {
    if ((self = [super init])) {
        self.action = anAction;
        self.controlEvents = someControlEvents;
    }
    return self;
}

- (void)dealloc {
    [action release]; action = nil;
    [super dealloc];
}

- (void)invokeWithSender:(id)sender {
    BKSenderBlock block = self.action;
    if (block) dispatch_async(dispatch_get_main_queue(), ^{ block(sender); });
}

@end


@implementation UIControl (BlocksKit)

- (void)addEventHandler:(BKSenderBlock)handler forControlEvents:(UIControlEvents)controlEvents {
    NSMutableArray *actions = [self associatedValueForKey:&kControlBlockArrayKey];
    
    if (!actions) {
        actions = [[NSMutableArray alloc] init];
        [self associateValue:actions withKey:&kControlBlockArrayKey];
        [actions release];
    }
    
    BKBlockWrapper *target = [[BKBlockWrapper alloc] initWithAction:handler forControlEvents:controlEvents];
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
