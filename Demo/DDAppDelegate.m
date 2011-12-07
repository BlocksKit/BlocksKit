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
		[self linkCategoryBlockProperty: @"willDismissBlock" withDelegateMethod: @selector(alertView:willDismissWithButtonIndex:)];
		[self linkCategoryBlockProperty: @"shouldEnableFirstOtherButtonBlock" withDelegateMethod: @selector(alertViewShouldEnableFirstOtherButton:)];
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
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"A2DynamicDelegate" message: @"This alert view has a dynamic delegate! \U0001f604" delegate: nil cancelButtonTitle: @"Meh\u2026" otherButtonTitles: @"OH HUZZAH!", nil];
	
	// Implements -alertViewShouldEnableFirstOtherButton:
	alertView.shouldEnableFirstOtherButtonBlock = ^(UIAlertView *alertView) {
		NSLog(@"Should I? %@", alertView);
		return YES;
	};
	
	// Implements -alertView:willDismissWithButtonIndex:
	alertView.willDismissBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
		NSLog(@"You pushed button #%d", buttonIndex);
	};
	
	// Set the delegate
	alertView.delegate = alertView.dynamicDelegate;
	
	[alertView show];
	
	return YES;
}

@end
