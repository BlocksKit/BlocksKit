//
//  UIViewBlocksKitTest.m
//  BlocksKit
//
//  Created by Zachary Waldowski on 12/20/11.
//  Copyright (c) 2011 Dizzy Technology. All rights reserved.
//

#import "UIViewBlocksKitTest.h"

@implementation UIViewBlocksKitTest {
	UIView *_subject;
}

- (BOOL)shouldRunOnMainThread {
	return YES;
}

- (void)setUp {
	_subject = [UIView new];
}

- (void)tearDown {
	[_subject release];
}

- (void)testOnTouchDown {
	__block BOOL onTouchDownBlock = NO;
	_subject.onTouchDownBlock = ^(NSSet *touches, UIEvent *event) {
		onTouchDownBlock = YES;
	};
	
	[_subject touchesBegan:[NSSet set] withEvent:nil];
	
	GHAssertTrue(onTouchDownBlock, @"Block handler was not called");
}

- (void)testOnTouchMove {
	__block BOOL onTouchMoveBlock = NO;
	_subject.onTouchMoveBlock = ^(NSSet *touches, UIEvent *event) {
		onTouchMoveBlock = YES;
	};
	
	[_subject touchesMoved:[NSSet set] withEvent:nil];
	
	GHAssertTrue(onTouchMoveBlock, @"Block handler was not called");
}

- (void)testOnTouchUp {
	__block BOOL onTouchUpBlock = NO;
	_subject.onTouchUpBlock = ^(NSSet *touches, UIEvent *event) {
		onTouchUpBlock = YES;
	};
	
	[_subject touchesEnded:[NSSet set] withEvent:nil];
	
	GHAssertTrue(onTouchUpBlock, @"Block handler was not called");
}

@end
