//
//  NSURLConnection+BlocksKit.h
//  BlocksKit
//

typedef void (^BKProgressBlock) (float progress);
typedef void (^BKResponseBlock) (NSURLResponse *response);
typedef void (^BKChallengeBlock) (NSURLAuthenticationChallenge *challenge);
typedef void (^BKConnectionFinishBlock) (NSURLResponse *response, NSData *data);
typedef void (^BKDataSentBlock) (NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite);

typedef   id (^BKCachedResponseBlock) (NSCachedURLResponse *cachedResponse);
typedef   id (^BKRedirectBlock) (NSURLRequest *request, NSURLResponse *redirectResponse);

typedef BOOL (^BKCanAuthenticateBlock) (NSURLProtectionSpace *protectionSpace);

/** NSURLConnection with both delegate and block callback support
 
 This category allows you to assign blocks on NSURLConnection
 delegate callbacks, while still allowing the normal delegation
 pattern!
 
 It also adds useful block handlers for tracking upload and
 download progress.
 
 Here is a small example:
     - (void)downloadImage:(id)sender {
         self.downloadButton.enabled = NO;
         self.progressView.progress = 0.0f;
         NSURL *imageURL = [NSURL URLWithString:@"http://icanhascheezburger.files.wordpress.com/2011/06/funny-pictures-nyan-cat-wannabe1.jpg"];
         NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
         NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
         connection.didFailWithErrorHandler = ^(NSError *error){
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

 Created by Igor Evsukov as [IEURLConnection](https://github.com/evsukov89/IEURLConnection) and contributed to BlocksKit.
    
 @warning If a delegate method is required to return a value and is implemented in the delegate, the
 implementation will take priority over the block.
*/

@interface NSURLConnection (BlocksKit)

@property (nonatomic, assign) id delegate;

@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURLResponse *response;

@property (nonatomic, copy) BKCanAuthenticateBlock canAuthenticateAgainstProtectionSpaceHandler;
@property (nonatomic, copy) BKChallengeBlock didCancelAuthenticationChallengeHandler;
@property (nonatomic, copy) BKChallengeBlock didReceiveAuthenticationChallengeHandler;
@property (nonatomic, copy) BKAnswerBlock shouldUseCredentialStorageHandler;

@property (nonatomic, copy) BKCachedResponseBlock willCacheResponseHandler;
@property (nonatomic, copy) BKResponseBlock didReceiveResponseHandler;
@property (nonatomic, copy) BKDataBlock didReceiveDataHandler;
@property (nonatomic, copy) BKDataSentBlock sendBodyDataHandler;
@property (nonatomic, copy) BKRedirectBlock willSendRequestRedirectResponseHandler;

@property (nonatomic, copy) BKErrorBlock didFailWithErrorHandler;
@property (nonatomic, copy) BKConnectionFinishBlock didFinishLoadingHandler;

@property (nonatomic, copy) BKProgressBlock uploadProgressHandler;
@property (nonatomic, copy) BKProgressBlock downloadProgressHandler;

+ (NSURLConnection *)connectionWithRequest:(NSURLRequest *)request;
+ (NSURLConnection *)connectionWithRequest:(NSURLRequest *)request delegate:(id)delegate;

- (id)initWithRequest:(NSURLRequest *)request;
- (id)initWithRequest:(NSURLRequest *)request startImmediately:(BOOL)startImmediately;


@end
