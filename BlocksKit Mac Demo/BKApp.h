
//  BlocksKit MacDemo - Created by Alex Gray on 7/6/13.

#import <Cocoa/Cocoa.h>
#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/A2DynamicDelegate.h>

@interface 								 BKApp : NSObject
@property (assign) IBOutlet NSTableView * tv;
@property (strong) 	 A2DynamicDelegate * ddSource;
@property 						  NSUInteger   displayCount;		@end

@interface  BKColorfulCell : NSCell									@end



