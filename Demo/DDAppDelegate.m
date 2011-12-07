//
//  DDAppDelegate.m
//  DynamicDelegate
//
//  Created by Alexsander Akers on 11/26/11.
//  Copyright (c) 2011 Pandamonia LLC. All rights reserved.
//

#import "A2BlockDelegate.h"
#import "DDAppDelegate.h"

@interface UIAlertView (A2DynamicDelegate)

@property (nonatomic, copy) BOOL (^shouldEnableFirstOtherButtonBlock)(UIAlertView *alertView);
@property (nonatomic, copy) void (^willDismissBlock)(UIAlertView *alertView, NSInteger buttonIndex);

@end

@implementation UIAlertView (A2DynamicDelegate)

@dynamic shouldEnableFirstOtherButtonBlock;
@dynamic willDismissBlock;

+ (void) load
{
	@autoreleasepool
	{
		[self linkCategoryBlockProperty: @"shouldEnableFirstOtherButtonBlock"
					 withDelegateMethod: @selector(alertViewShouldEnableFirstOtherButton:)];
		[self linkCategoryBlockProperty: @"willDismissBlock"
					 withDelegateMethod: @selector(alertView:willDismissWithButtonIndex:)];
	}
}

@end

@implementation DDAppDelegate

@synthesize window = _window;

- (BOOL) application: (UIApplication *) application didFinishLaunchingWithOptions: (NSDictionary *) launchOptions
{
	UIWindow *window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
	self.window = window;
	[window release];
	
	// Override point for customization after application launch.
	self.window.backgroundColor = [UIColor whiteColor];
	[self.window makeKeyAndVisible];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"A2DynamicDelegate\n+\nA2BlockDelegate" message: @"This alert's delegate is implemented using blocks! That's so cool! \U0001f604" delegate: nil cancelButtonTitle: @"Meh\u2026" otherButtonTitles: @"HUZZAH!", nil];
	
	// Implements -alertViewShouldEnableFirstOtherButton:
	alertView.shouldEnableFirstOtherButtonBlock = ^(UIAlertView *alertView) {
		NSLog(@"Message: %@", alertView.message);
		return YES;
	};
	
	// Implements -alertView:willDismissWithButtonIndex:
	alertView.willDismissBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
		NSLog(@"You pushed button #%d (%@)", buttonIndex, [alertView buttonTitleAtIndex: buttonIndex]);
		
	};
	
	// Set the delegate
	alertView.delegate = alertView.dynamicDelegate;
	
	[alertView show];
	
	return YES;
}

@end
