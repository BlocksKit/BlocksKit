//
//  NSObject+BlockObservation.m
//  BlocksKit
//

#import "NSObject+BlockObservation.h"
#import "NSObject+AssociatedObjects.h"

@interface AMObserverTrampoline : NSObject {
@private
    __bk_weak id observee;
    NSString *keyPath;
    BKObservationBlock task;
    NSOperationQueue *queue;
    dispatch_once_t cancellationPredicate;    
}

- (AMObserverTrampoline *)initWithObservingObject:(id)obj keyPath:(NSString *)keyPath onQueue:(NSOperationQueue *)queue task:(BKObservationBlock)task;
- (void)cancelObservation;

@end

static char *AMObserverTrampolineContext = "AMObserverTrampolineContext";

@implementation AMObserverTrampoline

- (AMObserverTrampoline *)initWithObservingObject:(id)obj keyPath:(NSString *)newKeyPath onQueue:(NSOperationQueue *)newQueue task:(BKObservationBlock)newTask {
    if (!(self = [super init])) return nil;
    task = [newTask copy];
    keyPath = [newKeyPath copy];
    queue = BK_RETAIN(newQueue);
    observee = obj;
    cancellationPredicate = 0;
    [(NSObject*)obj addObserver:self forKeyPath:keyPath options:0 context:AMObserverTrampolineContext];
    return self;
}

- (void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    BKObservationBlock block = task;
    if (context == AMObserverTrampolineContext) {
        if (queue)
            [queue addOperationWithBlock:^{ block(object, change); }];
        else
            block(object, change);
    }
}

- (void)cancelObservation {
    dispatch_once(&cancellationPredicate, ^{
        [(NSObject*)observee removeObserver:self forKeyPath:keyPath];
        observee = nil;
    });
}

- (void)dealloc {
    [self cancelObservation];
#if BK_SHOULD_DEALLOC
    [task release];
    [keyPath release];
    [queue release];
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
        
        AMObserverTrampoline *trampoline = BK_AUTORELEASE([[AMObserverTrampoline alloc] initWithObservingObject:self keyPath:keyPath onQueue:queue task:task]);
        [dict setObject:trampoline forKey:token];
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
