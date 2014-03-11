//
//  NSObject+A2BlockDelegate.h
//  BlocksKit
//

#import <Foundation/Foundation.h>

/** The A2BlockDelegate category extends features provided by A2DynamicDelegate
 to create custom block properties in a category on a delegating object and
 dynamically map them to delegate (`UIAlertViewDelegate`), data source
 (`UITableViewDataSource`), or other delegated protocol
 (`NSErrorRecoveryAttempting`) methods.

 A2BlockDelegate also supports replacing the delegate of a given class with an
 automatic - though optional - version of these block-based properties, while
 still allowing for traditional method-based delegate implementations.

 Simply call one of the methods in the category on a class to add a block
 property to that class, preferably during a `+load` method in a category.

 To interplay between classes that support delegation but are extended to have
 block properties through delegate replacement extended to have block
 properties, one should implement an `A2Dynamic<ProtocolName>` subclass of
 `A2DynamicDelegate`. This behavior is documented in detail in the class
 documentation for A2DynamicDelegate, and examples exist in BlocksKit.
 */
@interface NSObject (A2BlockDelegate)

/** @name Linking Block Properties */

/** Synthesizes multiple properties and links them to the appropriate selector
 in the data source protocol.

 A2DynamicDelegate assumes a protocol name `FooBarDataSource` for instances of
 class `FooBar`. The method will generate appropriate `setHandler:` and
 `handler` implementations for each property name and selector name string pair.

 @param selectorsForPropertyNames A dictionary with property names as keys and
 selector strings as objects.
 */
+ (void)bk_linkDataSourceMethods:(NSDictionary *)selectorsForPropertyNames;

/** Synthesizes multiple properties and links them to the appropriate selector
 in the delegate protocol.

 A2DynamicDelegate assumes a protocol name `FooBarDelegate` for instances of
 class `FooBar`. The method will generate appropriate `setHandler:` and
 `handler` implementations for each property name and selector name string pair.

 @param selectorsForPropertyNames A dictionary with property names as keys and
 selectors strings as objects.
 */
+ (void)bk_linkDelegateMethods:(NSDictionary *)selectorsForPropertyNames;

/** Synthesizes multiple properties and links them to the appropriate selector
 in the given protocol.

 The method will generate appropriate `setHandler:` and `handler`
 implementations for each property name and selector name string pair.

 @param protocol A protocol that declares all of the given selectors. Must not
 be NULL.
 @param selectorsForPropertyNames A dictionary with property names as keys and
 selector strings as objects.
 */
+ (void)bk_linkProtocol:(Protocol *)protocol methods:(NSDictionary *)selectorsForPropertyNames;

/** @name Delegate replacement properties */

/** Registers a dynamic data source replacement using the property name
 `dataSource` and the protocol name `FooBarDataSource` for an instance of
 `FooBar`. */
+ (void)bk_registerDynamicDataSource;

/** Registers a dynamic delegate replacement using the property name `delegate`
 and the protocol name `FooBarDelegate` for an instance of `FooBar`. */
+ (void)bk_registerDynamicDelegate;

/** Registers a dynamic data source replacement using the given property name
 and the protocol name `FooBarDataSource` for an instance of `FooBar`.

 @param dataSourceName The name of the class' data source property. Must not be
 nil.
 */
+ (void)bk_registerDynamicDataSourceNamed:(NSString *)dataSourceName;

/** Registers a dynamic delegate replacement using the given property name and
 the protocol name `FooBarDelegate` for an instance of `FooBar`.

 @param delegateName The name of the class' delegate property. Must not be nil.
 */
+ (void)bk_registerDynamicDelegateNamed:(NSString *)delegateName;

/** Registers a dynamic protocol implementation replacement
 using the given property name and the given protocol.

 @param delegateName The name of the class' delegation protocol property, such
 as `safeDelegate`. Must not be nil.
 @param protocol A properly encoded protocol. Must not be NULL.
 */
+ (void)bk_registerDynamicDelegateNamed:(NSString *)delegateName forProtocol:(Protocol *)protocol;

@end
