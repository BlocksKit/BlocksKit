//
//  NSObject+A2DynamicDelegate.h
//  BlocksKit
//

#import "BKDefines.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** The A2DynamicDelegate category to NSObject provides the primary interface
 by which dynamic delegates are generated for a given object. */
@interface NSObject (A2DynamicDelegate)

/** Creates or gets a dynamic data source for the reciever.

 A2DynamicDelegate assumes a protocol name `FooBarDataSource`
 for instances of class `FooBar`. The object is given a strong
 attachment to the reciever, and is automatically deallocated
 when the reciever is released.

 If the user implements a `A2DynamicFooBarDataSource` subclass
 of A2DynamicDelegate, its implementation of any method
 will be used over the block. If the block needs to be used,
 it can be called from within the custom
 implementation using blockImplementationForMethod:.

 @see <A2DynamicDelegate>blockImplementationForMethod:
 @return A dynamic data source.
 */
@property (readonly, strong) id bk_dynamicDataSource;

/** Creates or gets a dynamic delegate for the reciever.

 A2DynamicDelegate assumes a protocol name `FooBarDelegate`
 for instances of class `FooBar`. The object is given a strong
 attachment to the reciever, and is automatically deallocated
 when the reciever is released.

 If the user implements a `A2DynamicFooBarDelegate` subclass
 of A2DynamicDelegate, its implementation of any method
 will be used over the block. If the block needs to be used,
 it can be called from within the custom
 implementation using blockImplementationForMethod:.

 @see <A2DynamicDelegate>blockImplementationForMethod:
 @return A dynamic delegate.
 */
@property (readonly, strong) id bk_dynamicDelegate;

/** Creates or gets a dynamic protocol implementation for
 the reciever. The designated initializer.

 The object is given a strong attachment to the reciever,
 and is automatically deallocated when the reciever is released.

 If the user implements a subclass of A2DynamicDelegate prepended
 with `A2Dynamic`, such as `A2DynamicFooProvider`, its
 implementation of any method will be used over the block.
 If the block needs to be used, it can be called from within the
 custom implementation using blockImplementationForMethod:.

 @param protocol A custom protocol.
 @return A dynamic protocol implementation.
 @see <A2DynamicDelegate>blockImplementationForMethod:
 */
- (id)bk_dynamicDelegateForProtocol:(Protocol *)protocol;

@end

NS_ASSUME_NONNULL_END
