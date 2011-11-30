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

- (id) implementationForSelector: (SEL) aSelector;

- (void) implementSelector: (SEL) aSelector withBlock: (id) block;
- (void) removeImplementationForSelector: (SEL) aSelector;

#pragma mark - Protocol Class Methods

- (id) implementationForClassSelector: (SEL) aSelector;

- (void) implementClassSelector: (SEL) aSelector withBlock: (id) block;
- (void) removeImplementationForClassSelector: (SEL) aSelector;

#pragma mark - Protocol Properties

- (void *) valueForProperty: (NSString *) propertyName;
- (void) setValue: (void *) value forProperty: (NSString *) propertyName;

@end

@interface NSObject (A2DynamicDelegate)

// Assumes protocol name is "ClassName + Delegate
- (A2DynamicDelegate *) dynamicDelegate;

// Designated initializer
- (A2DynamicDelegate *) dynamicDelegateForProtocol: (Protocol *) aProtocol;

@end
