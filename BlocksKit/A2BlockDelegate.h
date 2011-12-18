//
//  A2BlockDelegate.h
//  A2DynamicDelegate
//
//  Created by Alexsander Akers on 11/30/11.
//  Copyright (c) 2011 Pandamonia LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (A2BlockDelegate)

#pragma mark - Data Source

+ (void) linkCategoryBlockProperty: (NSString *) propertyName withDataSourceMethod: (SEL) selector;
+ (void) linkDataSourceMethods: (NSDictionary *) selectorsForPropertyNames;

#pragma mark - Delegate

+ (void) linkCategoryBlockProperty: (NSString *) propertyName withDelegateMethod: (SEL) selector;
+ (void) linkDelegateMethods: (NSDictionary *) selectorsForPropertyNames;

#pragma mark - Other Protocol

+ (void) linkCategoryBlockProperty: (NSString *) propertyName withProtocol: (Protocol *) protocol method: (SEL) selector;
+ (void) linkProtocol: (Protocol *) protocol methods: (NSDictionary *) selectorsForPropertyNames;

@end
