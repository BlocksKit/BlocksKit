//
//  NSObject+BlockObservation.m
//  BlocksKit
//

#import "NSObject+BlockObservation.h"
#import "NSObject+AssociatedObjects.h"

@interface AMObserverTrampoline : NSObject

@property (nonatomic, assign) id __bk_weak observee;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, copy) BKObservationBlock task;
@property (nonatomic, retain) NSOperationQueue *queue;
@property (nonatomic, assign) dispatch_once_t cancellationPredicate;

+ (AMObserverTrampoline *)trampolineWithObservingObject:(id)obj keyPath:(NSString *)newKeyPath onQueue:(NSOperationQueue *)newQueue task:(BKObservationBlock)newTask;
- (void)cancelObservation;

@end

static char *AMObserverTrampolineContext = "AMObserverTrampolineContext";

@implementation AMObserverTrampoline

@synthesize observee, keyPath, task, queue, cancellationPredicate;

+ (AMObserverTrampoline *)trampolineWithObservingObject:(id)obj keyPath:(NSString *)newKeyPath onQueue:(NSOperationQueue *)newQueue task:(BKObservationBlock)newTask {
    AMObserverTrampoline *instance = [AMObserverTrampoline new];
    instance.task = newTask;
    instance.keyPath = newKeyPath;
    instance.queue = newQueue;
    instance.observee = obj;
    instance.cancellationPredicate = 0;
    [(NSObject*)obj addObserver:instance forKeyPath:instance.keyPath options:0 context:AMObserverTrampolineContext];
    return BK_AUTORELEASE(instance);
}

- (void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    BKObservationBlock block = self.task;
    if (context == AMObserverTrampolineContext) {
        if (self.queue)
            [self.queue addOperationWithBlock:^{ block(object, change); }];
        else
            block(object, change);
    }
}

- (void)cancelObservation {
    dispatch_once(&cancellationPredicate, ^{
        [(NSObject*)self.observee removeObserver:self forKeyPath:self.keyPath];
        self.observee = nil;
    });
}

- (void)dealloc {
    [self cancelObservation];
#if BK_SHOULD_DEALLOC
    self.task = nil;
    self.keyPath = nil;
    self.queue = nil;
    [super dealloc];
#endif
}

@end

static char *AMObserverMapKey = "org.andymatuschak.observerMap";
static dispatch_queue_t AMObserverMutationQueue = NULL;

static dispatch_queue_t AMObserverMutationQueueCreateIfNecessary() {
    static dispatch_once_t queueCreationPredicate = 0;
    dispatch_once(&queueCreationPredicate, ^{
        AMObserverMutationQueue = dispatch_queue_create("org.andymatuschak.observerMutationQueue", 0);
    });
    return AMObserverMutationQueue;
}


@implementation NSObject (BlockObservation)

- (NSString *)addObserverForKeyPath:(NSString *)keyPath task:(BKObservationBlock)task {
    return [self addObserverForKeyPath:keyPath onQueue:nil task:task];
}

- (NSString *)addObserverForKeyPath:(NSString *)keyPath onQueue:(NSOperationQueue *)queue task:(BKObservationBlock)task {
    NSString *token = [[NSProcessInfo processInfo] globallyUniqueString];
    dispatch_sync(AMObserverMutationQueueCreateIfNecessary(), ^{
        NSMutableDictionary *dict = [self associatedValueForKey:AMObserverMapKey];
        if (!dict) {
            dict = [NSMutableDictionary dictionary];
            [self associateValue:dict withKey:AMObserverMapKey];
        }
        [dict setObject:[AMObserverTrampoline trampolineWithObservingObject:self keyPath:keyPath onQueue:queue task:task] forKey:token];
    });
    return token;
}

- (void)removeObserverWithBlockToken:(NSString *)token {
    dispatch_async(AMObserverMutationQueueCreateIfNecessary(), ^{
        NSMutableDictionary *observationDictionary = [self associatedValueForKey:AMObserverMapKey];
        AMObserverTrampoline *trampoline = [observationDictionary objectForKey:token];
        if (!trampoline) {
            NSLog(@"[NSObject(AMBlockObservation) removeObserverWithBlockToken]: Ignoring attempt to remove non-existent observer on %@ for token %@.", self, token);
            return;
        }
        [trampoline cancelObservation];
        [observationDictionary removeObjectForKey:token];

        if (!observationDictionary.count)
            [self associateValue:nil withKey:AMObserverMapKey];
    });
}

@end
