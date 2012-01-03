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

- (void)testEvictionDelegate {
    _subject.willEvictBlock = ^(NSCache *cache, id obj){
        _total--;
    };
	
	_total = OBJECT_COUNT;
	
	@autoreleasepool {
		for (NSInteger i = 0; i < OBJECT_COUNT; i++) {
			NSString *string = [NSString stringWithFormat:@"%i", i];
			NSPurgeableData *obj = [NSPurgeableData dataWithBytes:string.UTF8String length:string.length];
			NSIndexPath *key = [NSIndexPath indexPathWithIndex:i];
			[_subject setObject:obj forKey:key];
		}
	}
	
    // force an eviction
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"UISimulatedMemoryWarningNotification", NULL, NULL, true);
    
    [self prepare];
    
    [self performSelector:@selector(_succeed) withObject:nil afterDelay:1];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10];
}

- (void)_succeed {
	NSInteger count = 0;
	for (NSInteger i = 0; i < OBJECT_COUNT; i++) {
		NSIndexPath *key = [NSIndexPath indexPathWithIndex:i];
		if ([_subject objectForKey: key]) count++;
	}
	
	if (_total == OBJECT_COUNT)
	{
		[self performSelector:@selector(_succeed) withObject:nil afterDelay:1];
		return;
	}
		
	GHAssertLessThan(_total, OBJECT_COUNT, @"The cache should have been emptied!");
    GHAssertEquals(_total, count, @"The cache should have been emptied!");
    [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testEvictionDelegate)];
    _subject.willEvictBlock = nil;
}

@end
