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
	/*NSURL *URL = [NSURL URLWithString:@"http://google.com/"];
	NSURLRequest *request = [NSURLRequest requestWithURL:URL];
	[NSURLConnection startConnectionWithRequest:request successHandler:^(NSURLConnection *connection, NSURLResponse *response, NSData *data) {
		[self notify:data.length ? SenAsyncTestCaseStatusSucceeded : SenAsyncTestCaseStatusFailed];
	} failureHandler:^(NSURLConnection *connection, NSError *err) {
		[self notify: SenAsyncTestCaseStatusFailed];
	}];
	[self waitForStatus: SenAsyncTestCaseStatusSucceeded timeout:10.0];*/
}

@end
