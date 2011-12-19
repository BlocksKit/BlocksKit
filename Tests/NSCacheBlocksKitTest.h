//
//  NSCacheBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <GHUnitIOS/GHUnit.h>
#import "BlocksKit/BlocksKit.h"

@interface NSCacheBlocksKitTest : GHAsyncTestCase

@property (nonatomic, retain) NSCache *subject;

- (void)testDelegate;
//- (void)testEvictionDelegate;

@end
