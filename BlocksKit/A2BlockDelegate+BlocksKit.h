//
//  A2BlockDelegate+BlocksKit.h
//  BlocksKit
//
//  Created by Zachary Waldowski on 12/17/11.
//  Copyright (c) 2011 Dizzy Technology. All rights reserved.
//

#import "BKGlobals.h"

/** The A2BlockDelegate category for BlocksKit
 completes the trifecta of functionality introduced in
 A2DynamicDelegate, A2BlockDelegate, and their associated
 categories. A2BlockDelegate for BlocksKit replaces
 the delegate of supported classes with an automatic -
 though optional - set of block-based properties, while
 still allowing the original block.
 
 These methods should be called in a category's `+load`
 method, along with the associated A2BlockDelegate methods,
 before the application starts.
 
 To interplay between classes that support delegation but are
 extended to have block properties, one should implement an
 `A2DynamicProtocolName` subclass of A2DynamicDelegate`. This
 behavior is documented in detail in the class documentation
 for A2DynamicDelegate.
 
 All classes in BlocksKit that provide both delegation and
 block callbacks use this category.
 
 @see A2DynamicDelegate
 */
@interface NSObject (A2BlockDelegateBlocksKit)

/** Registers a dynamic data source replacement using
 the property name `dataSource` and the protocol name
 `FooBarDataSource` for an instance of `FooBar`. */
+ (void) registerDynamicDataSource;

/** Registers a dynamic delegate replacement using
 the property name `delegate` and the protocol name
 `FooBarDelegate` for an instance of `FooBar`. */
+ (void) registerDynamicDelegate;

/** Registers a dynamic data source replacement using
 the given property name and the protocol name
 `FooBarDataSource` for an instance of `FooBar`.
 
 @param dataSourceName The name of the class' data
 source property. Must not be nil.
 */
+ (void) registerDynamicDataSourceNamed: (NSString *) dataSourceName;

/** Registers a dynamic delegate replacement using
 the given property name and the protocol name
 `FooBarDelegate` for an instance of `FooBar`.
 
 @param delegateName The name of the class'
 delegate property. Must not be nil.
 */
+ (void) registerDynamicDelegateNamed: (NSString *) delegateName;

/** Registers a dynamic protocol implementation replacement
 using the given property name and the given protocol.
 
 @param delegateName The name of the class' delegation
 protocol property, such as `safeDelegate`. Must not be nil.
 @param protocol A properly encoded protocol. Must not
 be NULL.
 */
+ (void) registerDynamicDelegateNamed: (NSString *) delegateName forProtocol: (Protocol *) protocol;

@end

/** This lightweight extension allows subclasses
 of A2DynamicDelegate, when in use with the A2BlockDelegate
 BlocksKit category, to access the original delegate. */
@interface A2DynamicDelegate (A2BlockDelegate)

/* A delegating object's original delegate, be it a delegate, dataSource, etc. */
@property (nonatomic, readonly) id realDelegate;

@end