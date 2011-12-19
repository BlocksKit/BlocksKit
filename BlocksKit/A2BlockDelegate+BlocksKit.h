//
//  A2BlockDelegate+BlocksKit.h
//  BlocksKit
//
//  Created by Zachary Waldowski on 12/17/11.
//  Copyright (c) 2011 Dizzy Technology. All rights reserved.
//

#import "A2BlockDelegate.h"

@interface NSObject (A2BlockDelegateBlocksKit)

+ (void) registerDynamicDataSource;
+ (void) registerDynamicDelegate;

+ (void) registerDynamicDataSourceNamed: (NSString *) dataSourceName;
+ (void) registerDynamicDelegateNamed: (NSString *) delegateName;
+ (void) registerDynamicDelegateNamed: (NSString *) delegateName forProtocol: (Protocol *) protocol;

@end
