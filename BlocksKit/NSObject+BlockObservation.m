//
//  NSObject+BlockObservation.m
//  BlocksKit
//

#import "NSObject+BlockObservation.h"
#import "NSObject+AssociatedObjects.h"

@interface AMObserverTrampoline : NSObject {
@private
    __weak id observee;
    NSString *keyPath;
    void (^task)(id obj, NSDictionary *change);
    NSOperationQueue *queue;
    dispatch_once_t cancellationPredicate;    
}

- (AMObserverTrampoline *)initObservingObject:(id)obj keyPath:(NSString *)keyPath onQueue:(NSOperationQueue *)queue task:(void (^)(id obj, NSDictionary *change))task;
- (void)cancelObservation;

@end

static NSString *AMObserverTrampolineContext = @"AMObserverTrampolineContext";

@implementation AMObserverTrampoline

- (AMObserverTrampoline *)initObservingObject:(id)obj keyPath:(NSString *)newKeyPath onQueue:(NSOperationQueue *)newQueue task:(void (^)(id obj, NSDictionary *change))newTask {
    if (!(self = [super init])) return nil;
    task = [newTask copy];
    keyPath = [newKeyPath copy];
    queue = [newQueue retain];
    observee = obj;
    cancellationPredicate = 0;
    [(NSObject*)obj addObserver:self forKeyPath:keyPath options:0 context:AMObserverTrampolineContext];
    return self;
}

- (void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == AMObserverTrampolineContext) {
        if (queue)
            [queue addOperationWithBlock:^{ task(object, change); }];
        else
            task(object, change);
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
    [task release];
    [keyPath release];
    [queue release];
    [super dealloc];
}

@end

static NSString *AMObserverMapKey = @"org.andymatuschak.observerMap";
static dispatch_queue_t AMObserverMutationQueue = NULL;

static dispatch_queue_t AMObserverMutationQueueCreateIfNecessary() {
    static dispatch_once_t queueCreationPredicate = 0;
    dispatch_once(&queueCreationPredicate, ^{
        AMObserverMutationQueue = dispatch_queue_create("org.andymatuschak.observerMutationQueue", 0);
    });
    return AMObserverMutationQueue;
}


@implementation NSObject (BlockObservation)

- (NSString *)addObserverForKeyPath:(NSString *)keyPath task:(void (^)(id obj, NSDictionary *change))task {
    return [self addObserverForKeyPath:keyPath onQueue:nil task:task];
}

- (NSString *)addObserverForKeyPath:(NSString *)keyPath onQueue:(NSOperationQueue *)queue task:(void (^)(id obj, NSDictionary *change))task {
    NSString *token = [[NSProcessInfo processInfo] globallyUniqueString];
    dispatch_sync(AMObserverMutationQueueCreateIfNecessary(), ^{
        NSMutableDictionary *dict = [self associatedValueForKey:AMObserverMapKey];
        if (!dict) {
            dict = [[NSMutableDictionary alloc] init];
            [self associateValue:dict withKey:AMObserverMapKey];
            [dict release];
        }
        AMObserverTrampoline *trampoline = [[AMObserverTrampoline alloc] initObservingObject:self keyPath:keyPath onQueue:queue task:task];
        [dict setObject:trampoline forKey:token];
        [trampoline release];
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
