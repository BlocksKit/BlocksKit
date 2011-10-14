//
//  NSInvocation+BlocksKit.m
//  BlocksKit
//

#import "NSInvocation+BlocksKit.h"

@interface BKInvocationGrabber : NSProxy

+ (BKInvocationGrabber *)grabberWithTarget:(id)target;

@property (nonatomic, retain) id target;
@property (nonatomic, retain) NSInvocation *invocation;

@end

@implementation BKInvocationGrabber

@synthesize target, invocation;

+ (BKInvocationGrabber *)grabberWithTarget:(id)target {
    BKInvocationGrabber *instance = [BKInvocationGrabber alloc];
    instance.target = target;
    return BK_AUTORELEASE(instance);
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector_ {
    return [self.target methodSignatureForSelector:selector_];
}

- (void)forwardInvocation:(NSInvocation*)invocation_ {
    [invocation_ setTarget:self.target];
    self.invocation = invocation_;
}

#if BK_SHOULD_DEALLOC
- (void)dealloc {
    self.target = nil;
    self.invocation = nil;
    [super dealloc];
}
#endif

@end


@implementation NSInvocation (BlocksKit)

+ (NSInvocation *)invocationWithTarget:(id)target block:(BKSenderBlock)block {
    BKInvocationGrabber *grabber = [BKInvocationGrabber grabberWithTarget:target];
    block(grabber);
    return grabber.invocation;
}

@end
