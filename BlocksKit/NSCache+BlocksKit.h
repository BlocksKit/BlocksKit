//
//  NSCache+BlocksKit.h
//  BlocksKit
//
//  Created by Evsukov Igor on 11.08.11.
//  Copyright 2011 Dizzy Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^BKReturnBlock)();

@interface NSCache (BlocksKit)

/** Returns an object from cache by key. If there is no object for key it is executes block,
 store it return object in cache by key and and return it.
 
 This mimics Rails cache behavior:
 
     @products = Rails.cache.fetch('products') do
       Product.all
     end
 
 will become:
 
     NSMutableArray *products = [cache objectForKey:@"products" withGetter:^id{
       return [Product all];
     }];
 
 @return object from cache. If non present, get it as block return value
 @param key a key for searching in cache
 @param getterBlock used to get a value for key if it is not present in cache
 */
- (id)objectForKey:(id)key withGetter:(BKReturnBlock)getterBlock;


/** Called when an object is about to be evicted or removed from the cache.
 */
@property (nonatomic, copy) BKSenderBlock willEvictObjectHandler;

@end
