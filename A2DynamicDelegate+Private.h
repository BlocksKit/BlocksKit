//
//  A2DynamicDelegate+Private.h
//  A2DynamicDelegate
//
//  Created by Alexsander Akers on 12/6/11.
//  Copyright (c) 2011 Pandamonia LLC. All rights reserved.
//

@interface A2DynamicDelegate ()

@property (nonatomic, assign) Protocol *protocol;

+ (A2DynamicDelegate *) dynamicDelegateForProtocol: (Protocol *) protocol; // Designated initializer

+ (NSMutableDictionary *) blockMap;

@end

@interface NSObject ()

+ (Protocol *) _delegateProtocol;
+ (Protocol *) _dataSourceProtocol;

@end
