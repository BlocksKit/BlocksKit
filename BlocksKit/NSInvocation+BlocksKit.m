//
//  NSInvocation+BlocksKit.m
//  BlocksKit
//

#import "NSInvocation+BlocksKit.h"

@interface JRInvocationGrabber : NSProxy {
    id              target;
    NSInvocation    *invocation;
}
@property (retain) id target;
@property (retain) NSInvocation *invocation;

+ (JRInvocationGrabber *)grabberWithTarget:(id)target;
@end

@implementation JRInvocationGrabber
@synthesize target, invocation;

+ (JRInvocationGrabber *)grabberWithTarget:(id)target {
    JRInvocationGrabber *instance = [JRInvocationGrabber alloc];
    instance.target = target;
#if __has_feature(objc_arc)
    return instance;
#else
    return [instance autorelease];
#endif
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector_ {
    return [self.target methodSignatureForSelector:selector_];
}

- (void)forwardInvocation:(NSInvocation*)invocation_ {
    [invocation_ setTarget:self.target];
    self.invocation = invocation_;
}

#if !__has_feature(objc_arc)
- (void)dealloc {
    self.target = nil;
    self.invocation = nil;
    [super dealloc];
}
#endif

@end

@implementation NSInvocation (BlocksKit)

+ (NSInvocation *)invocationWithTarget:(id)target block:(BKSenderBlock)block {
    JRInvocationGrabber *grabber = [JRInvocationGrabber grabberWithTarget:target];
    block(grabber);
    return grabber.invocation;
}

@end
