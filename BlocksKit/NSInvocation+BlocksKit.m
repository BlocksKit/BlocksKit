//
//  NSInvocation+BlocksKit.m
//  BlocksKit
//

#import "NSInvocation+BlocksKit.h"

@interface BKInvocationGrabber : NSProxy {
	id target;
	NSInvocation *invocation;
}

+ (BKInvocationGrabber *)grabberWithTarget:(id)target;

@property (nonatomic, retain) id target;
@property (nonatomic, retain) NSInvocation *invocation;

@end

@implementation BKInvocationGrabber

@synthesize target, invocation;

+ (BKInvocationGrabber *)grabberWithTarget:(id)target {
	BKInvocationGrabber *instance = [BKInvocationGrabber alloc];
	instance.target = target;
	return [instance autorelease];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector_ {
	return [self.target methodSignatureForSelector:selector_];
}

- (void)forwardInvocation:(NSInvocation*)invocation_ {
	[invocation_ setTarget:self.target];
	self.invocation = invocation_;
}

- (void)dealloc {
	self.target = nil;
	self.invocation = nil;
	[super dealloc];
}

@end


@implementation NSInvocation (BlocksKit)

+ (NSInvocation *)invocationWithTarget:(id)target block:(BKSenderBlock)block {
	NSParameterAssert(block != nil);
	BKInvocationGrabber *grabber = [BKInvocationGrabber grabberWithTarget:target];
	block(grabber);
	return grabber.invocation;
}

@end
