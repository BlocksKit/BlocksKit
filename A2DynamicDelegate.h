//
//  A2DynamicDelegate.h
//  A2DynamicDelegate
//
//  Created by Alexsander Akers on 11/26/11.
//  Copyright (c) 2011 Pandamonia LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/** A2DynamicDelegate implements a class's delegate,
 data source, or other delegated protocol by associating
 protocol methods with a block implementations.

    - (IBAction) annoyUser
    {
        // Create an alert view
        UIAlertView *alertView = [[UIAlertView alloc]
        						  initWithTitle: @"Hello World!"
        						  message: @"This alert's delegate is implemented using blocks. That's so cool!"
        						  delegate: nil
        						  cancelButtonTitle: @"Meh."
        						  otherButtonTitles: @"Woo!", nil];
        
        // Get the dynamic delegate
        A2DynamicDelegate *dd = alertView.dynamicDelegate;
        
        // Implement -alertViewShouldEnableFirstOtherButton:
        [dd implementMethod: @selector(alertViewShouldEnableFirstOtherButton:) withBlock: ^(UIAlertView *alertView) {
            NSLog(@"Message: %@", alertView.message);
            return YES;
        }];
        
        // Implement -alertView:willDismissWithButtonIndex:
        [dd implementMethod: @selector(alertView:willDismissWithButtonIndex:) withBlock: ^(UIAlertView *alertView, NSInteger buttonIndex) {
            NSLog(@"You pushed button #%d (%@)", buttonIndex, [alertView buttonTitleAtIndex: buttonIndex]);
        }];
        
        // Set the delegate
        alertView.delegate = dd;
        
        [alertView show];
        [alertView release];
    }
    
 A2DynamicDelegate is designed to be 'plug and play'. It just works. Pretty neat, huh?
 
 @warning An A2DynamicDelegate cannot simply be allocated. Calling one of the
 A2DynamicDelegate methods on NSObject, -dynamicDataSource, -dynamicDelegate,
 or -dynamicDelegateForProtocol: allows us to store the dynamic delegate as
 an associated object of the delegating object. This not only allows us to
 later retrieve it, but it also creates a strong relationship. Since delegates
 are usually weak references on the part of the delegating object, a dynamic
 delegate would be deallocated immediately after its declaring scope ends.
 */
@interface A2DynamicDelegate : NSObject {
	id _delegatingObject;
	NSMutableDictionary *_handlers;
}

/** A dictionary of custom handlers to be used by custom responders
 in a A2Dynamic(Protocol Name) subclass of A2DynamicDelegate, like
 `A2DynamicUIAlertViewDelegate`.
 */
@property (nonatomic, retain, readonly) NSMutableDictionary *handlers;

/** The object that the dynamic delegate implements methods for. */
@property (nonatomic, assign, readonly) id delegatingObject;

/** @name Block Class Method Implementations */

/** The block that is to be fired when the specified
 selector is called on the reciever.
 
 @param selector An encoded selector. Must not be NULL.
 @return A code block, or nil if no block is assigned.
 */
- (id) blockImplementationForMethod: (SEL) selector;

/** Assigns the given block to be fired when the specified
 selector is called on the reciever.
 
    [tableView.dynamicDataSource implementMethod:@selector(numberOfSectionsInTableView:)
								      withBlock:NSInteger^(UITableView *tableView){
        return 2;
    }];
 
 @warning Starting with A2DynamicDelegate 2.0, a block will
 not be checked for a matching signature. A block can have
 less parameters than the original selector and will be
 ignored, but cannot have more.
 
 @param selector An encoded selector. Must not be NULL.
 @param block A code block with the same signature as selector.
 */
- (void) implementMethod: (SEL) selector withBlock: (id) block;

/** Disassociates any block so that nothing will be fired
 when the specified selector is called on the reciever.
 
 @param selector An encoded selector. Must not be NULL.
 */
- (void) removeBlockImplementationForMethod: (SEL) selector;

/** @name Block Instance Method Implementations */

/** The block that is to be fired when the specified
 selector is called on the delegating object's class.
 
 @param selector An encoded selector. Must not be NULL.
 @return A code block, or nil if no block is assigned.
 */
- (id) blockImplementationForClassMethod: (SEL) selector;

/** Assigns the given block to be fired when the specified
 selector is called on the reciever.
 
 @warning Starting with A2DynamicDelegate 2.0, a block will
 not be checked for a matching signature. A block can have
 less parameters than the original selector and will be
 ignored, but cannot have more.
 
 @param selector An encoded selector. Must not be NULL.
 @param block A code block with the same signature as selector.
 */
- (void) implementClassMethod: (SEL) selector withBlock: (id) block;

/** Disassociates any blocks so that nothing will be fired
 when the specified selector is called on the delegating
 object's class.
 
 @param selector An encoded selector. Must not be NULL.
 */
- (void) removeBlockImplementationForClassMethod: (SEL) selector;

@end

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
 
 @see blockImplementationForMethod:
 @return A dynamic data source.
 */
- (id) dynamicDataSource;

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
 
 @see blockImplementationForMethod:
 @return A dynamic delegate.
 */
- (id) dynamicDelegate;

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
 @see blockImplementationForMethod:
 */
- (id) dynamicDelegateForProtocol: (Protocol *) protocol;

@end
