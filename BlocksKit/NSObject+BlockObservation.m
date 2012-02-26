//
//  NSObject+BlockObservation.m
//  BlocksKit
//

#import "NSObject+BlockObservation.h"
#import "NSObject+AssociatedObjects.h"
#import "NSDictionary+BlocksKit.h"

@interface BKObserver : NSObject {
	id observee;
	NSString *keyPath;
	BKObservationBlock task;
}

@property (nonatomic, assign) id observee;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, copy) BKObservationBlock task;

+ (BKObserver *)observerForObject:(id)observee keyPath:(NSString *)keyPath task:(BKObservationBlock)task;

@end

static char kObserverBlocksKey;
static char kBlockObservationContext;

@implementation BKObserver

@synthesize observee, keyPath, task;

+ (BKObserver *)observerForObject:(id)observee keyPath:(NSString *)newKeyPath task:(BKObservationBlock)newTask {
	BKObserver *instance = [BKObserver new];
	instance.observee = observee;
	instance.keyPath = newKeyPath;
	instance.task = newTask;
	return [instance autorelease];
}

- (void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == &kBlockObservationContext)
		self.task(object, change);
}

- (void)dealloc {
	self.task = nil;
	self.keyPath = nil;
	[super dealloc];
}

@end


static dispatch_queue_t BKObserverMutationQueue() {
	static dispatch_queue_t queue = nil;
	static dispatch_once_t token = 0;
	dispatch_once(&token, ^{
		queue = dispatch_queue_create("org.blockskit.observers.queue", 0);
	});
	return queue;
}

@implementation NSObject (BlockObservation)

- (NSString *)addObserverForKeyPath:(NSString *)keyPath task:(BKObservationBlock)task {
	NSString *token = [[NSProcessInfo processInfo] globallyUniqueString];
	[self addObserverForKeyPath:keyPath identifier:token options:0 task:task];
	return token;
}

- (void)addObserverForKeyPath:(NSString *)keyPath identifier:(NSString *)identifier task:(BKObservationBlock)task {
	[self addObserverForKeyPath:keyPath identifier:identifier options:0 task:task];
}

- (NSString *)addObserverForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options task:(BKObservationBlock)task {
	NSString *token = [[NSProcessInfo processInfo] globallyUniqueString];
	[self addObserverForKeyPath:keyPath identifier:token options:options task:task];
	return token;
}

- (void)addObserverForKeyPath:(NSString *)keyPath identifier:(NSString *)identifier options:(NSKeyValueObservingOptions)options task:(BKObservationBlock)task {
	NSParameterAssert(keyPath);
	NSParameterAssert(identifier);
	NSParameterAssert(task);
	
	__block BKObserver *newObserver = nil;
	
	dispatch_sync(BKObserverMutationQueue(), ^{
		newObserver = [BKObserver observerForObject:self keyPath:keyPath task:task];
		
		NSMutableDictionary *dict = [self associatedValueForKey:&kObserverBlocksKey];
		if (!dict) {
			dict = [NSMutableDictionary dictionary];
			[self associateValue:dict withKey:&kObserverBlocksKey];
		}
		
		[dict setObject:newObserver forKey:[NSString stringWithFormat:@"%@_%@", keyPath, identifier]];
	});
	
	[self addObserver:newObserver forKeyPath:keyPath options:options context:&kBlockObservationContext];
}

- (void)removeObserverForKeyPath:(NSString *)keyPath identifier:(NSString *)identifier {
	NSParameterAssert(keyPath);
	NSParameterAssert(identifier);
	
	dispatch_sync(BKObserverMutationQueue(), ^{
		NSString *token = [NSString stringWithFormat:@"%@_%@", keyPath, identifier];
		NSMutableDictionary *dict = [self associatedValueForKey:&kObserverBlocksKey];
		BKObserver *trampoline = [dict objectForKey:token];
		
		if (!trampoline || ![trampoline.keyPath isEqualToString:keyPath])
			return;
		
		[self removeObserver:trampoline forKeyPath:keyPath];
		
		[dict removeObjectForKey:token];
		
		if (!dict.count)
			[self associateValue:nil withKey:&kObserverBlocksKey];
	});
}

- (void)removeAllBlockObservers {
	dispatch_sync(BKObserverMutationQueue(), ^{
		NSMutableDictionary *observationDictionary = [self associatedValueForKey:&kObserverBlocksKey];
		[observationDictionary each:^(id key, id trampoline) {
			[self removeObserver:trampoline forKeyPath:[trampoline keyPath]];
		}];
		[self associateValue:nil withKey:&kObserverBlocksKey];
	});
}

@end
