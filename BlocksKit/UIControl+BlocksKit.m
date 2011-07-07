//
//  UIControl+BlocksKit.m
//  BlocksKit
//

#import "UIControl+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"
#import "NSArray+BlocksKit.h"

static char *kControlBlockArrayKey = "UIControlBlockHandlerArray";

@interface BKControlWrapper : NSObject

- (id)initWithHandler:(BKSenderBlock)aHandler forControlEvents:(UIControlEvents)someControlEvents;

@property (copy) BKSenderBlock handler;
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

#if BK_SHOULD_DEALLOC
- (void)dealloc {
    self.handler = nil;
    [super dealloc];
}
#endif

- (void)invoke:(id)sender {
    BKSenderBlock block = self.handler;
    if (block) dispatch_async(dispatch_get_main_queue(), ^{ block(sender); });
}

@end


@implementation UIControl (BlocksKit)

- (void)addEventHandler:(BKSenderBlock)handler forControlEvents:(UIControlEvents)controlEvents {
    NSMutableArray *actions = [self associatedValueForKey:&kControlBlockArrayKey];
    
    if (!actions) {
        actions = [NSMutableArray array];
        [self associateValue:actions withKey:&kControlBlockArrayKey];
    }
    
    BKControlWrapper *target = [[BKControlWrapper alloc] initWithHandler:handler forControlEvents:controlEvents];
    [actions addObject:target];
    [self addTarget:[actions lastObject] action:@selector(invoke:) forControlEvents:controlEvents];
    BK_RELEASE(target);
}

- (void)removeEventHandlersForControlEvents:(UIControlEvents)controlEvents {
    NSMutableArray *actions = [self associatedValueForKey:&kControlBlockArrayKey];
    
    if (!actions)
        return;
    
    NSArray *forControlEvent = [actions select:^BOOL(id obj) {
        return ([(BKControlWrapper*)obj controlEvents] == controlEvents);
    }];
    
    [forControlEvent each:^(id sender) {
        [self removeTarget:sender action:NULL forControlEvents:controlEvents];
    }];
    
    [actions removeObjectsInArray:forControlEvent];
}

@end
