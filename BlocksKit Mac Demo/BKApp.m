//
//  AppDelegate.m
//  MacDemo
//
//  Created by Alex Gray on 7/6/13.
//  Copyright (c) 2013 Pandamonia LLC. All rights reserved.
//

#import "BKApp.h"
#import <objc/runtime.h>

@implementation BKApp
- (void) awakeFromNib {

	NSColorList *clrLst 	= [NSColorList colorListNamed:@"Crayons"];
	NSDictionary *cryns 	= [clrLst.allKeys bk_reduce:@[] withBlock:^id(id sum,id x){
		return [sum arrayByAddingObject: @{ @"name" : x, @"color" : [clrLst colorWithKey : x] }];
	}];
	[self bk_associateValue:cryns withKey:(const void*)@"assocCryns"];

	[_ddSource = _tv.bk_dynamicDataSource implementMethod:@selector( numberOfRowsInTableView: )
						  withBlock:^NSInteger( NSTableView * v )	{
		return _displayCount;
	}];
	[_ddSource implementMethod:@selector( tableView:objectValueForTableColumn:row: )
						  withBlock:^id ( NSTableView * v, NSTableColumn * c, NSInteger r ){
		return [self bk_associatedValueForKey:@"assocCryns"][r][[v.tableColumns indexOfObject:c]?@"color":@"name"];
	}];
	_tv.dataSource	= (id<NSTableViewDataSource>)_ddSource;

	__block NSTimer *tmr;
	[self bk_addObserverForKeyPath:@"displayCount" task:^( id target ) {

		if 		(_displayCount > [[self bk_associatedValueForKey:@"assocCryns"]count]-1)	[tmr invalidate];
		else if 	(!_displayCount)
			tmr = [NSTimer bk_scheduledTimerWithTimeInterval:.4 block:^(NSTimeInterval time) {
				self.displayCount++;																				} repeats:YES];
		else [_tv reloadData], [_tv.enclosingScrollView.documentView scrollPoint:NSMakePoint(0, 10000)];
	}];
	[self reset:@"to start things off"];
}
- (IBAction)reset:(id)sender { self.displayCount = 0; }												@end

@implementation BKColorfulCell
- (void)drawWithFrame:(NSRect)cF inView:(NSView*)cV {
	[(NSColor*)[self objectValue]set];	NSRectFill(cF);
}		@end
