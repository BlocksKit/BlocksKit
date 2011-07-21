//
//  NSURLConnection+BlocksKit.m
//  BlocksKit
//

#import "NSURLConnection+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"
#import <objc/runtime.h>

static char *kDelegateKey = "NSURLConnectionDelegate";
static char *kResponseDataKey = "NSURLConnectionResponseData";
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
@property (nonatomic, assign) NSUInteger responseLength;
- (id)bk_initWithRequest:(NSURLRequest *)request delegate:(id)aDelegate;
- (id)bk_initWithRequest:(NSURLRequest *)request delegate:(id)aDelegate startImmediately:(BOOL)startImmediately;
@end

#pragma mark Delegate proxy

@interface BKURLConnectionDelegateProxy : NSObject
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

+ (void)load {
    Class myClass = [self class];
    
    Method originalInitWithRequestDelegateMethod = class_getInstanceMethod(myClass, @selector(initWithRequest:delegate:));
    Method categoryInitWithRequestDelegateMethod = class_getInstanceMethod(myClass, @selector(bk_initWithRequest:delegate:));
    method_exchangeImplementations(originalInitWithRequestDelegateMethod, categoryInitWithRequestDelegateMethod);
    
    Method originalInitWithRequestDelegateStartImmediatelyMethod = class_getInstanceMethod(myClass, @selector(initWithRequest:delegate:startImmediately:));
    Method categoryInitWithRequestDelegateStartImmediatelyMethod = class_getInstanceMethod(myClass, @selector(bk_initWithRequest:delegate:startImmediately:));
    method_exchangeImplementations(originalInitWithRequestDelegateStartImmediatelyMethod, categoryInitWithRequestDelegateStartImmediatelyMethod);    
}

+ (NSURLConnection*)connectionWithRequest:(NSURLRequest *)request {
    return BK_AUTORELEASE([[[self class] alloc] initWithRequest:request delegate:nil startImmediately:NO]);
}

// new methods
- (id)initWithRequest:(NSURLRequest *)request {
    return [self initWithRequest:request delegate:nil startImmediately:NO];
}

- (id)initWithRequest:(NSURLRequest *)request startImmediately:(BOOL)startImmediately {
    return [self initWithRequest:request delegate:nil startImmediately:startImmediately];
}

- (id)initWithRequest:(NSURLRequest *)request startImmediately:(BOOL)startImmediately completionHandler:(BKConnectionFinishBlock)block {
    if ((self = [self initWithRequest:request delegate:nil startImmediately:startImmediately]) && block) {
        self.didFinishLoadingHandler = block;
    }
    return self;
}

// swizzled methods
- (id)bk_initWithRequest:(NSURLRequest *)request delegate:(id)aDelegate {
    return [self initWithRequest:request delegate:aDelegate startImmediately:NO];
}

- (id)bk_initWithRequest:(NSURLRequest *)request delegate:(id)aDelegate startImmediately:(BOOL)startImmediately {
    if ([self bk_initWithRequest:request delegate:[BKURLConnectionDelegateProxy shared] startImmediately:startImmediately]) {
        if (aDelegate && (aDelegate != self) && ![aDelegate isKindOfClass:[self class]]) {
            self.delegate = aDelegate;
        }          
    }
    return self;
}

#pragma mark Private

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

- (NSUInteger)responseLength {
    NSNumber *value = [self associatedValueForKey:kResponseLengthKey];
    return [value unsignedIntegerValue];
}

- (void)setResponseLength:(NSUInteger)responseLength {
    NSNumber *value = [NSNumber numberWithUnsignedInteger:responseLength];
    return [self associateValue:value withKey:kResponseKey];
}

#pragma mark Properties

- (id)delegate {
    return [self associatedValueForKey:kDelegateKey];
}

- (void)setDelegate:(id)delegate {
    [self weaklyAssociateValue:delegate withKey:kDelegateKey];
}

- (BKResponseBlock)didReceiveResponseHandler {
    return [self associatedValueForKey:kDidReceiveResponseHandlerKey];
}

- (void)setDidReceiveResponseHandler:(BKResponseBlock)didReceiveResponseHandler {
    [self associateCopyOfValue:didReceiveResponseHandler withKey:kDidReceiveResponseHandlerKey];
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
