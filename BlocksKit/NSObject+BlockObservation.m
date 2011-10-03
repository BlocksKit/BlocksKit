//
//  NSObject+BlockObservation.m
//  BlocksKit
//

#import "NSObject+BlockObservation.h"
#import "NSObject+AssociatedObjects.h"
#import "NSDictionary+BlocksKit.h"

@interface BKObserver : NSObject

@property (nonatomic, assign) id observee;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, copy) BKObservationBlock task;

+ (BKObserver *)trampolineWithObservingObject:(id)obj keyPath:(NSString *)newKeyPath task:(BKObservationBlock)newTask;

@end

static char *kBKBlockObservationContext = "BKBlockObservationContext";

@implementation BKObserver

@synthesize observee, keyPath, task;

+ (BKObserver *)trampolineWithObservingObject:(id)obj keyPath:(NSString *)newKeyPath task:(BKObservationBlock)newTask {
    BKObserver *instance = [BKObserver new];
    instance.task = newTask;
    instance.keyPath = newKeyPath;
    instance.observee = obj;
    [(NSObject*)obj addObserver:instance forKeyPath:instance.keyPath options:0 context:kBKBlockObservationContext];
    return BK_AUTORELEASE(instance);
}

- (void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    BKObservationBlock block = self.task;
    if (self.task && context == kBKBlockObservationContext)
        block(object, change);
    else
        [super observeValueForKeyPath:aKeyPath ofObject:object change:change context:context];
}

#if BK_SHOULD_DEALLOC
- (void)dealloc {
    self.task = nil;
    self.keyPath = nil;
    [super dealloc];
}
#endif

@end

static char *kObserverBlocksKey = "BKKeyValueObservers";

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
    [self addObserverForKeyPath:keyPath identifier:token task:task];
    return token;
}

- (void)addObserverForKeyPath:(NSString *)keyPath identifier:(NSString *)identifier task:(BKObservationBlock)task {
    BKObserver *newObserver = [BKObserver trampolineWithObservingObject:self keyPath:keyPath task:task];
    
    dispatch_sync(BKObserverMutationQueue(), ^{
        NSMutableDictionary *dict = [self associatedValueForKey:kObserverBlocksKey];
        if (!dict) {
            dict = [NSMutableDictionary dictionary];
            [self associateValue:dict withKey:kObserverBlocksKey];
        }
        
        [dict setObject:newObserver forKey:[NSString stringWithFormat:@"%@_%@", keyPath, identifier]];
    });
    
    [self addObserver:newObserver forKeyPath:keyPath options:0 context:kBKBlockObservationContext];
}

- (void)removeObserverForKeyPath:(NSString *)keyPath identifier:(NSString *)identifier {
    dispatch_async(BKObserverMutationQueue(), ^{
        NSString *token = [NSString stringWithFormat:@"%@_%@", keyPath, identifier];
        NSMutableDictionary *dict = [self associatedValueForKey:kObserverBlocksKey];
        BKObserver *trampoline = [dict objectForKey:token];
        
        if (!trampoline || ![trampoline.keyPath isEqualToString:keyPath])
            return;
        
        [self removeObserver:trampoline forKeyPath:keyPath];
        
        [dict removeObjectForKey:token];
        
        if (!dict.count)
            [self associateValue:nil withKey:kObserverBlocksKey];
    });
}

- (void)removeAllBlockObservers {
    dispatch_async(BKObserverMutationQueue(), ^{
        NSMutableDictionary *observationDictionary = [self associatedValueForKey:kObserverBlocksKey];
        [observationDictionary each:^(id key, BKObserver *trampoline) {
            NSString *keyPath = trampoline.keyPath;
            [self removeObserver:trampoline forKeyPath:keyPath];
        }];
        [self associateValue:nil withKey:kObserverBlocksKey];
    });
}

@end
