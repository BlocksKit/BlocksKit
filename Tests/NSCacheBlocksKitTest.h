//
//  NSCacheBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <GHUnitIOS/GHUnit.h>
#import "BlocksKit/BlocksKit.h"

@interface NSCacheBlocksKitTest : GHAsyncTestCase {
    NSInteger total;
}

@property (nonatomic, retain) NSCache *subject;

- (void)testEvictionDelegate;

@end
