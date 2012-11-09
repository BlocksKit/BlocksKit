//
//  NSCacheBlocksKitTest.m
//  BlocksKit
//
//  Created by Zachary Waldowski on 10/5/11.
//  Copyright (c) 2011-2012 Pandamonia LLC. All rights reserved.
//

#import "NSCacheBlocksKitTest.h"

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
	_subject.willEvictBlock = ^(NSCache *cache, id obj){
		weakSelf->_total--;
	};
	[_subject.dynamicDelegate cache:_subject willEvictObject:nil];
	STAssertEquals(_total, (NSInteger)0, @"The delegates should have been called!");
}

@end
