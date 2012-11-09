//
//  NSObject+BlockObservation.m
//  BlocksKit
//

#import "NSObject+BlockObservation.h"
#import "NSObject+AssociatedObjects.h"
#import "NSDictionary+BlocksKit.h"
#import "NSArray+BlocksKit.h"
#import "NSSet+BlocksKit.h"

@interface BKObserver : NSObject

@property (nonatomic, unsafe_unretained) id observee;
@property (nonatomic, copy) NSArray *keyPaths;
@property (nonatomic, copy) id task;

+ (BKObserver *)observerForObject:(id)object keyPaths:(NSArray *)keyPaths task:(id)task;

@end

static char kObserverBlocksKey;
static char kBlockObservationNoChangeContext;
static char kMultipleBlockObservationNoChangeContext;
static char kBlockObservationContext;
static char kMultipleBlockObservationContext;

@implementation BKObserver

+ (BKObserver *)observerForObject:(id)object keyPaths:(NSArray *)keyPaths task:(id)task {
	BKObserver *instance = [BKObserver new];
	instance.observee = object;
	instance.keyPaths = keyPaths;
	instance.task = task;
	return instance;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == &kBlockObservationNoChangeContext) {
		BKSenderBlock task = self.task;
		task(object);
	} else if (context == &kBlockObservationContext) {
		BKObservationBlock task = self.task;
		task(object, change);
	} else if (context == &kMultipleBlockObservationNoChangeContext) {
		BKSenderKeyPathBlock task = self.task;
		task(object, keyPath);
	} else if (context == &kMultipleBlockObservationContext) {
		BKMultipleObservationBlock task = self.task;
		task(object, keyPath, change);
	}
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

- (NSString *)addObserverForKeyPath:(NSString *)keyPath task:(BKSenderBlock)task {
	return [self addObserverForKeyPath: keyPath options: 0 task: (id)task];
}

- (NSString *)addObserverForKeyPaths:(NSArray *)keyPaths task:(BKSenderKeyPathBlock)task {
	return [self addObserverForKeyPaths: keyPaths options: 0 task: (id)task];
}

- (NSString *)addObserverForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options task:(BKObservationBlock)task {
	NSString *token = [[NSProcessInfo processInfo] globallyUniqueString];
	[self addObserverForKeyPaths: @[keyPath] identifier: token options: options task: (id)task];
	return token;
}

- (NSString *)addObserverForKeyPaths:(NSArray *)keyPaths options:(NSKeyValueObservingOptions)options task:(BKMultipleObservationBlock)task {
	NSString *token = [[NSProcessInfo processInfo] globallyUniqueString];
	[self addObserverForKeyPaths: keyPaths identifier: token options: options task: task];
	return token;
}

- (void)addObserverForKeyPath:(NSString *)keyPath identifier:(NSString *)identifier options:(NSKeyValueObservingOptions)options task:(BKObservationBlock)task {
	[self addObserverForKeyPaths: @[keyPath] identifier: identifier options: options task: (id)task];
}

- (void)addObserverForKeyPaths:(NSArray *)keyPaths identifier:(NSString *)identifier options:(NSKeyValueObservingOptions)options task:(BKMultipleObservationBlock)task {
	NSParameterAssert(keyPaths.count);
	NSParameterAssert(identifier.length);
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
			dict[[NSString stringWithFormat:@"%@_%@", keyPath, identifier]] = newObserver;
		}];
	});
	
	void *context = (options == 0) ? ((keyPaths.count == 1) ? &kBlockObservationNoChangeContext : &kMultipleBlockObservationNoChangeContext) : ((keyPaths.count == 1) ? &kBlockObservationContext : &kMultipleBlockObservationContext);
	[keyPaths each:^(NSString *keyPath) {
		[self addObserver:newObserver forKeyPath:keyPath options:options context:context];
	}];
}

- (void)removeObserverForKeyPath:(NSString *)keyPath identifier:(NSString *)identifier {
	NSParameterAssert(keyPath.length);
	NSParameterAssert(identifier.length);
	
	dispatch_sync(BKObserverMutationQueue(), ^{
		NSString *token = [NSString stringWithFormat:@"%@_%@", keyPath, identifier];
		NSMutableDictionary *dict = [self associatedValueForKey:&kObserverBlocksKey];
		BKObserver *trampoline = dict[token];

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
			NSString *keyPath = [key substringToIndex:key.length - token.length - 1];
			
			if (!trampoline || ![trampoline.keyPaths containsObject:keyPath])
				return;
			
			[self removeObserver:trampoline forKeyPath:keyPath];
		}];
	});
}

- (void)removeAllBlockObservers {
    dispatch_sync(BKObserverMutationQueue(), ^{
        NSMutableDictionary *observationDictionary = [self associatedValueForKey:&kObserverBlocksKey];
        NSSet *trampolinesToRemove = [NSSet setWithArray:[observationDictionary allValues]];
        [trampolinesToRemove each:^(BKObserver *trampoline) {
            [trampoline.keyPaths each:^(NSString *keyPath) {
                [self removeObserver:trampoline forKeyPath:keyPath];
            }];
        }];
        [self associateValue:nil withKey:&kObserverBlocksKey];
    });
}

@end
