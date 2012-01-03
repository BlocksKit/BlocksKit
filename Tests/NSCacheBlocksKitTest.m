//
//  NSCacheBlocksKitTest.m
//  BlocksKit
//
//  Created by Zachary Waldowski on 10/5/11.
//  Copyright (c) 2011 Dizzy Technology. All rights reserved.
//

#import "NSCacheBlocksKitTest.h"
#import "NSTimer+BlocksKit.h"

#define OBJECT_COUNT 300

@implementation NSCacheBlocksKitTest  {
	NSCache *_subject;
	NSInteger _total;
}

- (void)setUp {
    _subject = [NSCache new];
}

- (void)tearDown {
	[_subject release];
}

- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
	_total--;
}

- (void)testDelegate {
	_subject.delegate = self;
	_total = 2;
	_subject.willEvictBlock = ^(NSCache *cache, id obj){
        _total--;
    };
	[_subject.dynamicDelegate cache:_subject willEvictObject:nil];
	GHAssertEquals(_total, 0, @"The delegates should have been called!");
}

@end
