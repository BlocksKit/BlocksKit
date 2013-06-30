//
//  NSObject+BKBlockObservation.h
//  BlocksKit
//

#import <Foundation/Foundation.h>

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

 - [Andy Matuschak](https://github.com/andymatuschak)
 - [Jon Sterling](https://github.com/jonsterling)
 - [Zach Waldowski](https://github.com/zwaldowski)
 - [Jonathan Wight](https://github.com/schwa)
 */

@interface NSObject (BlockObservation)

/** Adds an observer to an object conforming to NSKeyValueObserving.

 Adds a block observer that executes a block upon a state change.

 @param keyPath The property to observe, relative to the reciever.
 @param task A block with no return argument, and a single parameter: the reciever.
 @return Returns a globally unique process identifier for removing
 observation with removeObserverWithBlockToken:.
 @see addObserverForKeyPath:identifier:options:task:
 */
- (NSString *)bk_addObserverForKeyPath:(NSString *)keyPath task:(void (^)(id target))task;

/** Adds an observer to an object conforming to NSKeyValueObserving.

 Adds a block observer that executes the same block upon
 multiple state changes.

 @param keyPaths An array of properties to observe, relative to the reciever.
 @param task A block with no return argument and two parameters: the
 reciever and the key path of the value change.
 @return A unique identifier for removing
 observation with removeObserverWithBlockToken:.
 @see addObserverForKeyPath:identifier:options:task:
 */
- (NSString *)bk_addObserverForKeyPaths:(NSArray *)keyPaths task:(void (^)(id obj, NSDictionary *keyPath))task;

/** Adds an observer to an object conforming to NSKeyValueObserving.

 Adds a block observer that executes a block upon a state change
 with specific options.

 @param keyPath The property to observe, relative to the reciever.
 @param options The NSKeyValueObservingOptions to use.
 @param task A block with no return argument and two parameters: the
 reciever and the change dictionary.
 @return Returns a globally unique process identifier for removing
 observation with removeObserverWithBlockToken:.
 @see addObserverForKeyPath:identifier:options:task:
 */
- (NSString *)bk_addObserverForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options task:(void (^)(id obj, NSDictionary *change))task;

/** Adds an observer to an object conforming to NSKeyValueObserving.

 Adds a block observer that executes the same block upon
 multiple state changes with specific options.

 @param keyPaths An array of properties to observe, relative to the reciever.
 @param options The NSKeyValueObservingOptions to use.
 @param task A block with no return argument and three parameters: the
 reciever, the key path of the value change, and the change dictionary.
 @param task A block responding to the reciever, the key path, and the KVO change.
 @return A unique identifier for removing
 observation with removeObserverWithBlockToken:.
 @see addObserverForKeyPath:identifier:options:task:
 */
- (NSString *)bk_addObserverForKeyPaths:(NSArray *)keyPaths options:(NSKeyValueObservingOptions)options task:(void (^)(id obj, NSString *keyPath, NSDictionary *change))task;

/** Adds an observer to an object conforming to NSKeyValueObserving.

 Adds a block observer that executes the block upon a
 state change.

 @param keyPath The property to observe, relative to the reciever.
 @param token An identifier for the observation block.
 @param options The NSKeyValueObservingOptions to use.
 @param task A block responding to the reciever and the KVO change.
 observation with removeObserverWithBlockToken:.
 @see addObserverForKeyPath:task:
 */
- (void)bk_addObserverForKeyPath:(NSString *)keyPath identifier:(NSString *)token options:(NSKeyValueObservingOptions)options task:(void (^)(id obj, NSDictionary *change))task;

/** Adds an observer to an object conforming to NSKeyValueObserving.

 Adds a block observer that executes the same block upon
 multiple state changes.

 @param keyPaths An array of properties to observe, relative to the reciever.
 @param token An identifier for the observation block.
 @param options The NSKeyValueObservingOptions to use.
 @param task A block responding to the reciever, the key path, and the KVO change.
 observation with removeObserversWithIdentifier:.
 @see addObserverForKeyPath:task:
 */
- (void)bk_addObserverForKeyPaths:(NSArray *)keyPaths identifier:(NSString *)token options:(NSKeyValueObservingOptions)options task:(void (^)(id obj, NSString *keyPath, NSDictionary *change))task;

/** Removes a block observer.

 @param keyPath The property to stop observing, relative to the reciever.
 @param token The unique key returned by addObserverForKeyPath:task:
 or the identifier given in addObserverForKeyPath:identifier:task:.
 @see removeObserversWithIdentifier:
 */
- (void)bk_removeObserverForKeyPath:(NSString *)keyPath identifier:(NSString *)token;

/** Removes multiple block observers with a certain identifier.

 @param token A unique key returned by addObserverForKeyPath:task:
 and addObserverForKeyPaths:task: or the identifier given in
 addObserverForKeyPath:identifier:task: and
 addObserverForKeyPaths:identifier:task:.
 @see removeObserverForKeyPath:identifier:
 */
- (void)bk_removeObserversWithIdentifier:(NSString *)token;

/** Remove all registered block observers. */
- (void)bk_removeAllBlockObservers;

@end
