//
//  BKApp.h
//  BlocksKit Mac Demo
//
//  Contributed by Alex Gray.
//

@import Cocoa;

@class A2DynamicDelegate;

@interface BKApp : NSObject

@property NSWindow *window;
@property NSTimer *tmr;
@property A2DynamicDelegate * ddSrc;
@property IBOutlet NSTableView *tv;
@property NSUInteger displayCt;

@end
