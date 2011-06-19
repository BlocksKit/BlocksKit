//
//  UIControl+BlocksKit.m
//  BlocksKit
//

#import "UIControl+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"
#import "NSArray+BlocksKit.h"

static char *kControlBlockArrayKey = "UIControlBlockHandlerArray";

@interface BKControlWrapper : NSObject

+ (id)wrapperWithHandler:(BKSenderBlock)aHandler forControlEvents:(UIControlEvents)someControlEvents;

@property (copy) BKSenderBlock handler;
@property (assign) UIControlEvents controlEvents;

- (void)invoke:(id)sender;

@end

@implementation BKControlWrapper

@synthesize handler, controlEvents;

+ (id)wrapperWithHandler:(BKSenderBlock)aHandler forControlEvents:(UIControlEvents)someControlEvents {
    BKControlWrapper *instance = [BKControlWrapper new];
    instance.handler = aHandler;
    instance.controlEvents = someControlEvents;
#if __has_feature(objc_arc)
    return instance;
#else
    return [instance autorelease];
#endif
}

#if !__has_feature(objc_arc)
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
    
    if (!actions)
        [self associateValue:[NSMutableArray array] withKey:&kControlBlockArrayKey];
    
    BKControlWrapper *target = [BKControlWrapper wrapperWithHandler:handler forControlEvents:controlEvents];
    [actions addObject:target];
    [self addTarget:target action:@selector(invoke:) forControlEvents:controlEvents];
    [target release];    
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
