//
//  NSURLConnection+BlocksKit.h
//  BKURLConnection
//
//  Created by Igor Evsukov on 17.07.11.
//  Copyright 2011 Igor Evsukov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL (^BKCanAuthenticateAgainstProtectionSpaceHandler) (NSURLProtectionSpace *protectionSpace);
typedef void (^BKDidCancelAuthenticationChallengeHandler) (NSURLAuthenticationChallenge *challenge);
typedef void (^BKDidReceiveAuthenticationChallengeHandler) (NSURLAuthenticationChallenge *challenge);
typedef BOOL (^BKShouldUseCredentialStorageHandler) ();

typedef   id (^BKWillCacheResponseHandler) (NSCachedURLResponse *cachedResponse);
typedef void (^BKDidReceiveResponseHandler) (NSURLResponse *response);
typedef void (^BKDidReceiveDataHandler) (NSData *data);
typedef void (^BKSendBodyDataHandler) (NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite);
typedef   id (^BKWillSendRequestRedirectResponseHandler) (NSURLRequest *request, NSURLResponse *redirectResponse);

typedef void (^BKDidFailWithErrorHandler) (NSError *error);
typedef void (^BKDidFinishLoadingHandler) (NSURLResponse *response, NSData *responceData);

typedef void (^BKConnectionProgressBlock) (float progress);

/** NSURLConnection with both delegate and block callback support
 
 This category allows You to assign blocks on NSURLConnection
 delegate callbacks. And You can use blocks and delegation
 simultaneously!
 
 It also adds usefull block handlers for tracking upload and
 download progress.
 
 Here is small example:
 
     - (void)downloadImage:(id)sender {
         self.downloadButton.enabled = NO;
         self.progressView.progress = 0.0f;
         NSURL *imageURL = [NSURL URLWithString:@"http://icanhascheezburger.files.wordpress.com/2011/06/funny-pictures-nyan-cat-wannabe1.jpg"];
         NSURLConnection *connection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:imageURL] delegate:self];
         connection.didFailWithErrorHandler = ^(NSError *error) {
             [[UIAlertView alertWithTitle:@"Download error" message:[error localizedDescription]] show];
             
             self.downloadButton.enabled = YES;
             self.progressView.progress = 0.0f;
         };
         connection.didFinishLoadingHandler = ^(NSURLResponse *response, NSData *responseData){
             self.imageView.image = [UIImage imageWithData:responseData];
             self.downloadButton.enabled = YES;
         };
         connection.downloadProgressHandler = ^(float progress){
             self.progressView.progress = progress;
         };
         
         [connection start];
     }
     
     //these methods will be called too!
     - (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
         NSLog(@"%s",__PRETTY_FUNCTION__);
     }
     
     - (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
         NSLog(@"%s",__PRETTY_FUNCTION__);
     }
    
 @warning if delegate method reqiured to return a value, implementation in passed delegate will have
 higher priority than a block analog.
 */
@interface NSURLConnection (BlocksKit)

#if __has_feature(objc_arc)
@property (nonatomic, weak) id delegate;

@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSURLResponse *response;
#else
@property (nonatomic, assign) id delegate;

@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURLResponse *response;
#endif

@property (nonatomic, copy) BKCanAuthenticateAgainstProtectionSpaceHandler canAuthenticateAgainstProtectionSpaceHandler;
@property (nonatomic, copy) BKDidCancelAuthenticationChallengeHandler didCancelAuthenticationChallengeHandler;
@property (nonatomic, copy) BKDidReceiveAuthenticationChallengeHandler didReceiveAuthenticationChallengeHandler;
@property (nonatomic, copy) BKShouldUseCredentialStorageHandler shouldUseCredentialStorageHandler;

@property (nonatomic, copy) BKWillCacheResponseHandler willCacheResponseHandler;
@property (nonatomic, copy) BKDidReceiveResponseHandler didReceiveResponseHandler;
@property (nonatomic, copy) BKDidReceiveDataHandler didReceiveDataHandler;
@property (nonatomic, copy) BKSendBodyDataHandler sendBodyDataHandler;
@property (nonatomic, copy) BKWillSendRequestRedirectResponseHandler willSendRequestRedirectResponseHandler;

@property (nonatomic, copy) BKDidFailWithErrorHandler didFailWithErrorHandler;
@property (nonatomic, copy) BKDidFinishLoadingHandler didFinishLoadingHandler;

@property (nonatomic, copy) BKConnectionProgressBlock uploadProgressHandler;
@property (nonatomic, copy) BKConnectionProgressBlock downloadProgressHandler;

+ (NSURLConnection*)connectionWithRequest:(NSURLRequest *)request delegate:(id)delegate;

- (id)initWithRequest:(NSURLRequest *)request;
- (id)initWithRequest:(NSURLRequest *)request startImmediately:(BOOL)startImmediately;
+ (NSURLConnection*)connectionWithRequest:(NSURLRequest *)request;


@end
