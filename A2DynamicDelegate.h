//
//  A2DynamicDelegate.h
//  DynamicDelegate
//
//  Created by Alexsander Akers on 11/26/11.
//  Copyright (c) 2011 Pandamonia LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface A2DynamicDelegate : NSObject

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
- (A2DynamicDelegate *) dynamicDataSource;

// Assumes protocol name is "Class ## Delegate"
- (A2DynamicDelegate *) dynamicDelegate;

// Designated initializer
- (A2DynamicDelegate *) dynamicDelegateForProtocol: (Protocol *) protocol;

@end
