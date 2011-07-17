//
//  NSURLConnection+BlocksKit.m
//  BlocksKit
//

#import "NSURLConnection+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"

static char *kDelegateKey = "NSURLConnectionDelegate";
static char *kResponseDataKey = "NSURLConnectionResponseData";
static char *kResponseKey = "NSURLConnectionResponse";
static char *kCanAuthenticateAgainstProtectionSpaceHandlerKey = "NSURLConnectionCanAuthenticate";
static char *kDidCancelAuthenticationChallengeHandlerKey = "NSURLConnectionDidCancelAuthentication";
static char *kDidReceiveAuthenticationChallengeHandlerKey = "NSURLConnectionDidReceiveAuthentication";
static char *kShouldUseCredentialStorageHandlerKey = "NSURLConnectionShouldUseCredentialStorage";
static char *kWillCacheResponseHandlerKey = "NSURLConnectionWillCacheResponse";
static char *kDidReceiveResponseHandlerKey = "NSURLConnectionDidReceiveResponse";
static char *kdidReceiveDataHandlerKey = "NSURLConnectionDidReceiveData";
static char *kSendBodyDataHandlerKey = "NSURLConnectionSendBodyData";
static char *kWillSendRequestRedirectResponseHandlerKey = "NSURLConnectionWillSendRequestRedirect";
static char *kDidFailWithErrorHandlerKey = "NSURLConnectionDidFail";
static char *kDidFinishLoadingHandlerKey = "NSURLConnectionDidFinish";
static char *kUploadProgressHandlerKey = "NSURLConnectionUploadProgress";
static char *kDownloadProgressHandlerKey = "NSURLConnectionDownload";

#pragma mark 

@interface BKURLConnectionDelegateProxy : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
+ (id)shared;
@end

@implementation BKURLConnectionDelegateProxy

+ (id)shared {
    static BKURLConnectionDelegateProxy *proxyDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        proxyDelegate = [[BKURLConnectionDelegateProxy alloc] init];
    });
    
    return proxyDelegate;
}

#pragma mark Authentication delegate

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if (connection.delegate && [connection.delegate respondsToSelector:@selector(connection:willSendRequestForAuthenticationChallenge:)])
        [connection.delegate connection:connection willSendRequestForAuthenticationChallenge:challenge];
}

- (BOOL)connection:(NSURLConnection*)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    if (connection.delegate && [connection.delegate respondsToSelector:@selector(connection:canAuthenticateAgainstProtectionSpace:)])
        return [connection.delegate connection:connection canAuthenticateAgainstProtectionSpace:protectionSpace];

    if (connection.canAuthenticateAgainstProtectionSpaceHandler)
        return connection.canAuthenticateAgainstProtectionSpaceHandler(protectionSpace);

    return NO;
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if (connection.delegate != nil && [connection.delegate respondsToSelector:@selector(connection:didCancelAuthenticationChallenge:)])
        [connection.delegate connection:connection didCancelAuthenticationChallenge:challenge];

    if (connection.didCancelAuthenticationChallengeHandler)
        connection.didCancelAuthenticationChallengeHandler(challenge);
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if (connection.delegate && [connection.delegate respondsToSelector:@selector(connection:didReceiveAuthenticationChallenge:)])
        [connection.delegate connection:connection didReceiveAuthenticationChallenge:challenge];

    if (connection.didReceiveAuthenticationChallengeHandler)
        connection.didReceiveAuthenticationChallengeHandler(challenge);
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    if (connection.delegate && [connection.delegate respondsToSelector:@selector(connectionShouldUseCredentialStorage:)])
        return [connection.delegate connectionShouldUseCredentialStorage:connection];

    if (connection.shouldUseCredentialStorageHandler)
        return connection.shouldUseCredentialStorageHandler();

    return NO;   
}

#pragma mark Connection delegate

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    if (connection.delegate && [connection.delegate respondsToSelector:@selector(connection:willCacheResponse:)])
        return [connection.delegate connection:connection willCacheResponse:cachedResponse];
    
    if (connection.willCacheResponseHandler)
        return connection.willCacheResponseHandler(cachedResponse);
    
    return cachedResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection.delegate && [connection.delegate respondsToSelector:@selector(connection:didReceiveResponse:)])
        [connection.delegate connection:connection didReceiveResponse:response];
    
    if (connection.responseData)
        [connection.responseData setLength:0];
    
    connection.response = response;
    
    if (connection.didReceiveResponseHandler)
        connection.didReceiveResponseHandler(response);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection.delegate && [connection.delegate respondsToSelector:@selector(connection:didReceiveData:)])
        [connection.delegate connection:connection didReceiveData:data];
    
    NSMutableData *responseData = connection.responseData;
    
    if (!responseData) {
        responseData = [NSMutableData data];
        connection.responseData = responseData;
    }
    
    [responseData appendData:data];
    
    if (connection.didReceiveDataHandler)
        connection.didReceiveDataHandler(data);
    
    if (connection.downloadProgressHandler && connection.response && [connection.response expectedContentLength] != NSURLResponseUnknownLength)
        connection.downloadProgressHandler(responseData.length/connection.response.expectedContentLength);
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    if (connection.delegate && [connection.delegate respondsToSelector:@selector(connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)])
        [connection.delegate connection:connection didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    
    if (connection.sendBodyDataHandler)
        connection.sendBodyDataHandler(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    
    if (connection.uploadProgressHandler)
        connection.uploadProgressHandler(totalBytesWritten/totalBytesExpectedToWrite);
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    if (connection.delegate && [connection.delegate respondsToSelector:@selector(connection:willSendRequest:redirectResponse:)])
        return [connection.delegate connection:connection willSendRequest:request redirectResponse:redirectResponse];
    
    if (connection.willSendRequestRedirectResponseHandler)
        return connection.willSendRequestRedirectResponseHandler(request, redirectResponse);
    
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
    
    if (connection.didFinishLoadingHandler)
        connection.didFinishLoadingHandler(connection.response, connection.responseData);
}

@end

#pragma mark Category

@interface NSURLConnection (BlocksKitPrivate)
- (id)bk_initWithRequest:(NSURLRequest *)request delegate:(id)aDelegate;
- (id)bk_initWithRequest:(NSURLRequest *)request delegate:(id)aDelegate startImmediately:(BOOL)startImmediately;
@end

@implementation NSURLConnection (BlocksKit)

#pragma mark Initializers

+ (void)load {
    Class myClass = [self class];
    
    Method originalInitWithRequestDelegateMethod = class_getInstanceMethod(myClass, @selector(initWithRequest:delegate:));
    Method categoryInitWithRequestDelegateMethod = class_getInstanceMethod(myClass, @selector(bk_initWithRequest:delegate:));
    method_exchangeImplementations(originalInitWithRequestDelegateMethod, categoryInitWithRequestDelegateMethod);
    
    Method originalInitWithRequestDelegateStartImmediatelyMethod = class_getInstanceMethod(myClass, @selector(initWithRequest:delegate:startImmediately:));
    Method categoryInitWithRequestDelegateStartImmediatelyMethod = class_getInstanceMethod(myClass, @selector(bk_initWithRequest:delegate:startImmediately:));
    method_exchangeImplementations(originalInitWithRequestDelegateStartImmediatelyMethod, categoryInitWithRequestDelegateStartImmediatelyMethod);    
}

+ (NSURLConnection*)connectionWithRequest:(NSURLRequest *)request delegate:(id)delegate {
    return BK_AUTORELEASE([[self alloc] initWithRequest:request delegate:delegate startImmediately:NO]);
}

+ (NSURLConnection*)connectionWithRequest:(NSURLRequest *)request {
    return [[self alloc] initWithRequest:request delegate:nil startImmediately:NO];
}

// new method
- (id)initWithRequest:(NSURLRequest *)request {
    return [self initWithRequest:request delegate:nil startImmediately:NO];
}

// new method
- (id)initWithRequest:(NSURLRequest *)request startImmediately:(BOOL)startImmediately {
    return [self initWithRequest:request delegate:nil startImmediately:startImmediately];
}

// swizzled method
- (id)bk_initWithRequest:(NSURLRequest *)request delegate:(id)aDelegate {
    return [self initWithRequest:request delegate:aDelegate startImmediately:NO];
}

// swizzled method
- (id)bk_initWithRequest:(NSURLRequest *)request delegate:(id)aDelegate startImmediately:(BOOL)startImmediately {
    if ([self bk_initWithRequest:request delegate:[BKURLConnectionDelegateProxy shared] startImmediately:startImmediately]) {
        if (aDelegate && [aDelegate isKindOfClass:[self class]]) {
            self.delegate = aDelegate;
        }          
    }
    return self;
}

#pragma mark Properties

- (id)delegate {
    return [self associatedValueForKey:kDelegateKey];
}

- (void)setDelegate:(id)delegate {
    [self weaklyAssociateValue:delegate withKey:kDelegateKey];
}

- (NSMutableData *)responseData {
    return [self associatedValueForKey:kResponseDataKey];
}

- (void)setResponseData:(NSMutableData *)responseData {
    [self associateValue:responseData withKey:kResponseDataKey];
}

- (NSURLResponse *)response {
    return [self associatedValueForKey:kResponseKey];
}
- (void)setResponse:(NSURLResponse *)response {
    return [self associateValue:response withKey:kResponseKey];
}

- (BKCanAuthenticateBlock)canAuthenticateAgainstProtectionSpaceHandler {
    return [self associatedValueForKey:kCanAuthenticateAgainstProtectionSpaceHandlerKey];
}

- (void)setCanAuthenticateAgainstProtectionSpaceHandler:(BKCanAuthenticateBlock)canAuthenticateAgainstProtectionSpaceHandler {
    [self associateCopyOfValue:canAuthenticateAgainstProtectionSpaceHandler withKey:kCanAuthenticateAgainstProtectionSpaceHandlerKey];
}

- (BKChallengeBlock)didCancelAuthenticationChallengeHandler {
    return [self associatedValueForKey:kDidCancelAuthenticationChallengeHandlerKey];
}

- (void)setDidCancelAuthenticationChallengeHandler:(BKChallengeBlock)didCancelAuthenticationChallengeHandler {
    [self associateCopyOfValue:didCancelAuthenticationChallengeHandler withKey:kDidCancelAuthenticationChallengeHandlerKey];
}

- (BKChallengeBlock)didReceiveAuthenticationChallengeHandler {
    return [self associatedValueForKey:kDidReceiveAuthenticationChallengeHandlerKey];
}

- (void)setDidReceiveAuthenticationChallengeHandler:(BKChallengeBlock)didReceiveAuthenticationChallengeHandler {
    [self associateCopyOfValue:didReceiveAuthenticationChallengeHandler withKey:kDidReceiveAuthenticationChallengeHandlerKey];
}

- (BKAnswerBlock)shouldUseCredentialStorageHandler {
    return [self associatedValueForKey:kShouldUseCredentialStorageHandlerKey];
}

- (void)setShouldUseCredentialStorageHandler:(BKAnswerBlock)shouldUseCredentialStorageHandler {
    [self associateCopyOfValue:shouldUseCredentialStorageHandler withKey:kShouldUseCredentialStorageHandlerKey];
}

- (BKCachedResponseBlock)willCacheResponseHandler {
    return [self associatedValueForKey:kWillCacheResponseHandlerKey];
}

- (void)setWillCacheResponseHandler:(BKCachedResponseBlock)willCacheResponseHandler {
    [self associateCopyOfValue:willCacheResponseHandler withKey:kWillCacheResponseHandlerKey];
}

- (BKResponseBlock)didReceiveResponseHandler {
    return [self associatedValueForKey:kDidReceiveResponseHandlerKey];
}

- (void)setDidReceiveResponseHandler:(BKResponseBlock)didReceiveResponseHandler {
    [self associateCopyOfValue:didReceiveResponseHandler withKey:kDidReceiveResponseHandlerKey];
}

- (BKDataBlock)didReceiveDataHandler {
    return [self associatedValueForKey:kdidReceiveDataHandlerKey];
}

- (void)setDidReceiveDataHandler:(BKDataBlock)didReceiveDataHandler {
    [self associateCopyOfValue:didReceiveDataHandler withKey:kdidReceiveDataHandlerKey];
}

- (BKDataSentBlock)sendBodyDataHandler {
    return [self associatedValueForKey:kSendBodyDataHandlerKey];
}

- (void)setSendBodyDataHandler:(BKDataSentBlock)sendBodyDataHandler {
    [self associateCopyOfValue:sendBodyDataHandler withKey:kSendBodyDataHandlerKey];
}

- (BKRedirectBlock)willSendRequestRedirectResponseHandler {
    return [self associatedValueForKey:kWillSendRequestRedirectResponseHandlerKey];
}

- (void)setWillSendRequestRedirectResponseHandler:(BKRedirectBlock)willSendRequestRedirectResponseHandler {
    [self associateCopyOfValue:willSendRequestRedirectResponseHandler withKey:kWillSendRequestRedirectResponseHandlerKey];
}

- (BKErrorBlock)didFailWithErrorHandler {
    return [self associatedValueForKey:kDidFailWithErrorHandlerKey];
}

- (void)setDidFailWithErrorHandler:(BKErrorBlock)didFailWithErrorHandler {
    [self associateCopyOfValue:didFailWithErrorHandler withKey:kDidFailWithErrorHandlerKey];
}

- (BKConnectionFinishBlock)didFinishLoadingHandler {
    return [self associatedValueForKey:kDidFinishLoadingHandlerKey];
}

- (void)setDidFinishLoadingHandler:(BKConnectionFinishBlock)didFinishLoadingHandler {
    [self associateCopyOfValue:didFinishLoadingHandler withKey:kDidFinishLoadingHandlerKey];
}

- (BKProgressBlock)uploadProgressHandler {
    return [self associatedValueForKey:kUploadProgressHandlerKey];
}

- (void)setUploadProgressHandler:(BKProgressBlock)uploadProgressHandler {
    [self associateCopyOfValue:uploadProgressHandler withKey:kUploadProgressHandlerKey];
}

- (BKProgressBlock)downloadProgressHandler {
    return [self associatedValueForKey:kDownloadProgressHandlerKey];
}

- (void)setDownloadProgressHandler:(BKProgressBlock)downloadProgressHandler {
    [self associateCopyOfValue:downloadProgressHandler withKey:kDownloadProgressHandlerKey];
}

@end
