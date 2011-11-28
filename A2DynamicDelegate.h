//
//  A2DynamicDelegate.h
//  DynamicDelegate
//
//  Created by Alexsander Akers on 11/26/11.
//  Copyright (c) 2011 Pandamonia LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface A2DynamicDelegate : NSObject

- (BOOL) implementSelector: (SEL) aSelector withBlock: (id) block;
- (BOOL) removeImplementationForSelector: (SEL) aSelector;

- (id) implementationForSelector: (SEL) aSelector;

@end

@interface NSObject (A2DynamicDelegate)

// Assumes protocol name is "ClassName + Delegate
- (A2DynamicDelegate *) dynamicDelegate;

// Designated initializer
- (A2DynamicDelegate *) dynamicDelegateForProtocol: (Protocol *) aProtocol;

@end
