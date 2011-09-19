//
//  NSURLConnection+BlocksKit.m
//  BlocksKit
//

#import "NSURLConnection+BlocksKit.h"
#import "NSObject+BlocksKit.h"
#import "BKDelegateProxy.h"

static char *kResponseDataKey = "NSURLConnectionResponseData";
static char *kIsBlockBackedKey = "NSURLConnectionIsBlockBacked";
static char *kResponseKey = "NSURLConnectionResponse";
static char *kResponseLengthKey = "NSURLConnectionResponseLength";
static char *kDidReceiveResponseHandlerKey = "NSURLConnectionDidReceiveResponse";
static char *kDidFailWithErrorHandlerKey = "NSURLConnectionDidFail";
static char *kDidFinishLoadingHandlerKey = "NSURLConnectionDidFinish";
static char *kUploadProgressHandlerKey = "NSURLConnectionUploadProgress";
static char *kDownloadProgressHandlerKey = "NSURLConnectionDownload";

#pragma mark Private

@interface NSURLConnection (BlocksKitPrivate)
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURLResponse *response;
@property (nonatomic) NSUInteger responseLength;
@property (nonatomic, getter = isBlockBased) BOOL blockBased;
@end

#pragma mark Delegate proxy

@interface BKURLConnectionDelegate : BKDelegateProxy
@end

@implementation BKURLConnectionDelegate

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
    
    connection.responseLength = 0;
    
    if (connection.responseData)
        [connection.responseData setLength:0];
    
    connection.response = response;
    
    if (connection.didReceiveResponseHandler)
        connection.didReceiveResponseHandler(response);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    connection.responseLength += data.length;
    
    if (connection.downloadProgressHandler && connection.response && [connection.response expectedContentLength] != NSURLResponseUnknownLength)
        connection.downloadProgressHandler(connection.responseLength/connection.response.expectedContentLength);

    if (connection.delegate && [connection.delegate respondsToSelector:@selector(connection:didReceiveData:)]) {
        [connection.delegate connection:connection didReceiveData:data];
        return;
    }
    
    NSMutableData *responseData = connection.responseData;
    
    if (!responseData) {
        responseData = [NSMutableData data];
        connection.responseData = responseData;
    }
    
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    if (connection.delegate && [connection.delegate respondsToSelector:@selector(connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)])
        [connection.delegate connection:connection didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    
    if (connection.uploadProgressHandler)
        connection.uploadProgressHandler(totalBytesWritten/totalBytesExpectedToWrite);
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    if (connection.delegate && [connection.delegate respondsToSelector:@selector(connection:willSendRequest:redirectResponse:)])
        return [connection.delegate connection:connection willSendRequest:request redirectResponse:redirectResponse];
    
    return request;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection.delegate && [connection.delegate respondsToSelector:@selector(connection:didFailWithError:)])
        [connection.delegate connection:connection didFailWithError:error];
    
    if (connection.didFailWithErrorHandler)
        connection.didFailWithErrorHandler(error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection.delegate && [connection.delegate respondsToSelector:@selector(connectionDidFinishLoading:)])
        [connection.delegate connectionDidFinishLoading:connection];
    
    if (connection.responseData && !connection.responseData.length)
        connection.responseData = nil;
    
    if (connection.didFinishLoadingHandler)
        connection.didFinishLoadingHandler(connection.response, connection.responseData);
}

@end

#pragma mark Category

@implementation NSURLConnection (BlocksKit)

#pragma mark Initializers

+ (NSURLConnection*)connectionWithRequest:(NSURLRequest *)request {
    return BK_AUTORELEASE([[[self class] alloc] initWithRequest:request]);
}

- (id)initWithRequest:(NSURLRequest *)request {
    if ((self = [self initWithRequest:request delegate:[BKURLConnectionDelegate shared] startImmediately:NO])) {
        self.blockBased = YES;
    }
    return self;
}

- (id)initWithRequest:(NSURLRequest *)request completionHandler:(BKConnectionFinishBlock)block {
    return [self initWithRequest:request startImmediately:NO completionHandler:block];
}

- (id)initWithRequest:(NSURLRequest *)request startImmediately:(BOOL)startImmediately completionHandler:(BKConnectionFinishBlock)block {
    if (block && (self = [self initWithRequest:request delegate:[BKURLConnectionDelegate shared] startImmediately:startImmediately])) {
        self.didFinishLoadingHandler = block;
        self.blockBased = YES;
    }
    return self;
}

#pragma mark Actions

- (void)startWithCompletionBlock:(BKConnectionFinishBlock)block {
    if (!self.isBlockBased)
        return;
    
    self.didFinishLoadingHandler = block;
    [self start];
}

#pragma mark Private

- (BOOL)isBlockBased {
    NSNumber *value = [self associatedValueForKey:kIsBlockBackedKey];
    NSAssert(value && [value boolValue], @"Block-backed NSURLConnection methods have been sent to this normal NSURLConnection:  %@", self);
    return [value boolValue];
}

- (void)setBlockBased:(BOOL)blockBased {
    [self associateValue:[NSNumber numberWithBool:blockBased] withKey:kIsBlockBackedKey];
}

- (NSMutableData *)responseData {
    return [self associatedValueForKey:kResponseDataKey];
}

- (void)setResponseData:(NSMutableData *)responseData {
    if (!self.isBlockBased)
        return;
    
    [self associateValue:responseData withKey:kResponseDataKey];
}

- (NSURLResponse *)response {
    return [self associatedValueForKey:kResponseKey];
}

- (void)setResponse:(NSURLResponse *)response {
    if (!self.isBlockBased)
        return;
    
    return [self associateValue:response withKey:kResponseKey];
}

- (NSUInteger)responseLength {
    return [[self associatedValueForKey:kResponseLengthKey] unsignedIntegerValue];
}

- (void)setResponseLength:(NSUInteger)responseLength {
    if (!self.isBlockBased)
        return;
    
    NSNumber *value = [NSNumber numberWithUnsignedInteger:responseLength];
    return [self associateValue:value withKey:kResponseLengthKey];
}

#pragma mark Properties

- (id)delegate {
    return [self associatedValueForKey:kBKDelegateKey];
}

- (void)setDelegate:(id)delegate {
    if (!self.isBlockBased)
        return;
    
    if (delegate && delegate != self && delegate != [BKURLConnectionDelegate shared] && ![delegate isKindOfClass:[self class]])
        [self weaklyAssociateValue:delegate withKey:kBKDelegateKey];
}

- (BKResponseBlock)didReceiveResponseHandler {
    return [self associatedValueForKey:kDidReceiveResponseHandlerKey];
}

- (void)setDidReceiveResponseHandler:(BKResponseBlock)didReceiveResponseHandler {
    if (!self.isBlockBased)
        return;
    
    [self associateCopyOfValue:didReceiveResponseHandler withKey:kDidReceiveResponseHandlerKey];
}

- (BKErrorBlock)didFailWithErrorHandler {
    return [self associatedValueForKey:kDidFailWithErrorHandlerKey];
}

- (void)setDidFailWithErrorHandler:(BKErrorBlock)didFailWithErrorHandler {
    if (!self.isBlockBased)
        return;
    
    [self associateCopyOfValue:didFailWithErrorHandler withKey:kDidFailWithErrorHandlerKey];
}

- (BKConnectionFinishBlock)didFinishLoadingHandler {
    return [self associatedValueForKey:kDidFinishLoadingHandlerKey];
}

- (void)setDidFinishLoadingHandler:(BKConnectionFinishBlock)didFinishLoadingHandler {
    if (!self.isBlockBased)
        return;
    
    [self associateCopyOfValue:didFinishLoadingHandler withKey:kDidFinishLoadingHandlerKey];
}

- (BKProgressBlock)uploadProgressHandler {
    return [self associatedValueForKey:kUploadProgressHandlerKey];
}

- (void)setUploadProgressHandler:(BKProgressBlock)uploadProgressHandler {
    if (!self.isBlockBased)
        return;
    
    [self associateCopyOfValue:uploadProgressHandler withKey:kUploadProgressHandlerKey];
}

- (BKProgressBlock)downloadProgressHandler {
    return [self associatedValueForKey:kDownloadProgressHandlerKey];
}

- (void)setDownloadProgressHandler:(BKProgressBlock)downloadProgressHandler {
    if (!self.isBlockBased)
        return;
    
    [self associateCopyOfValue:downloadProgressHandler withKey:kDownloadProgressHandlerKey];
}

@end
