//
//  NSObject+BlockObservation.h
//  BlocksKit
//

#import "BlocksKit_Globals.h"

/** Blocks wrapper for key-value observation.

 In Mac OS X Panther, Apple introduced an API called "key-value
 observing."  It implements an [observer pattern](http://en.wikipedia.org/wiki/Observer_pattern),
 where an object will notify observers of any changes in state.

 NSNotification is a rudimentary form of this design style;
 KVO, however, allows for the observation of any change in key-value state.
 The API for key-value observation, however, is flawed, ugly, and lengthy.

 Like most of the other block abilities in BlocksKit, observation saves
 and a bunch of code and a bunch of potential bugs.
 
 Created by Andy Matuschak as [AMBlockObservation](https://gist.github.com/153676).
 Licensed in the public domain.

 @warning *Important:* Due to a design flaw in recent version of the Objective-C
 runtime, you must call removeObserverWithBlockToken: in the dealloc method
 of any object making use of block-based KVO.
 */

@interface NSObject (BlockObservation)

/** Adds an observer to an object conforming to NSKeyValueObserving.

 Adds a block observer that notifies executes the block immediately
 upon a state change.

 @see addObserverForKeyPath:onQueue:task
 @param keyPath A unique key identifying the observer to the reciever.
 @param task A block responding to the reciever and the KVO change.
 @return Returns a globally unique process identifier for removing
 observation with removeObserverWithBlockToken:.
 */
- (NSString *)addObserverForKeyPath:(NSString *)keyPath task:(BKObservationBlock)task;

/** Adds an observer to an object conforming to NSKeyValueObserving on a queue.

 Adds a block observer that notifies executes the block according
 to the given operation queue upon a state change.
 
 @param keyPath A unique key identifying the observer to the reciever.
 @param queue An NSOperationQueue the block can be fired on.
 @param task A block responding to the reciever and the KVO change.
 @return Returns a globally unique process identifier for removing
 observation with removeObserverWithBlockToken:.
 */
- (NSString *)addObserverForKeyPath:(NSString *)keyPath onQueue:(NSOperationQueue *)queue task:(BKObservationBlock)task;

/** Removes a block observer.
 
 @param token The unique key returned by the addObserverForKeyPath:task:
 and addObserverForKeyPath:onQueue:task: functions.
 */
- (void)removeObserverWithBlockToken:(NSString *)token;

@end
