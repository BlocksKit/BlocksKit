//
//  A2BlockDelegate+BlocksKit.h
//  BlocksKit
//
//  Created by Zachary Waldowski on 12/17/11.
//  Copyright (c) 2011 Dizzy Technology. All rights reserved.
//

#import "A2BlockDelegate.h"

@interface NSObject (A2BlockDelegateBlocksKit)

+ (void)swizzleDelegateProperty;
+ (void)swizzleDataSourceProperty;

@end

@interface A2DynamicDelegate (BlocksKit)

@property (nonatomic, readonly) id realDelegate;
@property (nonatomic, readonly) id realDataSource;

@end