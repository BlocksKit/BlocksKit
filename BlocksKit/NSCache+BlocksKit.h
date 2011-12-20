//
//  NSCache+BlocksKit.h
//  %PROJECT
//

#import "BKGlobals.h"

/** NSCache with block adding of objects
 
 This category allows you to conditionally add objects to
 an instance of NSCache using blocks.  Both the normal
 delegation pattern and a block callback for NSCache's one
 delegate method are allowed.
 
 These methods emulate Rails caching behavior.

 Created by Igor Evsukov and contributed to BlocksKit.
 */

@interface NSCache (BlocksKit)

/** Returns the value associated with a given key. If there is no
 object for that key, it uses the result of the block, saves
 that to the cache, and returns it.
 
 This mimics the cache behavior of Ruby on Rails.  The following code:
 
	 @products = Rails.cache.fetch('products') do
	   Product.all
	 end
 
 becomes:
 
	 NSMutableArray *products = [cache objectForKey:@"products" withGetter:^id{
	   return [Product all];
	 }];
 
 @return The value associated with *key*, or the object returned
 by the block if no value is associated with *key*.
 @param key An object identifying the value.
 @param getterBlock A block used to get an object if there is no
 value in the cache.
 */
- (id)objectForKey:(id)key withGetter:(BKReturnBlock)getterBlock;

/** Called when an object is about to be evicted from the cache.

 This block callback is an analog for the cache:willEviceObject:
 method of NSCacheDelegate.
 */
@property (nonatomic, copy) void(^willEvictBlock)(NSCache *, id);

@end
