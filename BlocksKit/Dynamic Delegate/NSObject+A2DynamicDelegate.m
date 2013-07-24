//
//  NSObject+A2DynamicDelegate.m
//  BlocksKit
//

#import <objc/runtime.h>
#import "NSObject+A2DynamicDelegate.h"

extern Protocol *a2_dataSourceProtocol(Class cls);
extern Protocol *a2_delegateProtocol(Class cls);

static dispatch_queue_t a2_backgroundQueue(void)
{
	static dispatch_once_t onceToken;
	static dispatch_queue_t backgroundQueue = nil;
	dispatch_once(&onceToken, ^{
		backgroundQueue = dispatch_queue_create("us.pandamonia.A2DynamicDelegate.backgroundQueue", DISPATCH_QUEUE_SERIAL);
	});
	return backgroundQueue;
}

@implementation NSObject (A2DynamicDelegate)

- (id)bk_dynamicDataSource
{
	Protocol *protocol = a2_dataSourceProtocol([self class]);
	return [self bk_dynamicDelegateForProtocol:protocol];
}
- (id)bk_dynamicDelegate
{
	Protocol *protocol = a2_delegateProtocol([self class]);
	return [self bk_dynamicDelegateForProtocol:protocol];
}
- (id)bk_dynamicDelegateForProtocol:(Protocol *)protocol
{
	/**
	 * Storing the dynamic delegate as an associated object of the delegating
	 * object not only allows us to later retrieve the delegate, but it also
	 * creates a strong relationship to the delegate. Since delegates are weak
	 * references on the part of the delegating object, a dynamic delegate
	 * would be deallocated immediately after its declaring scope ends.
	 * Therefore, this strong relationship is required to ensure that the
	 * delegate's lifetime is at least as long as that of the delegating object.
	 **/

	__block A2DynamicDelegate *dynamicDelegate;

	dispatch_sync(a2_backgroundQueue(), ^{
		dynamicDelegate = objc_getAssociatedObject(self, (__bridge const void *)protocol);

		if (!dynamicDelegate)
		{
			Class cls = NSClassFromString([@"A2Dynamic" stringByAppendingString:NSStringFromProtocol(protocol)]) ?: [A2DynamicDelegate class];
			dynamicDelegate = [[cls alloc] initWithProtocol:protocol];
			objc_setAssociatedObject(self, (__bridge const void *)protocol, dynamicDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		}
	});

	return dynamicDelegate;
}

@end
