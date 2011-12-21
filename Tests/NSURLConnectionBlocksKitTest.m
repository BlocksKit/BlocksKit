//
//  NSURLConnectionBlocksKitTest.m
//  BlocksKit Unit Tests


#import "NSURLConnectionBlocksKitTest.h"

@implementation NSURLConnectionBlocksKitTest

- (void)testAsyncConnection {
	[self prepare];
	NSURL *URL = [NSURL URLWithString:@"http://google.com/"];
	NSURLRequest *request = [NSURLRequest requestWithURL:URL];
	[NSURLConnection startConnectionWithRequest:request successHandler:^(NSURLConnection *connection, NSURLResponse *response, NSData *data) {
		[self notify:data.length ? kGHUnitWaitStatusSuccess : kGHUnitWaitStatusFailure forSelector:@selector(testAsyncConnection)];
	} failureHandler:^(NSURLConnection *connection, NSError *err) {
		[self notify:kGHUnitWaitStatusFailure forSelector:@selector(testAsyncConnection)];
	}];
	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
}

@end
