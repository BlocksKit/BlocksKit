//
//  NSCacheBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "NSCacheBlocksKitTest.h"
#import <BlocksKit/A2DynamicDelegate.h>
#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/NSCache+BlocksKit.h>

#define OBJECT_COUNT 300

@implementation NSCacheBlocksKitTest  {
	NSCache *_subject;
	NSInteger _total;
}

- (void)setUp {
	_subject = [NSCache new];
}

- (void)tearDown {
	_subject = nil;
}

- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
	_total--;
}

- (void)testDelegate {
	_subject.delegate = self;
	_total = 2;
	__unsafe_unretained NSCacheBlocksKitTest *weakSelf = self;
	_subject.bk_willEvictBlock = ^(NSCache *cache, id obj){
		weakSelf->_total--;
	};
	[_subject.bk_dynamicDelegate cache:_subject willEvictObject:nil];
	STAssertEquals(_total, (NSInteger)0, @"The delegates should have been called!");
}

@end
