//
//  NSURLConnection+BlocksKit.m
//  BlocksKit
//

#import "NSURLConnection+BlocksKit.h"
#import "NSObject+BlocksKit.h"
#import "BKDelegate.h"

static char *kDelegateKey = "NSURLConnectionDelegate";
static char *kResponseDataKey = "NSURLConnectionResponseData";
static char *kResponseKey = "NSURLConnectionResponse";
static char *kResponseLengthKey = "NSURLConnectionResponseLength";
static char *kResponseBlockKey = "NSURLConnectionDidReceiveResponse";
static char *kFailureBlockKey = "NSURLConnectionDidFail";
static char *kSuccessBlockKey = "NSURLConnectionDidFinish";
static char *kUploadBlockKey = "NSURLConnectionUploadProgress";
static char *kDownloadBlockKey = "NSURLConnectionDownloadProgress";

#pragma mark Private

@interface NSURLConnection (BlocksKitPrivate)
@property (nonatomic, retain) NSMutableData *bk_responseData;
@property (nonatomic, retain) NSURLResponse *bk_response;
@property (nonatomic) NSUInteger bk_responseLength;
@end

#pragma mark Delegate proxy

@interface BKURLConnectionDelegate : BKDelegate

@end

@implementation BKURLConnectionDelegate

+ (Class)targetClass {
    return [NSURLConnection class];
}

#pragma mark Authentication delegate

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if (connection.delegate && [connection.delegate respondsToSelector:@selector(connection:willSendRequestForAuthenticationChallenge:)])
        [connection.delegate connection:connection willSendRequestForAuthenticationChallenge:challenge];
}

- (BOOL)connection:(NSURLConnection*)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    if (connection.delegate && [connection.delegate respondsToSelector:@selector(connection:canAuthenticateAgainstProtectionSpace:)])
        return [connection.delegate connection:connection canAuthenticateAgainstProtectionSpace:protectionSpace];
    
    return NO;
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if (connection.delegate != nil && [connection.delegate respondsToSelector:@selector(connection:didCancelAuthenticationChallenge:)])
        [connection.delegate connection:connection didCancelAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if (connection.delegate && [connection.delegate respondsToSelector:@selector(connection:didReceiveAuthenticationChallenge:)])
        [connection.delegate connection:connection didReceiveAuthenticationChallenge:challenge];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    if (connection.delegate && [connection.delegate respondsToSelector:@selector(connectionShouldUseCredentialStorage:)])
        return [connection.delegate connectionShouldUseCredentialStorage:connection];

    return YES;   
}

#pragma mark Connection delegate

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    if (connection.delegate && [connection.delegate respondsToSelector:@selector(connection:willCacheResponse:)])
        return [connection.delegate connection:connection willCacheResponse:cachedResponse];
    
    return cachedResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection.delegate && [connection.delegate respondsToSelector:@selector(connection:didReceiveResponse:)])
        [connection.delegate connection:connection didReceiveResponse:response];
    
    connection.bk_responseLength = 0;
    
    if (connection.bk_responseData)
        [connection.bk_responseData setLength:0];
    
    connection.bk_response = response;
    
    BKResponseBlock responseBlock = connection.responseBlock;
    if (responseBlock)
        responseBlock(response);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    connection.bk_responseLength += data.length;
    
    BKProgressBlock block = connection.downloadBlock;
    if (block && connection.bk_response && connection.bk_response.expectedContentLength != NSURLResponseUnknownLength)
        block(connection.bk_responseLength / connection.bk_response.expectedContentLength);

    if (connection.delegate && [connection.delegate respondsToSelector:@selector(connection:didReceiveData:)]) {
        [connection.delegate connection:connection didReceiveData:data];
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
    if (connection.delegate && [connection.delegate respondsToSelector:@selector(connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)])
        [connection.delegate connection:connection didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    
    BKProgressBlock block = connection.uploadBlock;
    if (block)
        block(totalBytesWritten/totalBytesExpectedToWrite);
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    if (connection.delegate && [connection.delegate respondsToSelector:@selector(connection:willSendRequest:redirectResponse:)])
        return [connection.delegate connection:connection willSendRequest:request redirectResponse:redirectResponse];
    
    return request;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection.delegate && [connection.delegate respondsToSelector:@selector(connection:didFailWithError:)])
        [connection.delegate connection:connection didFailWithError:error];
    
    BKErrorBlock block = connection.failureBlock;
    if (block)
        block(error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection.delegate && [connection.delegate respondsToSelector:@selector(connectionDidFinishLoading:)])
        [connection.delegate connectionDidFinishLoading:connection];
    
    if (!connection.bk_responseData.length)
        connection.bk_responseData = nil;
    
    BKConnectionFinishBlock block = connection.successBlock;
    if (block)
        block(connection.bk_response, connection.bk_responseData);
}

@end

#pragma mark Category

@implementation NSURLConnection (BlocksKit)

#pragma mark Initializers

+ (NSURLConnection*)connectionWithRequest:(NSURLRequest *)request {
    return BK_AUTORELEASE([[[self class] alloc] initWithRequest:request]);
}

+ (NSURLConnection *)startConnectionWithRequest:(NSURLRequest *)request successHandler:(BKConnectionFinishBlock)success failureHandler:(BKErrorBlock)failure {
    NSURLConnection *connection = [[[self class] alloc] initWithRequest:request];
    connection.successBlock = success;
    connection.failureBlock = failure;
    [connection start];
    return BK_AUTORELEASE(connection);
}

- (id)initWithRequest:(NSURLRequest *)request {
    return [self initWithRequest:request completionHandler:NULL];
}

- (id)initWithRequest:(NSURLRequest *)request completionHandler:(BKConnectionFinishBlock)block {
    if ((self = [self initWithRequest:request delegate:[BKURLConnectionDelegate shared] startImmediately:NO]))
        self.successBlock = block;
    return self;
}

#pragma mark Actions

- (void)startWithCompletionBlock:(BKConnectionFinishBlock)block {
    self.successBlock = block;
    [self start];
}

#pragma mark Private

- (NSMutableData *)bk_responseData {
    return [self associatedValueForKey:kResponseDataKey];
}

- (void)setBk_responseData:(NSMutableData *)responseData {
    [self associateValue:responseData withKey:kResponseDataKey];
}

- (NSURLResponse *)bk_response {
    return [self associatedValueForKey:kResponseKey];
}

- (void)setBk_response:(NSURLResponse *)response {
    return [self associateValue:response withKey:kResponseKey];
}

- (NSUInteger)bk_responseLength {
    return [[self associatedValueForKey:kResponseLengthKey] unsignedIntegerValue];
}

- (void)setBk_responseLength:(NSUInteger)responseLength {
    NSNumber *value = [NSNumber numberWithUnsignedInteger:responseLength];
    return [self associateValue:value withKey:kResponseLengthKey];
}

#pragma mark Properties

- (id)delegate {
    return [self associatedValueForKey:kDelegateKey];
}

- (void)setDelegate:(id)delegate {
    if (delegate && delegate != self && delegate != [BKURLConnectionDelegate shared] && ![delegate isKindOfClass:[self class]])
        [self weaklyAssociateValue:delegate withKey:kDelegateKey];
}

- (BKResponseBlock)responseBlock {
    BKResponseBlock block = [self associatedValueForKey:kResponseBlockKey];
    return BK_AUTORELEASE([block copy]);
}

- (void)setResponseBlock:(BKResponseBlock)block {
    [self associateCopyOfValue:block withKey:kResponseBlockKey];
}

- (BKErrorBlock)failureBlock {
    BKErrorBlock block = [self associatedValueForKey:kFailureBlockKey];
    return BK_AUTORELEASE([block copy]);
}

- (void)setFailureBlock:(BKErrorBlock)block {
    [self associateCopyOfValue:block withKey:kFailureBlockKey];
}

- (BKConnectionFinishBlock)successBlock {
    BKConnectionFinishBlock block = [self associatedValueForKey:kSuccessBlockKey];
    return BK_AUTORELEASE([block copy]);
}

- (void)setSuccessBlock:(BKConnectionFinishBlock)block {
    [self associateCopyOfValue:block withKey:kSuccessBlockKey];
}

- (BKProgressBlock)uploadBlock {
    BKProgressBlock block = [self associatedValueForKey:kUploadBlockKey];
    return BK_AUTORELEASE([block copy]);
}

- (void)setUploadBlock:(BKProgressBlock)block {
    [self associateCopyOfValue:block withKey:kUploadBlockKey];
}

- (BKProgressBlock)downloadBlock {
    BKProgressBlock block = [self associatedValueForKey:kDownloadBlockKey];
    return BK_AUTORELEASE([block copy]);
}

- (void)setDownloadBlock:(BKProgressBlock)block {
    [self associateCopyOfValue:block withKey:kDownloadBlockKey];
}

#pragma mark - Deprecated

- (BKResponseBlock)didReceiveResponseHandler {
    return [self responseBlock];
}

- (void)setDidReceiveResponseHandler:(BKResponseBlock)block {
    [self setResponseBlock:block];
}

- (BKErrorBlock)didFailWithErrorHandler {
    return [self failureBlock];
}

- (void)setDidFailWithErrorHandler:(BKErrorBlock)block {
    [self setFailureBlock:block];
}

- (BKConnectionFinishBlock)didFinishLoadingHandler {
    return [self successBlock];
}

- (void)setDidFinishLoadingHandler:(BKConnectionFinishBlock)block {
    [self setSuccessBlock:block];
}

- (BKProgressBlock)uploadProgressHandler {
    return [self uploadBlock];
}

- (void)setUploadProgressHandler:(BKProgressBlock)block {
    [self setUploadBlock:block];
}

- (BKProgressBlock)downloadProgressHandler {
    return [self downloadBlock];
}

- (void)setDownloadProgressHandler:(BKProgressBlock)block {
    [self setDownloadBlock:block];
}

@end
