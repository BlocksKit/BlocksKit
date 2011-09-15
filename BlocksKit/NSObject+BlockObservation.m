//
//  NSObject+BlockObservation.m
//  BlocksKit
//

#import "NSObject+BlockObservation.h"
#import "NSObject+AssociatedObjects.h"

@interface BKObserver : NSObject

@property (nonatomic, assign) id observee;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, copy) BKObservationBlock task;
@property (nonatomic, assign) dispatch_once_t cancellationPredicate;

+ (BKObserver *)trampolineWithObservingObject:(id)obj keyPath:(NSString *)newKeyPath task:(BKObservationBlock)newTask;

@end

static char *kBKBlockObservationContext = "BKBlockObservationContext";

@implementation BKObserver

@synthesize observee, keyPath, task, cancellationPredicate;

+ (BKObserver *)trampolineWithObservingObject:(id)obj keyPath:(NSString *)newKeyPath task:(BKObservationBlock)newTask {
    BKObserver *instance = [BKObserver new];
    instance.task = newTask;
    instance.keyPath = newKeyPath;
    instance.observee = obj;
    instance.cancellationPredicate = 0;
    [(NSObject*)obj addObserver:instance forKeyPath:instance.keyPath options:0 context:kBKBlockObservationContext];
    return BK_AUTORELEASE(instance);
}

- (void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    BKObservationBlock block = self.task;
    if (self.task && context == kBKBlockObservationContext)
        block(object, change);
}

- (void)dealloc {
    dispatch_once(&cancellationPredicate, ^{
        [(NSObject*)self.observee removeObserver:self forKeyPath:self.keyPath];
        self.observee = nil;
    });
#if BK_SHOULD_DEALLOC
    self.task = nil;
    self.keyPath = nil;
    [super dealloc];
#endif
}

@end

static char *kObserversKey = "org.blockskit.observers.map";

static dispatch_queue_t BKObserverMutationQueue() {
    static dispatch_queue_t queue = nil;
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        queue = dispatch_queue_create("org.blockskit.observers.queue", 0);
    });
    return queue;
}

@implementation NSObject (BlockObservation)

- (void)addObserverForKeyPath:(NSString *)keyPath identifier:(NSString *)identifier task:(BKObservationBlock)task {
    dispatch_sync(BKObserverMutationQueue(), ^{
        NSString *token = [NSString stringWithFormat:@"%@////%@", identifier, keyPath];
        
        NSMutableDictionary *dict = [self associatedValueForKey:kObserversKey];
        if (!dict) {
            dict = [NSMutableDictionary dictionary];
            [self associateValue:dict withKey:kObserversKey];
        }
        
        [dict setObject:[BKObserver trampolineWithObservingObject:self keyPath:keyPath task:task] forKey:token];
    });
}

- (void)removeObserverForKeyPath:(NSString *)keyPath identifier:(NSString *)identifier {
    dispatch_async(BKObserverMutationQueue(), ^{
        NSMutableDictionary *observationDictionary = [self associatedValueForKey:kObserversKey];
        BKObserver *trampoline = [observationDictionary objectForKey:identifier];
        NSString *key = identifier;
        if (!trampoline) {
            NSString *token = [NSString stringWithFormat:@"%@////%@", keyPath, identifier];
            trampoline = [observationDictionary objectForKey:token];
            key = token;
        }
        
        if (!trampoline)
            return;
        
        if (![trampoline.keyPath isEqualToString:keyPath])
            return;
        
        [self removeObserver:trampoline forKeyPath:keyPath];
        
        [observationDictionary removeObjectForKey:key];
        
        if (!observationDictionary.count)
            [self associateValue:nil withKey:kObserversKey];
    });
}

- (void)removeAllBlockObservers {
    dispatch_async(BKObserverMutationQueue(), ^{
        NSMutableDictionary *observationDictionary = [self associatedValueForKey:kObserversKey];
        [observationDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            BKObserver *trampoline = obj;
            NSString *keyPath = trampoline.keyPath;
            [self removeObserver:trampoline forKeyPath:keyPath];
        }];
        [self associateValue:nil withKey:kObserversKey];
    });
}

@end
