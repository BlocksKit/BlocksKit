
//  BlocksKit MacDemo - Created by Alex Gray on 7/6/13.

#import <Cocoa/Cocoa.h>
#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/A2DynamicDelegate.h>
#import <objc/runtime.h>

@interface 					 BKApp : NSObject

@property 	 			  NSTimer * tmr;
@property 	 A2DynamicDelegate * ddSrc;
@property IBOutlet NSTableView * tv;
@property 			  NSUInteger   displayCt;			@end

@interface  	 BKColorfulCell : NSCell				@end
