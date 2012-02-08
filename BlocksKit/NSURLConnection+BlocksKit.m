//
//  NSURLConnection+BlocksKit.m
//  BlocksKit
//

#import "NSURLConnection+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"
#import "A2BlockDelegate+BlocksKit.h"
#import <objc/runtime.h>

#pragma mark Private

static char kResponseDataKey;
static char kResponseKey;
static char kResponseLengthKey;

@interface NSURLConnection (BlocksKitPrivate)
@property (nonatomic, retain, setter = bk_setResponseData:) NSMutableData *bk_responseData;
@property (nonatomic, retain, setter = bk_setResponse:) NSURLResponse *bk_response;
@property (nonatomic, setter = bk_setResponseLength:) NSUInteger bk_responseLength;
@end

@implementation NSURLConnection (BlocksKitPrivate)

- (NSMutableData *)bk_responseData {
	return [self associatedValueForKey:&kResponseDataKey];
}

- (void)bk_setResponseData:(NSMutableData *)responseData {
	[self associateValue:responseData withKey:&kResponseDataKey];
}

- (NSURLResponse *)bk_response {
	return [self associatedValueForKey:&kResponseKey];
}

- (void)bk_setResponse:(NSURLResponse *)response {
	return [self associateValue:response withKey:&kResponseKey];
}

- (NSUInteger)bk_responseLength {
	return [[self associatedValueForKey:&kResponseLengthKey] unsignedIntegerValue];
}

- (void)bk_setResponseLength:(NSUInteger)responseLength {
	NSNumber *value = [NSNumber numberWithUnsignedInteger:responseLength];
	return [self associateValue:value withKey:&kResponseLengthKey];
}

@end

#pragma mark - BKURLConnectionInformalDelegate - iOS 4.3 & Snow Leopard support

@protocol BKURLConnectionInformalDelegate <NSObject>
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
@end

@interface A2DynamicBKURLConnectionInformalDelegate : A2DynamicDelegate <BKURLConnectionInformalDelegate>

@end

@implementation A2DynamicBKURLConnectionInformalDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(connection:didReceiveResponse:)])
		[realDelegate connection:connection didReceiveResponse:response];
	
	connection.bk_responseLength = 0;
	[connection.bk_responseData setLength:0];
	
	connection.bk_response = response;
	
	void (^block)(NSURLConnection *, NSURLResponse *) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(connection, response);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	connection.bk_responseLength += data.length;
	
	void (^block)(CGFloat) = connection.downloadBlock;
	if (block && connection.bk_response && connection.bk_response.expectedContentLength != NSURLResponseUnknownLength)
		block((CGFloat)connection.bk_responseLength / (CGFloat)connection.bk_response.expectedContentLength);
	
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

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)])
		[realDelegate connection:connection didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
	
	void (^block)(CGFloat) = connection.uploadBlock;
	if (block)
		block((CGFloat)totalBytesWritten/(CGFloat)totalBytesExpectedToWrite);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(connectionDidFinishLoading:)])
		[realDelegate connectionDidFinishLoading:connection];
	
	if (!connection.bk_responseData.length)
		connection.bk_responseData = nil;
	
	void(^block)(NSURLConnection *, NSURLResponse *, NSData *) = connection.successBlock;
	if (block)
		block(connection, connection.bk_response, connection.bk_responseData);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(connection:didFailWithError:)])
		[realDelegate connection:connection didFailWithError:error];
	
	connection.bk_responseLength = 0;
	[connection.bk_responseData setLength:0];
	
	void (^block)(NSURLConnection *, NSError *) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(connection, error);
}

@end

#pragma mark - NSURLConnectionDelegate - iOS 5.0 & Lion support

#ifdef NSURLConnectionDataDelegate
@interface A2DynamicNSURLConnectionDelegate : A2DynamicDelegate <NSURLConnectionDataDelegate>
#else
@interface A2DynamicNSURLConnectionDelegate : A2DynamicDelegate <NSURLConnectionDelegate>
#endif

@end

@implementation A2DynamicNSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(connection:didReceiveResponse:)])
		[realDelegate connection:connection didReceiveResponse:response];
	
	connection.bk_responseLength = 0;
	
	if (connection.bk_responseData)
		[connection.bk_responseData setLength:0];
	
	connection.bk_response = response;
	
	void (^block)(NSURLConnection *, NSURLResponse *) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(connection, response);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	connection.bk_responseLength += data.length;
	
	void (^block)(CGFloat) = connection.downloadBlock;
	if (block && connection.bk_response && connection.bk_response.expectedContentLength != NSURLResponseUnknownLength)
		block((CGFloat)connection.bk_responseLength / (CGFloat)connection.bk_response.expectedContentLength);
	
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

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)])
		[realDelegate connection:connection didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
	
	void (^block)(CGFloat) = connection.uploadBlock;
	if (block)
		block((CGFloat)totalBytesWritten/(CGFloat)totalBytesExpectedToWrite);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(connectionDidFinishLoading:)])
		[realDelegate connectionDidFinishLoading:connection];
	
	if (!connection.bk_responseData.length)
		connection.bk_responseData = nil;
	
	void(^block)(NSURLConnection *, NSURLResponse *, NSData *) = connection.successBlock;
	if (block)
		block(connection, connection.bk_response, connection.bk_responseData);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(connection:didFailWithError:)])
		[realDelegate connection:connection didFailWithError:error];
	
	connection.bk_responseLength = 0;
	[connection.bk_responseData setLength:0];
	
	void (^block)(NSURLConnection *, NSError *) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(connection, error);
}

@end

#pragma mark - Category

static NSString *const kSuccessBlockKey = @"NSURLConnectionDidFinishLoading";
static NSString *const kUploadBlockKey = @"NSURLConnectionDidSendData";
static NSString *const kDownloadBlockKey = @"NSURLConnectionDidRecieveData";

@implementation NSURLConnection (BlocksKit)

@dynamic delegate, responseBlock, failureBlock;

+ (void)load {
	@autoreleasepool {
		[self registerDynamicDelegate];
		[self linkCategoryBlockProperty:@"responseBlock" withDelegateMethod:@selector(connection:didReceiveResponse:)];
		[self linkCategoryBlockProperty:@"failureBlock" withDelegateMethod:@selector(connection:didFailWithError:)];
	}
}

#pragma mark Initializers

+ (NSURLConnection*)connectionWithRequest:(NSURLRequest *)request {
	return [[[[self class] alloc] initWithRequest:request] autorelease];
}

+ (NSURLConnection *)startConnectionWithRequest:(NSURLRequest *)request successHandler:(void(^)(NSURLConnection *, NSURLResponse *, NSData *))success failureHandler:(void(^)(NSURLConnection *, NSError *))failure {
	NSURLConnection *connection = [[[self class] alloc] initWithRequest:request];
	connection.successBlock = success;
	connection.failureBlock = failure;
	[connection start];
	return [connection autorelease];
}

- (id)initWithRequest:(NSURLRequest *)request {
	return [self initWithRequest:request completionHandler:NULL];
}

- (id)initWithRequest:(NSURLRequest *)request completionHandler:(void(^)(NSURLConnection *, NSURLResponse *, NSData *))block {
	Protocol *delegateProtocol = objc_getProtocol("NSURLConnectionDelegate");
	if (!delegateProtocol)
		delegateProtocol = @protocol(BKURLConnectionInformalDelegate);
	if ((self = [self initWithRequest:request delegate:[self dynamicDelegateForProtocol:delegateProtocol] startImmediately:NO]))
		self.successBlock = block;
	return self;
}

- (void)startWithCompletionBlock:(void(^)(NSURLConnection *, NSURLResponse *, NSData *))block {
	self.successBlock = block;
	[self start];
}

#pragma mark Properties

- (void(^)(NSURLConnection *, NSURLResponse *, NSData *))successBlock {
	return [[self.dynamicDelegate handlers] objectForKey:kSuccessBlockKey];
}

- (void)setSuccessBlock:(void(^)(NSURLConnection *, NSURLResponse *, NSData *))block {
	if (block)
		[[self.dynamicDelegate handlers] setObject:block forKey:kSuccessBlockKey];
	else
		[[self.dynamicDelegate handlers] removeObjectForKey:kSuccessBlockKey];
	
}

- (void(^)(CGFloat))uploadBlock {
	return [[self.dynamicDelegate handlers] objectForKey:kUploadBlockKey];
}

- (void)setUploadBlock:(void(^)(CGFloat))block {
	if (block)
		[[self.dynamicDelegate handlers] setObject:block forKey:kUploadBlockKey];
	else
		[[self.dynamicDelegate handlers] removeObjectForKey:kUploadBlockKey];
}

- (void(^)(CGFloat))downloadBlock {
	return [[self.dynamicDelegate handlers] objectForKey:kDownloadBlockKey];
}

- (void)setDownloadBlock:(void(^)(CGFloat))block {
	if (block)
		[[self.dynamicDelegate handlers] setObject:block forKey:kDownloadBlockKey];
	else
		[[self.dynamicDelegate handlers] removeObjectForKey:kDownloadBlockKey];
}

@end