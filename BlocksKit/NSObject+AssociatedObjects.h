//
//  NSObject+AssociatedObjects.h
//  %PROJECT
//

#import "BKGlobals.h"

/** Objective-C wrapper for 10.6 associated object API.

 In Mac OS X Snow Leopard and iOS 3.0, Apple introduced an
 addition to the Objective-C Runtime called associated objects.
 Associated objects allow for the pairing of a random key and
 object pair to be saved on an instance.

 In BlocksKit, associated objects allow us to emulate instance
 variables in the categories we use.
 
 Class methods also exist for each association. These associations
 are unique to each class, and exist for the lifetime of the
 application unless set to `nil`. Each class is a unique meta-object;
 the ultimate singleton.

 Created by Andy Matuschak as [AMAssociatedObjects](https://github.com/andymatuschak/NSObject-AssociatedObjects).
 Licensed in the public domain.
 */
@interface NSObject (AssociatedObjects)

/** Strongly associates an object with the reciever.

 The associated value is retained as if it were a property
 synthesized with `nonatomic` and `retain`.

 Using retained association is strongly recommended for most
 Objective-C object derivative of NSObject, particularly
 when it is subject to being externally released or is in an
 `NSAutoreleasePool`.

 @param value Any object.
 @param key A unique key pointer.
 */
- (void)associateValue:(id)value withKey:(const char *)key;

/** Strongly associates an object with the receiving class.
 
 @see associateValue:withKey:
 @param value Any object.
 @param key A unique key pointer.
 */
+ (void)associateValue:(id)value withKey:(const char *)key;

/** Associates a copy of an object with the reciever.

 The associated value is copied as if it were a property
 synthesized with `nonatomic` and `copy`.

 Using copied association is recommended for a block or
 otherwise `NSCopying`-compliant instances like NSString.

 @param value Any object, pointer, or value.
 @param key A unique key pointer.
 */
- (void)associateCopyOfValue:(id)value withKey:(const char *)key;

/** Associates a copy of an object with the receiving class.
 
 @see associateCopyOfValue:withKey:
 @param value Any object, pointer, or value.
 @param key A unique key pointer.
 */
+ (void)associateCopyOfValue:(id)value withKey:(const char *)key;

/** Weakly associates an object with the reciever.

 A weak association will cause the pointer to be set to zero
 or nil upon the disappearance of what it references;
 in other words, the associated object is not kept alive.

 @param value Any object.
 @param key A unique key pointer.
 */
- (void)weaklyAssociateValue:(id)value withKey:(const char *)key;

/** Weakly associates an object with the receiving class.
 
 @see weaklyAssociateValue:withKey:
 @param value Any object.
 @param key A unique key pointer.
 */
+ (void)weaklyAssociateValue:(id)value withKey:(const char *)key;

/** Returns the associated value for a key on the reciever.

 @param key A unique key pointer.
 @return The object associated with the key, or `nil` if not found.
 */
- (id)associatedValueForKey:(const char *)key;

/** Returns the associated value for a key on the receiving class.
 
 @see associatedValueForKey:
 @param key A unique key pointer.
 @return The object associated with the key, or `nil` if not found.
 */
+ (id)associatedValueForKey:(const char *)key;

/** Returns the reciever to a clean state by removing all
 associated objects, releasing them if necessary. */
- (void)removeAllAssociatedObjects;

/** Returns the recieving class to a clean state by removing
 all associated objects, releasing them if necessary. */
+ (void)removeAllAssociatedObjects;

@end
