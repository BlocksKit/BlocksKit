//
//  NSURLConnection+BlocksKit.m
//  NSURLConnection
//
//  Created by Igor Evsukov on 17.07.11.
//  Copyright 2011 Igor Evsukov. All rights reserved.
//

#import "NSURLConnection+BlocksKit.h"

#import "NSObject+AssociatedObjects.h"

#pragma mark - private class – delegate proxy
@interface BKURLConnectionDelegateProxy : NSObject

+ (id)shared;

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace;
- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection;

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse;

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

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

#pragma mark Connection Authentication
- (BOOL)connection:(NSURLConnection*)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    if (connection.delegate != nil && [connection.delegate respondsToSelector:@selector(connection:canAuthenticateAgainstProtectionSpace:)]) {
        return [connection.delegate connection:connection canAuthenticateAgainstProtectionSpace:protectionSpace];
    }
    if (connection.canAuthenticateAgainstProtectionSpaceHandler != nil) {
        return connection.canAuthenticateAgainstProtectionSpaceHandler(protectionSpace);
    }
    return NO;
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if (connection.delegate != nil && [connection.delegate respondsToSelector:@selector(connection:didCancelAuthenticationChallenge:)]) {
        [connection.delegate connection:connection didCancelAuthenticationChallenge:challenge];
    }
    if (connection.didCancelAuthenticationChallengeHandler != nil) {
        connection.didCancelAuthenticationChallengeHandler(challenge);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if (connection.delegate != nil && [connection.delegate respondsToSelector:@selector(connection:didReceiveAuthenticationChallenge:)]) {
        [connection.delegate connection:connection didReceiveAuthenticationChallenge:challenge];
    }
    if (connection.didReceiveAuthenticationChallengeHandler != nil) {
        connection.didReceiveAuthenticationChallengeHandler(challenge);
    }
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    if (connection.delegate != nil && [connection.delegate respondsToSelector:@selector(connectionShouldUseCredentialStorage:)]) {
        return [connection.delegate connectionShouldUseCredentialStorage:connection];
    }
    if (connection.shouldUseCredentialStorageHandler != nil) {
        return connection.shouldUseCredentialStorageHandler();
    }
    return NO;   
}

#pragma mark Connection Data and Responses
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    if (connection.delegate != nil && [connection.delegate respondsToSelector:@selector(connection:willCacheResponse:)]) {
        return [connection.delegate connection:connection willCacheResponse:cachedResponse];
    }
    if (connection.willCacheResponseHandler != nil) {
        return connection.willCacheResponseHandler(cachedResponse);
    }
    return cachedResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection.delegate != nil && [connection.delegate respondsToSelector:@selector(connection:didReceiveResponse:)]) {
        [connection.delegate connection:connection didReceiveResponse:response];
    }
    
    if (connection.responseData != nil) {
        // according to documentation 
        // we should delete all previous received data
        [connection.responseData setLength:0];
    }
    
    connection.response = response;
    if (connection.didReceiveResponseHandler != nil) {
        connection.didReceiveResponseHandler(response);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection.delegate != nil && [connection.delegate respondsToSelector:@selector(connection:didReceiveData:)]) {
        [connection.delegate connection:connection didReceiveData:data];
    }
    
    if (connection.responseData == nil)
        connection.responseData = [NSMutableData data];
    
    [connection.responseData appendData:data];
    
    if (connection.didReceiveDataHandler != nil) {
        connection.didReceiveDataHandler(data);
    }
    
    if (connection.downloadProgressHandler != nil && connection.response != nil && [connection.response expectedContentLength] != NSURLResponseUnknownLength) {
        connection.downloadProgressHandler((double)[connection.responseData length]/(double)[connection.response expectedContentLength]);
    }
    
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    if (connection.delegate != nil && [connection.delegate respondsToSelector:@selector(connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [connection.delegate connection:connection didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
    
    if (connection.sendBodyDataHandler != nil) {
        connection.sendBodyDataHandler(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    }
    
    if (connection.uploadProgressHandler != nil) {
        connection.uploadProgressHandler((float)totalBytesWritten/(float)totalBytesExpectedToWrite);
    }
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    if (connection.delegate != nil && [connection.delegate respondsToSelector:@selector(connection:willSendRequest:redirectResponse:)]) {
        return [connection.delegate connection:connection willSendRequest:request redirectResponse:redirectResponse];
    }
    if (connection.willSendRequestRedirectResponseHandler != nil) {
        return connection.willSendRequestRedirectResponseHandler(request, redirectResponse);
    }
    return request;
}

#pragma mark Connection Completion
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection.delegate != nil && [connection.delegate respondsToSelector:@selector(connection:didFailWithError:)]) {
        [connection.delegate connection:connection didFailWithError:error];
    }
    
    if (connection.didFailWithErrorHandler != nil) {
        connection.didFailWithErrorHandler(error);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection.delegate != nil && [connection.delegate respondsToSelector:@selector(connectionDidFinishLoading:)]) {
        [connection.delegate connectionDidFinishLoading:connection];
    }
    
    if (connection.didFinishLoadingHandler != nil) {
        connection.didFinishLoadingHandler(connection.response, connection.responseData);
    }
}

@end

#pragma mark - constants
static char* kDelegateKey = "delegate";

static char* kResponseDataKey = "responseData";
static char* kResponseKey = "response";

static char* kCanAuthenticateAgainstProtectionSpaceHandlerKey = "canAuthenticateAgainstProtectionSpaceHandler";
static char* kDidCancelAuthenticationChallengeHandlerKey = "didCancelAuthenticationChallengeHandler";
static char* kDidReceiveAuthenticationChallengeHandlerKey = "didReceiveAuthenticationChallengeHandler";
static char* kShouldUseCredentialStorageHandlerKey = "shouldUseCredentialStorageHandler";

static char* kWillCacheResponseHandlerKey = "willCacheResponseHandler";
static char* kDidReceiveResponseHandlerKey = "didReceiveResponseHandler";
static char* kdidReceiveDataHandlerKey = "didReceiveDataHandler";
static char* kSendBodyDataHandlerKey = "sendBodyDataHandler";
static char* kWillSendRequestRedirectResponseHandlerKey = "willSendRequestRedirectResponseHandler";

static char* kDidFailWithErrorHandlerKey = "didFailWithErrorHandler";
static char* kDidFinishLoadingHandlerKey = "didFinishLoadingHandler";

static char* kUploadProgressHandlerKey = "uploadProgressHandler";
static char* kDownloadProgressHandlerKey = "downloadProgressHandler";

@interface NSURLConnection (BlocksKitPrivate)

#if BK_SHOULD_DEALLOC
- (void)bk_dealloc;
#endif

- (id)bk_initWithRequest:(NSURLRequest *)request delegate:(id)aDelegate;
- (id)bk_initWithRequest:(NSURLRequest *)request delegate:(id)aDelegate startImmediately:(BOOL)startImmediately;

@end

@implementation NSURLConnection (BlocksKit)

#pragma mark - monkeypatching
+ (void)load {    
    Method originalInitWithRequestDelegateMethod = class_getInstanceMethod([self class], @selector(initWithRequest:delegate:));
    Method categoryInitWithRequestDelegateMethod = class_getInstanceMethod([self class], @selector(bk_initWithRequest:delegate:));
    method_exchangeImplementations(originalInitWithRequestDelegateMethod, categoryInitWithRequestDelegateMethod);
    
    Method originalInitWithRequestDelegateStartImmediatelyMethod = class_getInstanceMethod([self class], @selector(initWithRequest:delegate:startImmediately:));
    Method categoryInitWithRequestDelegateStartImmediatelyMethod = class_getInstanceMethod([self class], @selector(bk_initWithRequest:delegate:startImmediately:));
    method_exchangeImplementations(originalInitWithRequestDelegateStartImmediatelyMethod, categoryInitWithRequestDelegateStartImmediatelyMethod);    
}

#pragma mark - properties
@dynamic delegate;

@dynamic responseData, response;
@dynamic canAuthenticateAgainstProtectionSpaceHandler, didCancelAuthenticationChallengeHandler, didReceiveAuthenticationChallengeHandler, shouldUseCredentialStorageHandler;
@dynamic willCacheResponseHandler, didReceiveResponseHandler, didReceiveDataHandler, sendBodyDataHandler, willSendRequestRedirectResponseHandler;
@dynamic didFailWithErrorHandler, didFinishLoadingHandler;
@dynamic uploadProgressHandler, downloadProgressHandler;

#pragma mark - init && dealloc
#pragma mark original overloaded
- (id)bk_initWithRequest:(NSURLRequest *)request delegate:(id)aDelegate {
    return [self initWithRequest:request delegate:aDelegate startImmediately:NO];
}
- (id)bk_initWithRequest:(NSURLRequest *)request delegate:(id)aDelegate startImmediately:(BOOL)startImmediately {
    if ([self bk_initWithRequest:request delegate:[BKURLConnectionDelegateProxy shared] startImmediately:startImmediately]) {
        if (aDelegate != nil && aDelegate != [self class]) {
            self.delegate = aDelegate;
        }          
    }
    return self;
}

+ (NSURLConnection*)connectionWithRequest:(NSURLRequest *)request delegate:(id)delegate {
    return [[self alloc] initWithRequest:request delegate:delegate startImmediately:NO];
}

#pragma mark new
- (id)initWithRequest:(NSURLRequest *)request {
    return [self initWithRequest:request delegate:nil startImmediately:NO];
}

- (id)initWithRequest:(NSURLRequest *)request startImmediately:(BOOL)startImmediately {
    return [self initWithRequest:request delegate:nil startImmediately:startImmediately];
}
+ (NSURLConnection*)connectionWithRequest:(NSURLRequest *)request {
    return [[self alloc] initWithRequest:request delegate:nil startImmediately:NO];
}

#pragma mark - getters and setters
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

- (BKCanAuthenticateAgainstProtectionSpaceHandler)canAuthenticateAgainstProtectionSpaceHandler {
    return [self associatedValueForKey:kCanAuthenticateAgainstProtectionSpaceHandlerKey];
}
- (void)setCanAuthenticateAgainstProtectionSpaceHandler:(BKCanAuthenticateAgainstProtectionSpaceHandler)canAuthenticateAgainstProtectionSpaceHandler {
    [self associateCopyOfValue:canAuthenticateAgainstProtectionSpaceHandler withKey:kCanAuthenticateAgainstProtectionSpaceHandlerKey];
}

- (BKDidCancelAuthenticationChallengeHandler)didCancelAuthenticationChallengeHandler {
    return [self associatedValueForKey:kDidCancelAuthenticationChallengeHandlerKey];
}
- (void)setDidCancelAuthenticationChallengeHandler:(BKDidCancelAuthenticationChallengeHandler)didCancelAuthenticationChallengeHandler {
    [self associateCopyOfValue:didCancelAuthenticationChallengeHandler withKey:kDidCancelAuthenticationChallengeHandlerKey];
}

- (BKDidReceiveAuthenticationChallengeHandler)didReceiveAuthenticationChallengeHandler {
    return [self associatedValueForKey:kDidReceiveAuthenticationChallengeHandlerKey];
}
- (void)setDidReceiveAuthenticationChallengeHandler:(BKDidReceiveAuthenticationChallengeHandler)didReceiveAuthenticationChallengeHandler {
    [self associateCopyOfValue:didReceiveAuthenticationChallengeHandler withKey:kDidReceiveAuthenticationChallengeHandlerKey];
}

- (BKShouldUseCredentialStorageHandler)shouldUseCredentialStorageHandler {
    return [self associatedValueForKey:kShouldUseCredentialStorageHandlerKey];
}
- (void)setShouldUseCredentialStorageHandler:(BKShouldUseCredentialStorageHandler)shouldUseCredentialStorageHandler {
    [self associateCopyOfValue:shouldUseCredentialStorageHandler withKey:kShouldUseCredentialStorageHandlerKey];
}

- (BKWillCacheResponseHandler)willCacheResponseHandler {
    return [self associatedValueForKey:kWillCacheResponseHandlerKey];
}
- (void)setWillCacheResponseHandler:(BKWillCacheResponseHandler)willCacheResponseHandler {
    [self associateCopyOfValue:willCacheResponseHandler withKey:kWillCacheResponseHandlerKey];
}

- (BKDidReceiveResponseHandler)didReceiveResponseHandler {
    return [self associatedValueForKey:kDidReceiveResponseHandlerKey];
}
- (void)setDidReceiveResponseHandler:(BKDidReceiveResponseHandler)didReceiveResponseHandler {
    [self associateCopyOfValue:didReceiveResponseHandler withKey:kDidReceiveResponseHandlerKey];
}

- (BKDidReceiveDataHandler)didReceiveDataHandler {
    return [self associatedValueForKey:kdidReceiveDataHandlerKey];
}
- (void)setDidReceiveDataHandler:(BKDidReceiveDataHandler)didReceiveDataHandler {
    [self associateCopyOfValue:didReceiveDataHandler withKey:kdidReceiveDataHandlerKey];
}

- (BKSendBodyDataHandler)sendBodyDataHandler {
    return [self associatedValueForKey:kSendBodyDataHandlerKey];
}
- (void)setSendBodyDataHandler:(BKSendBodyDataHandler)sendBodyDataHandler {
    [self associateCopyOfValue:sendBodyDataHandler withKey:kSendBodyDataHandlerKey];
}

- (BKWillSendRequestRedirectResponseHandler)willSendRequestRedirectResponseHandler {
    return [self associatedValueForKey:kWillSendRequestRedirectResponseHandlerKey];
}
- (void)setWillSendRequestRedirectResponseHandler:(BKWillSendRequestRedirectResponseHandler)willSendRequestRedirectResponseHandler {
    [self associateCopyOfValue:willSendRequestRedirectResponseHandler withKey:kWillSendRequestRedirectResponseHandlerKey];
}

- (BKDidFailWithErrorHandler)didFailWithErrorHandler {
    return [self associatedValueForKey:kDidFailWithErrorHandlerKey];
}
- (void)setDidFailWithErrorHandler:(BKDidFailWithErrorHandler)didFailWithErrorHandler {
    [self associateCopyOfValue:didFailWithErrorHandler withKey:kDidFailWithErrorHandlerKey];
}

- (BKDidFinishLoadingHandler)didFinishLoadingHandler {
    return [self associatedValueForKey:kDidFinishLoadingHandlerKey];
}
- (void)setDidFinishLoadingHandler:(BKDidFinishLoadingHandler)didFinishLoadingHandler {
    [self associateCopyOfValue:didFinishLoadingHandler withKey:kDidFinishLoadingHandlerKey];
}

- (BKConnectionProgressBlock)uploadProgressHandler {
    return [self associatedValueForKey:kUploadProgressHandlerKey];
}
- (void)setUploadProgressHandler:(BKConnectionProgressBlock)uploadProgressHandler {
    [self associateCopyOfValue:uploadProgressHandler withKey:kUploadProgressHandlerKey];
}

- (BKConnectionProgressBlock)downloadProgressHandler {
    return [self associatedValueForKey:kDownloadProgressHandlerKey];
}
- (void)setDownloadProgressHandler:(BKConnectionProgressBlock)downloadProgressHandler {
    [self associateCopyOfValue:downloadProgressHandler withKey:kDownloadProgressHandlerKey];
}

@end
