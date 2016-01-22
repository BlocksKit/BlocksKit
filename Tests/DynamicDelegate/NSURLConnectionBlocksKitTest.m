//
//  NSURLConnectionBlocksKitTest.m
//  BlocksKit Unit Tests
//

@import XCTest;
@import BlocksKit.Dynamic.Foundation;

@interface NSURLConnectionBlocksKitTest : XCTestCase

@end

@implementation NSURLConnectionBlocksKitTest

- (void)testAsyncConnection {
	XCTestExpectation *expectation = [self expectationWithDescription:@"Block callbacks reached"];

	NSURL *URL = [NSURL URLWithString:@"http://google.com/"];
	NSURLRequest *request = [NSURLRequest requestWithURL:URL];
	NSURLConnection *conn = [[NSURLConnection alloc] bk_initWithRequest:request];
	conn.bk_successBlock = ^(NSURLConnection *connection, NSURLResponse *response, NSData *data) {
		[expectation fulfill];
	};
	conn.bk_failureBlock = ^(NSURLConnection *connection, NSError *err) {
		[expectation fulfill];
	};
	
	[conn start];
	
	[self waitForExpectationsWithTimeout:10 handler:NULL];
}

@end
