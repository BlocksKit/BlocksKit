//
//  NSObject+BlockObservation.h
//  %PROJECT
//

#import "BKGlobals.h"

/** Blocks wrapper for key-value observation.

 In Mac OS X Panther, Apple introduced an API called "key-value
 observing."  It implements an [observer pattern](http://en.wikipedia.org/wiki/Observer_pattern),
 where an object will notify observers of any changes in state.

 NSNotification is a rudimentary form of this design style;
 KVO, however, allows for the observation of any change in key-value state.
 The API for key-value observation, however, is flawed, ugly, and lengthy.

 Like most of the other block abilities in BlocksKit, observation saves
 and a bunch of code and a bunch of potential bugs.
 
 Includes code by the following:
 
 - Andy Matuschak. <https://github.com/andymatuschak>. 2009. Public domain.
 - Jon Sterling. <https://github.com/jonsterling>. 2010. Public domain.
 - Zach Waldowski. <https://github.com/zwaldowski>. 2011. MIT.
 - Jonathan Wight. <https://github.com/schwa>. 2011. BSD.

 @warning *Important:* Due to a design flaw in some recent versions of the
 Objective-C runtime, you must call removeObserverWithBlockToken: in the
 dealloc method of any object making use of block-based KVO.
 */

@interface NSObject (BlockObservation)

/** Adds an observer to an object conforming to NSKeyValueObserving.

 Adds a block observer that notifies executes the block upon a
 state change.

 @param keyPath A unique key identifying the observer to the reciever.
 @param task A block responding to the reciever and the KVO change.
 @return Returns a globally unique process identifier for removing
 observation with removeObserverWithBlockToken:.
 */
- (NSString *)addObserverForKeyPath:(NSString *)keyPath task:(BKObservationBlock)task;

/** Adds an observer to an object conforming to NSKeyValueObserving.
 
 Adds a block observer that notifies executes the block upon a
 state change.
 
 @param keyPath A unique key identifying the observer to the reciever.
 @param token An identifier for observation block.
 @param task A block responding to the reciever and the KVO change.
 observation with removeObserverWithBlockToken:.
 */
- (void)addObserverForKeyPath:(NSString *)keyPath identifier:(NSString *)token task:(BKObservationBlock)task;

/** Adds an observer to an object conforming to NSKeyValueObserving.

 Adds a block observer that notifies executes the block immediately
 upon a state change.
 
 As of 29 Aug. 2011, this method is deprecated and all observation
 blocks are executed immediately.
 
 @param keyPath A unique key identifying the observer to the reciever.
 @param queue Deprecated, not honored.
 @param task A block responding to the reciever and the KVO change.
 @return Returns a globally unique process identifier for removing
 observation with removeObserverWithBlockToken:.
 */
- (NSString *)addObserverForKeyPath:(NSString *)keyPath onQueue:(NSOperationQueue *)queue task:(BKObservationBlock)task DEPRECATED_ATTRIBUTE;

/** Removes a block overserver.
 
 @param token The unique key returned by addObserverForKeyPath:task:
 or the identifier given in addObserverForKeyPath:identifier:task:.
 */ 
- (void)removeObserverForKeyPath:(NSString *)inKeyPath identifier:(NSString *)token;

/** Removes a block observer.
 
 @param token The unique key returned by addObserverForKeyPath:task:.
 */
- (void)removeObserverWithBlockToken:(NSString *)token DEPRECATED_ATTRIBUTE;

/** Removes all block observers regitered to this object.
 */
- (void)removeAllKVObservers;

@end
