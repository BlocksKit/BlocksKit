//
//  A2DynamicDelegate.h
//  A2DynamicDelegate
//
//  Created by Alexsander Akers on 11/26/11.
//  Copyright (c) 2011 Pandamonia LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface A2DynamicDelegate : NSObject {
	NSMutableDictionary *_handlers;
}

// Block objects *DO NOT* need to be copied before entering the dictionary.
@property (nonatomic, retain, readonly) NSMutableDictionary *handlers;

#pragma mark - Protocol Instance Methods

- (id) blockImplementationForMethod: (SEL) selector;

- (void) implementMethod: (SEL) selector withBlock: (id) block;
- (void) removeBlockImplementationForMethod: (SEL) selector;

#pragma mark - Protocol Class Methods

- (id) blockImplementationForClassMethod: (SEL) selector;

- (void) implementClassMethod: (SEL) selector withBlock: (id) block;
- (void) removeBlockImplementationForClassMethod: (SEL) selector;

@end

@interface NSObject (A2DynamicDelegate)

// Assumes protocol name is "Class ## DataSource"
- (id) dynamicDataSource;

// Assumes protocol name is "Class ## Delegate"
- (id) dynamicDelegate;

// Designated initializer
- (id) dynamicDelegateForProtocol: (Protocol *) protocol;

@end
