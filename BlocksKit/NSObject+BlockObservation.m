//
//  NSObject+BlockObservation.m
//  BlocksKit
//

#import "NSObject+BlockObservation.h"
#import "NSObject+AssociatedObjects.h"
#import "NSDictionary+BlocksKit.h"
#import "NSArray+BlocksKit.h"

@interface BKObserver : NSObject {
	id _task;
	id _observee;
	NSArray *_keyPaths;
}

@property (nonatomic, assign) id observee;
@property (nonatomic, copy) NSArray *keyPaths;
@property (nonatomic, copy) id task;

+ (BKObserver *)observerForObject:(id)object keyPaths:(NSArray *)keyPaths task:(id)task;

@end

static char kObserverBlocksKey;
static char kBlockObservationContext;
static char kMultipleBlockObservationContext;

@implementation BKObserver

@synthesize observee = _observee, keyPaths = _keyPaths, task = _task;

+ (BKObserver *)observerForObject:(id)object keyPaths:(NSArray *)keyPaths task:(id)task {
	BKObserver *instance = [BKObserver new];
	instance.observee = object;
	instance.keyPaths = keyPaths;
	instance.task = task;
	return [instance autorelease];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == &kBlockObservationContext) {
		BKObservationBlock task = self.task;
		task(object, change);
	} else if (context == &kMultipleBlockObservationContext) {
		BKMultipleObservationBlock task = self.task;
		task(object, keyPath, change);
	}
}

- (void)dealloc {
	self.task = nil;
	self.keyPaths = nil;
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

- (NSString *)addObserverForKeyPaths:(NSArray *)keyPaths task:(BKMultipleObservationBlock)task {
	NSString *token = [[NSProcessInfo processInfo] globallyUniqueString];
	[self addObserverForKeyPaths:keyPaths identifier:token options:0 task:task];
	return token;
}

- (void)addObserverForKeyPath:(NSString *)keyPath identifier:(NSString *)identifier options:(NSKeyValueObservingOptions)options task:(BKObservationBlock)task {
	[self addObserverForKeyPaths:[NSArray arrayWithObject:keyPath] identifier:identifier options:options task:(id)task];
}

- (void)addObserverForKeyPaths:(NSArray *)keyPaths identifier:(NSString *)identifier options:(NSKeyValueObservingOptions)options task:(BKMultipleObservationBlock)task {
	NSParameterAssert(keyPaths);
	NSParameterAssert(identifier);
	NSParameterAssert(task);
	
	__block BKObserver *newObserver = nil;
	
	dispatch_sync(BKObserverMutationQueue(), ^{
		newObserver = [BKObserver observerForObject:self keyPaths:keyPaths task:task];
		
		NSMutableDictionary *dict = [self associatedValueForKey:&kObserverBlocksKey];
		if (!dict) {
			dict = [NSMutableDictionary dictionary];
			[self associateValue:dict withKey:&kObserverBlocksKey];
		}
		
		[keyPaths each:^(NSString *keyPath) {
			[dict setObject:newObserver forKey:[NSString stringWithFormat:@"%@_%@", keyPath, identifier]];
		}];
	});
	
	void *context = keyPaths.count ? &kBlockObservationContext : &kMultipleBlockObservationContext;
	[keyPaths each:^(NSString *keyPath) {
		[self addObserver:newObserver forKeyPath:keyPath options:options context:context];
	}];
}

- (void)removeObserverForKeyPath:(NSString *)keyPath identifier:(NSString *)identifier {
	NSParameterAssert(keyPath);
	NSParameterAssert(identifier);
	
	dispatch_sync(BKObserverMutationQueue(), ^{
		NSString *token = [NSString stringWithFormat:@"%@_%@", keyPath, identifier];
		NSMutableDictionary *dict = [self associatedValueForKey:&kObserverBlocksKey];
		BKObserver *trampoline = [dict objectForKey:token];
		
		if (!trampoline || ![trampoline.keyPaths containsObject:keyPath])
			return;
		
		[self removeObserver:trampoline forKeyPath:keyPath];
		
		[dict removeObjectForKey:token];
		
		if (!dict.count)
			[self associateValue:nil withKey:&kObserverBlocksKey];
	});
}

- (void)removeObserversWithIdentifier:(NSString *)token {
	NSParameterAssert(token);
	
	dispatch_sync(BKObserverMutationQueue(), ^{
		NSMutableDictionary *dict = [self associatedValueForKey:&kObserverBlocksKey];
		NSDictionary *withIdentifier = [dict select:^BOOL(NSString *key, id obj) {
			return [key hasSuffix:token];
		}];
		
		[dict removeObjectsForKeys:withIdentifier.allKeys];
		
		if (!dict.count)
			[self associateValue:nil withKey:&kObserverBlocksKey];
		
		[withIdentifier each:^(NSString *key, BKObserver *trampoline) {
			NSString *keyPath = [key substringToIndex:key.length - token.length - 2];
			
			if (!trampoline || ![trampoline.keyPaths containsObject:keyPath])
				return;
			
			[self removeObserver:trampoline forKeyPath:keyPath];
		}];
	});
}

- (void)removeAllBlockObservers {
	dispatch_sync(BKObserverMutationQueue(), ^{
		NSMutableDictionary *observationDictionary = [self associatedValueForKey:&kObserverBlocksKey];
		[observationDictionary each:^(NSString *key, BKObserver *trampoline) {
			[trampoline.keyPaths each:^(NSString *keyPath) {
				[self removeObserver:trampoline forKeyPath:keyPath];
			}];
		}];
		[self associateValue:nil withKey:&kObserverBlocksKey];
	});
}

@end

BK_MAKE_CATEGORY_LOADABLE(NSKeyValueOvserving_BlocksKit)