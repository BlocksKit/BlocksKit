//
//  NSURLConnection+BlocksKit.m
//  BlocksKit
//

#import "NSURLConnection+BlocksKit.h"
@import ObjectiveC.runtime;
#import "A2DynamicDelegate.h"
#import "NSObject+A2DynamicDelegate.h"
#import "NSObject+A2BlockDelegate.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#pragma mark Private

static const void *BKResponseDataKey = &BKResponseDataKey;
static const void *BKResponseKey = &BKResponseKey;
static const void *BKResponseLengthKey = &BKResponseLengthKey;

@interface NSURLConnection (BlocksKitPrivate)

@property (nonatomic, retain, setter = bk_setResponseData:) NSMutableData *bk_responseData;
@property (nonatomic, retain, setter = bk_setResponse:) NSURLResponse *bk_response;
@property (nonatomic, setter = bk_setResponseLength:) NSUInteger bk_responseLength;

@end

@implementation NSURLConnection (BlocksKitPrivate)

- (NSMutableData *)bk_responseData
{
	return objc_getAssociatedObject(self, BKResponseDataKey);
}

- (void)bk_setResponseData:(NSMutableData *)responseData
{
	objc_setAssociatedObject(self, BKResponseDataKey, responseData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURLResponse *)bk_response
{
	return objc_getAssociatedObject(self, BKResponseKey);
}

- (void)bk_setResponse:(NSURLResponse *)response
{
	objc_setAssociatedObject(self, BKResponseKey, response, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)bk_responseLength
{
	return [objc_getAssociatedObject(self, BKResponseLengthKey) unsignedIntegerValue];
}

- (void)bk_setResponseLength:(NSUInteger)responseLength
{
	objc_setAssociatedObject(self, BKResponseLengthKey, @(responseLength), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark - BKURLConnectionInformalDelegate - iOS 4.3 & Snow Leopard support

@protocol BKURLConnectionInformalDelegate <NSObject>

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace;

@end

@interface A2DynamicBKURLConnectionInformalDelegate : A2DynamicDelegate <BKURLConnectionInformalDelegate>

@end

@implementation A2DynamicBKURLConnectionInformalDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(connection:didReceiveResponse:)])
		[realDelegate connection:connection didReceiveResponse:response];

	connection.bk_responseLength = 0;
	[connection.bk_responseData setLength:0];

	connection.bk_response = response;

	void (^block)(NSURLConnection *, NSURLResponse *) = [self blockImplementationForMethod:_cmd];
	if (block) block(connection, response);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	connection.bk_responseLength += data.length;

	void (^block)(double) = connection.bk_downloadBlock;
	if (block && connection.bk_response && connection.bk_response.expectedContentLength != NSURLResponseUnknownLength)
		block((double)connection.bk_responseLength / (double)connection.bk_response.expectedContentLength);

	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(connection:didReceiveData:)]) {
		[realDelegate connection:connection didReceiveData:data];
		return;
	}

	NSMutableData *responseData = connection.bk_responseData;
	if (!responseData) {
		responseData = [NSMutableData data];
		connection.bk_responseData = responseData;
	}

	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)])
		[realDelegate connection:connection didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];

	void (^block)(double) = connection.bk_uploadBlock;
	if (block) block((double)totalBytesWritten/(double)totalBytesExpectedToWrite);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(connectionDidFinishLoading:)])
		[realDelegate connectionDidFinishLoading:connection];

	if (!connection.bk_responseData.length)
		connection.bk_responseData = nil;

	void (^block)(NSURLConnection *, NSURLResponse *, NSData *) = connection.bk_successBlock;
	if (block) block(connection, connection.bk_response, connection.bk_responseData);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(connection:didFailWithError:)])
		[realDelegate connection:connection didFailWithError:error];

	connection.bk_responseLength = 0;
	[connection.bk_responseData setLength:0];

	void (^block)(NSURLConnection *, NSError *) = [self blockImplementationForMethod:_cmd];
	if (block) block(connection, error);
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(connection:didReceiveAuthenticationChallenge:)])
		[realDelegate connection:connection didReceiveAuthenticationChallenge:challenge];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(connection:canAuthenticateAgainstProtectionSpace:)])
		return [realDelegate connection:connection canAuthenticateAgainstProtectionSpace:protectionSpace];

	return NO;
}

@end

#pragma mark - NSURLConnectionDelegate - iOS 5.0 & Lion support

@interface A2DynamicNSURLConnectionDelegate : A2DynamicDelegate <NSURLConnectionDelegate>

@end

@implementation A2DynamicNSURLConnectionDelegate

- (BOOL)conformsToProtocol:(Protocol *)protocol
{
	Protocol *dataDelegateProtocol = objc_getProtocol("NSURLConnectionDataDelegate");
	return (protocol_isEqual(protocol, dataDelegateProtocol) || protocol_isEqual(protocol, self.protocol) || [super conformsToProtocol:protocol]);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(connection:didFailWithError:)])
		[realDelegate connection:connection didFailWithError:error];

	connection.bk_responseLength = 0;
	[connection.bk_responseData setLength:0];

	void (^block)(NSURLConnection *, NSError *) = [self blockImplementationForMethod:_cmd];
	if (block) block(connection, error);
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(connectionShouldUseCredentialStorage:)])
		return [realDelegate connectionShouldUseCredentialStorage:connection];

	return YES;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(connection:willSendRequestForAuthenticationChallenge:)])
		[realDelegate connection:connection willSendRequestForAuthenticationChallenge:challenge];
}

#pragma mark - NSURLConnectionDataDelegate

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(connection:willSendRequest:redirectResponse:)])
		return [realDelegate connection:connection willSendRequest:request redirectResponse:response];

	return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(connection:didReceiveResponse:)])
		[realDelegate connection:connection didReceiveResponse:response];

	connection.bk_responseLength = 0;

	if (connection.bk_responseData)
		[connection.bk_responseData setLength:0];

	connection.bk_response = response;

	void (^block)(NSURLConnection *, NSURLResponse *) = [self blockImplementationForMethod:_cmd];
	if (block) block(connection, response);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	connection.bk_responseLength += data.length;

	void (^block)(double) = connection.bk_downloadBlock;
	if (block && connection.bk_response && connection.bk_response.expectedContentLength != NSURLResponseUnknownLength)
		block((double)connection.bk_responseLength / (double)connection.bk_response.expectedContentLength);

	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(connection:didReceiveData:)]) {
		[realDelegate connection:connection didReceiveData:data];
		return;
	}

	NSMutableData *responseData = connection.bk_responseData;
	if (!responseData) {
		responseData = [NSMutableData data];
		connection.bk_responseData = responseData;
	}

	[responseData appendData:data];
}

- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(connection:needNewBodyStream:)])
		return [realDelegate connection:connection needNewBodyStream:request];

	return nil;
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)])
		[realDelegate connection:connection didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];

	void (^block)(double) = connection.bk_uploadBlock;
	if (block)
		block((double)totalBytesWritten/(double)totalBytesExpectedToWrite);
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(connection:willCacheResponse:)])
		return [realDelegate connection:connection willCacheResponse:cachedResponse];

	return cachedResponse;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(connectionDidFinishLoading:)])
		[realDelegate connectionDidFinishLoading:connection];

	if (!connection.bk_responseData.length)
		connection.bk_responseData = nil;

	void (^block)(NSURLConnection *, NSURLResponse *, NSData *) = connection.bk_successBlock;
	if (block)
		block(connection, connection.bk_response, connection.bk_responseData);
}

@end

#pragma mark - Category

static NSString *const kSuccessBlockKey = @"NSURLConnectionDidFinishLoading";
static NSString *const kFailureBlockKey = @"NSURLConnectionDidFailWithError";
static NSString *const kUploadBlockKey = @"NSURLConnectionDidSendData";
static NSString *const kDownloadBlockKey = @"NSURLConnectionDidRecieveData";

@implementation NSURLConnection (BlocksKit)

@dynamic delegate, bk_responseBlock, bk_failureBlock;

+ (void)load
{
	@autoreleasepool {
		[self bk_registerDynamicDelegate];
		[self bk_linkDelegateMethods:@{ @"bk_responseBlock": @"connection:didReceiveResponse:", @"bk_failureBlock": @"connection:didFailWithError:" }];
	}
}

#pragma mark Initializers

+ (NSURLConnection*)bk_connectionWithRequest:(NSURLRequest *)request
{
	return [[[self class] alloc] bk_initWithRequest:request];
}

+ (NSURLConnection *)bk_startConnectionWithRequest:(NSURLRequest *)request successHandler:(void (^)(NSURLConnection *, NSURLResponse *, NSData *))success failureHandler:(void (^)(NSURLConnection *, NSError *))failure
{
	Protocol *delegateProtocol = objc_getProtocol("NSURLConnectionDelegate");
	if (!delegateProtocol)
		delegateProtocol = @protocol(BKURLConnectionInformalDelegate);
	NSURLConnection *ret = [[self class] alloc];
	A2DynamicDelegate *dd = [ret bk_dynamicDelegateForProtocol:delegateProtocol];
	if (success)
		dd.handlers[kSuccessBlockKey] = [success copy];
	if (failure)
		[dd implementMethod:@selector(connection:didFailWithError:) withBlock:[failure copy]];
	return [ret initWithRequest:request delegate:dd startImmediately:YES];
}

- (instancetype)bk_initWithRequest:(NSURLRequest *)request
{
	return (self = [self bk_initWithRequest:request completionHandler:nil]);
}

- (instancetype)bk_initWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLConnection *, NSURLResponse *, NSData *))block
{
	Protocol *delegateProtocol = objc_getProtocol("NSURLConnectionDelegate");
	if (!delegateProtocol)
		delegateProtocol = @protocol(BKURLConnectionInformalDelegate);
	A2DynamicDelegate *dd = [self bk_dynamicDelegateForProtocol:delegateProtocol];
	if (block)
		dd.handlers[kSuccessBlockKey] = [block copy];
	return (self = [self initWithRequest:request delegate:dd startImmediately:NO]);
}

- (void)bk_startWithCompletionBlock:(void (^)(NSURLConnection *, NSURLResponse *, NSData *))block
{
	self.bk_successBlock = block;
	[self start];
}

#pragma mark Properties

- (void (^)(NSURLConnection *, NSURLResponse *, NSData *))bk_successBlock {
	return [self.bk_dynamicDelegate handlers][kSuccessBlockKey];
}

- (void)bk_setSuccessBlock:(void (^)(NSURLConnection *, NSURLResponse *, NSData *))block {
	if (block)
		[self.bk_dynamicDelegate handlers][kSuccessBlockKey] = [block copy];
	else
		[[self.bk_dynamicDelegate handlers] removeObjectForKey:kSuccessBlockKey];
}

- (void (^)(double))bk_uploadBlock {
	return [self.bk_dynamicDelegate handlers][kUploadBlockKey];
}

- (void)bk_setUploadBlock:(void (^)(double))block {
	if (block)
		[self.bk_dynamicDelegate handlers][kUploadBlockKey] = [block copy];
	else
		[[self.bk_dynamicDelegate handlers] removeObjectForKey:kUploadBlockKey];
}

- (void (^)(double))bk_downloadBlock {
	return [self.bk_dynamicDelegate handlers][kDownloadBlockKey];
}

- (void)bk_setDownloadBlock:(void (^)(double))block {
	if (block)
		[self.bk_dynamicDelegate handlers][kDownloadBlockKey] = [block copy];
	else
		[[self.bk_dynamicDelegate handlers] removeObjectForKey:kDownloadBlockKey];
}

@end

#pragma clang diagnostic pop
