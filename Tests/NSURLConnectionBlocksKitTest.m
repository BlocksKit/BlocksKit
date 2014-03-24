//
//  NSURLConnectionBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import <XCTest/XCTest.h>
#import <BlocksKit/NSURLConnection+BlocksKit.h>
#import "XCTestCase+BKAsyncTestCase.h"

@interface NSURLConnectionBlocksKitTest : XCTestCase

@end

@implementation NSURLConnectionBlocksKitTest

- (void)testAsyncConnection {
	[self bk_performAsyncTestWithTimeout:10 block:^{
		NSURL *URL = [NSURL URLWithString:@"http://google.com/"];
		NSURLRequest *request = [NSURLRequest requestWithURL:URL];
		NSURLConnection *conn = [[NSURLConnection alloc] bk_initWithRequest:request];
		conn.bk_successBlock = ^(NSURLConnection *connection, NSURLResponse *response, NSData *data) {
			[self bk_finishRunningAsyncTest];
		};
		conn.bk_failureBlock = ^(NSURLConnection *connection, NSError *err) {
			[self bk_finishRunningAsyncTest];
		};
		
		[conn start];
	}];
}

@end
