//
//  DDAppDelegate.m
//  A2DD Demo
//
//  Created by Alexsander Akers on 11/26/11.
//  Copyright (c) 2011 Pandamonia LLC. All rights reserved.
//

#import "A2DynamicDelegate.h"
#import "A2BlockDelegate.h"
#import "DDAppDelegate.h"

#pragma mark - A2DynamicUIAlertViewDelegate

@interface A2DynamicUIAlertViewDelegate : A2DynamicDelegate <UIAlertViewDelegate>

// Custom block handlers could go here

@end

@implementation A2DynamicUIAlertViewDelegate

@end

#pragma mark - UIAlertView+A2DynamicDelegate

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

#pragma mark - DDAppDelegate

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
		NSLog(@"This block was set using -[UIAlertView(A2DynamicDelegate) setWillDismissBlock:]");
		NSLog(@"You pushed button #%d (%@)", buttonIndex, [alertView buttonTitleAtIndex: buttonIndex]);
	};
	
	[alertView.dynamicDelegate implementMethod: @selector(alertView:clickedButtonAtIndex:) withBlock: ^(UIAlertView *alertView, NSInteger buttonIndex) {
		NSLog(@"This block was set using -[A2DynamicDelegate implementMethod:withBlock:]");
	}];
	
	// Set the delegate
	alertView.delegate = alertView.dynamicDelegate;
	
	[alertView show];
	
	return YES;
}

@end
