//
//  NSURLConnection+BlocksKit.h
//  BlocksKit
//

#import <Foundation/Foundation.h>

/** NSURLConnection with both delegate and block callback support.

 It also adds useful block handlers for tracking upload and download progress.

 Here is a small example:
	 - (void)downloadImage:(id)sender {
		 self.downloadButton.enabled = NO;
		 self.progressView.progress = 0.0f;
		 NSURL *imageURL = [NSURL URLWithString:@"http://icanhascheezburger.files.wordpress.com/2011/06/funny-pictures-nyan-cat-wannabe1.jpg"];
		 NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
		 NSURLConnection *connection = [NSURLConnection connectionWithRequest:request];
		 connection.delegate = self;
		 connection.failureBlock = ^(NSURLConnection *connection, NSError *error) {
			 [[UIAlertView alertViewWithTitle:@"Download error" message:[error localizedDescription]] show];

			 self.downloadButton.enabled = YES;
			 self.progressView.progress = 0.0f;
		 };
		 connection.successBlock = ^(NSURLConnection *connection, NSURLResponse *response, NSData *responseData) {
			 self.imageView.image = [UIImage imageWithData:responseData];
			 self.downloadButton.enabled = YES;
		 };
		 connection.downloadBlock = ^(double progress) {
			 self.progressView.progress = progress;
		 };

		 [connection start];
	 }

	 //these methods will be called too!
	 - (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
		 NSLog(@"%s",__PRETTY_FUNCTION__);
	 }

	 - (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
		 NSLog(@"%s",__PRETTY_FUNCTION__);
	 }

 Created by Igor Evsukov as
 [IEURLConnection](https://github.com/evsukov89/IEURLConnection) and contributed
 to BlocksKit.
*/

@interface NSURLConnection (BlocksKit)

/** A mutable delegate that implements the NSURLConnectionDelegate protocol.

 This property allows for both use of block callbacks and delegate methods
 in an instance of NSURLConnection.  It only works on block-backed
 NSURLConnection instances.
 */
@property (nonatomic, weak, setter = setDelegate:) id delegate;

/** The block fired once the connection recieves a response from the server.

 This block corresponds to the connection:didReceiveResponse: method
 of NSURLConnectionDataDelegate. */
@property (nonatomic, copy, setter = bk_setResponseBlock:) void (^bk_responseBlock)(NSURLConnection *connection, NSURLResponse *response);

/** The block fired upon the failure of the connection.

 This block corresponds to the connection:didFailWithError:
 method of NSURLConnectionDelegate. */
@property (nonatomic, copy, setter = bk_setFailureBlock:) void (^bk_failureBlock)(NSURLConnection *connection, NSError *error);

/** The block that  upon the successful completion of the connection.

 This block corresponds to the connectionDidFinishLoading:
 method of NSURLConnectionDelegate.

 @warning If the delegate implements connection:didRecieveData:, then this
 block will *not* include the data recieved by the connection and appending
 the recieved data to an instance NSMutableData is left up to the user due
 to the behavior of frameworks that use NSURLConnection.
 */
@property (nonatomic, copy, setter = bk_setSuccessBlock:) void (^bk_successBlock)(NSURLConnection *connection, NSURLResponse *response, NSData *responseData);

/** The block fired every time new data is sent to the server,
 representing the current percentage of completion.

 This block corresponds to the
 connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:
 method of NSURLConnectionDelegate.
 */
@property (nonatomic, copy, setter = bk_setUploadBlock:) void (^bk_uploadBlock)(double percent);

/** The block fired every time new data is recieved from the server,
 representing the current percentage of completion.

 This block corresponds to the connection:didRecieveData:
 method of NSURLConnectionDelegate.
 */
@property (nonatomic, copy, setter = bk_setDownloadBlock:) void (^bk_downloadBlock)(double percent);

/** Creates and returns an initialized block-backed URL connection that does not begin to load the data for the URL request.

 @param request The URL request to load.
 @return An autoreleased NSURLConnection for the specified URL request.
 */
+ (NSURLConnection *)bk_connectionWithRequest:(NSURLRequest *)request;

/** Creates, starts, and returns an asynchronous, block-backed URL connection

 @return New and running NSURLConnection with the specified properties.
 @param request The URL request to load.
 @param success A code block that acts on instances of NSURLResponse and NSData in the event of a successful connection.
 @param failure A code block that acts on instances of NSURLResponse and NSError in the event of a failed connection.
 */
+ (NSURLConnection *)bk_startConnectionWithRequest:(NSURLRequest *)request successHandler:(void (^)(NSURLConnection *connection, NSURLResponse *response, NSData *responseData))success failureHandler:(void (^)(NSURLConnection *connection, NSError *error))failure;

/** Returns an initialized block-backed URL connection.

 @return Newly initialized NSURLConnection with the specified properties.
 @param request The URL request to load.
 */
- (id)bk_initWithRequest:(NSURLRequest *)request;

/** Returns an initialized URL connection with the specified completion handler.

 @return Newly initialized NSURLConnection with the specified properties.
 @param request The URL request to load.
 @param block A code block that acts on instances of NSURLResponse and NSData in the event of a successful connection.
 */
- (id)bk_initWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLConnection *connection, NSURLResponse *response, NSData *responseData))block;

/** Causes the connection to begin loading data, if it has not already, with the specified block to be fired on successful completion.

 @param block A code block that acts on instances of NSURLResponse and NSData in the event of a successful connection.
 */
- (void)bk_startWithCompletionBlock:(void (^)(NSURLConnection *connection, NSURLResponse *response, NSData *responseData))block;

@end
