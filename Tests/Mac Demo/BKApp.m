
#import "BKApp.h"

@implementation BKApp	- (void) awakeFromNib {

	// Get a colorlist we'll use as content for our tableView
	NSColorList *clrLst 	= [NSColorList colorListNamed:@"Crayons"];

#pragma mark - NSArray+BlocksKit

	// We "reduce" the colorList's keys (x) into the "sum" array, which is ininitally empty. (@[])
	NSArray *cryns = [clrLst.allKeys reduce:@[] withBlock:^id(NSArray *sum, id x) {
		// Return the accumulator "sum" array that gets one more name/NSColor dictionary on each pass.
		return [sum arrayByAddingObject:@{@"name":x, @"color":[clrLst colorWithKey:x]}];
	}];

#pragma mark - NSObject+AssociatedObjects

	// Use BK to easily "Associated Values" to any object.
	// Here, we save the array we just made to "self", for use later. No property/ivar necessary!
	[self associateValue:cryns withKey:(const void*)@"assocCryns"];

#pragma mark - NSTimer+BlocksKit

	// timer w/ block will bump our displayCount property and repeat itself, triggering KVO notification below
	_tmr = [NSTimer scheduledTimerWithTimeInterval:.4 block:^(NSTimer *t) { self.displayCt++; } repeats:YES];

#pragma mark - NSObject+BlockObservation

	// A simpler, blocks based alternative to "observeValueForKeyPath:ofObject:change:context:"
	// Thanks to KVO, this block "task" will get called every time our "displayCount" property changes (ie. via the timer)
	[self addObserverForKeyPath:@"displayCt" options:2 task:^(BKApp*obj,NSDictionary*change) {

		// reload table and scroll to the bottom of the list when displayCt changes
		obj.displayCt != [[obj associatedValueForKey:@"assocCryns"]count]
		? 	[obj.tv  reloadData], [obj.tv.enclosingScrollView.documentView scrollPoint:NSMakePoint(0,10000)]
		: 	[obj.tmr invalidate]; // if displayCt == count of dicts in "crayon" array, "invalidate" timer
	}];

#pragma mark - Dynamic DataSource

	// assign/instantiate A2DynamicDelegate from a tableView's dynamicDataSource property (via BlocksKit's magic!)
	_ddSrc = _tv.dynamicDataSource;

	// The 2 required <NSTableViewDataSource> methods we will dynamically "delegate".
	SEL numberOfRowsMethod 			 = @selector(numberOfRowsInTableView:),
		 objectValueForColRowMethod = @selector(tableView:objectValueForTableColumn:row:);

	// Our "block implementations" variable with method signatures that match the 2 tableView datasource methods above.
	NSInteger  (^numberOfRowsBlock)(NSTableView*) 								  = ^NSInteger(NSTableView*tv){ return _displayCt; };
	id (^objectValueForColRowBlock)(NSTableView*,NSTableColumn*,NSInteger) = ^id(NSTableView*tv,NSTableColumn*tc,NSInteger row) {
		// Here we access the array of dictionaries we saved to "self", returning the appropriate "objectValueForTableColumn:row:"
		return [self associatedValueForKey:@"assocCryns"][row][[tv.tableColumns indexOfObject:tc] ? @"color" : @"name"];
	};
	// Tell A2DynamicDelegate to implement the datasource method with the block we just defined. (these populate the table!).
	[_ddSrc implementMethod:numberOfRowsMethod 			withBlock:			numberOfRowsBlock];
	[_ddSrc implementMethod:objectValueForColRowMethod withBlock:objectValueForColRowBlock];

	// set the A2DynamicDelegate as the IBOutlet table property's datasource. Requires a cast to id<NSTableViewDataSource> protocol.
	_tv.dataSource	= (id<NSTableViewDataSource>)_ddSrc;
}

- (IBAction)reset:(id)sender { self.displayCt = 0; } /* Reset Button to reset the action */							@end

@implementation BKColorfulCell  // A simple cell class to display the color object in the table.

- (void)drawWithFrame:(NSRect)cF inView:(NSView*)cV {	[(NSColor*)[self objectValue]set];	NSRectFill(cF);}		@end

