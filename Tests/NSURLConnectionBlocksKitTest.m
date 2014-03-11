//
//  NSURLConnectionBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import <XCTest/XCTest.h>
#import <BlocksKit/NSURLConnection+BlocksKit.h>
#import "BKAsyncTestCase.h"

@interface NSURLConnectionBlocksKitTest : BKAsyncTestCase

@end

@implementation NSURLConnectionBlocksKitTest

- (void)testAsyncConnection {
	[self prepare];
	NSURL *URL = [NSURL URLWithString:@"http://google.com/"];
	NSURLRequest *request = [NSURLRequest requestWithURL:URL];
	NSURLConnection *conn = [[NSURLConnection alloc] bk_initWithRequest:request];
	conn.bk_successBlock = ^(NSURLConnection *connection, NSURLResponse *response, NSData *data) {
		[self notify:data.length ? SenTestCaseWaitStatusSuccess : SenTestCaseWaitStatusFailure forSelector:@selector(testAsyncConnection)];
	};
	conn.bk_failureBlock = ^(NSURLConnection *connection, NSError *err) {
		[self notify:SenTestCaseWaitStatusFailure forSelector:@selector(testAsyncConnection)];
	};
	[conn start];
	[self waitForStatus:SenTestCaseWaitStatusSuccess timeout:10.0];
}

@end
