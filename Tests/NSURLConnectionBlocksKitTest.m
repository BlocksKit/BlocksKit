//
//  NSURLConnectionBlocksKitTest.m
//  BlocksKit Unit Tests
//
//  Created by Zachary Waldowski on 12/20/11.
//  Copyright (c) 2011-2012 Pandamonia LLC. All rights reserved.
//

#import "NSURLConnectionBlocksKitTest.h"

@implementation NSURLConnectionBlocksKitTest

- (void)testAsyncConnection {
	[self prepare];
	NSURL *URL = [NSURL URLWithString:@"http://google.com/"];
	NSURLRequest *request = [NSURLRequest requestWithURL:URL];
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest: request];
	conn.successBlock = ^(NSURLConnection *connection, NSURLResponse *response, NSData *data) {
		[self notify:data.length ? SenTestCaseWaitStatusSuccess : SenTestCaseWaitStatusFailure forSelector: @selector(testAsyncConnection)];
	};
	conn.failureBlock = ^(NSURLConnection *connection, NSError *err) {
		[self notify: SenTestCaseWaitStatusFailure forSelector: @selector(testAsyncConnection)];
	};
	[conn start];
	[self waitForStatus: SenTestCaseWaitStatusSuccess timeout:10.0];
}

@end
