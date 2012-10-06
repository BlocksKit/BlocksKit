//
//  PNDAppDelegate.m
//  iOS Tests App
//
//  Created by Alexsander Akers on 10/5/12.
//  Copyright (c) 2012 Pandamonia LLC. All rights reserved.
//

#import "PNDAppDelegate.h"

@implementation PNDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.backgroundColor = [UIColor whiteColor];
	
	UIViewController *rootViewController = [[UIViewController alloc] init];
	UILabel *label = [[UILabel alloc] init];
	label.font = [UIFont systemFontOfSize: [UIFont labelFontSize]];
	label.text = @"Testing…";
	[label sizeToFit];
	
	label.frame = CGRectMake((rootViewController.view.bounds.size.width - label.frame.size.width) / 2.0, (rootViewController.view.bounds.size.height - label.frame.size.height) / 2.0, label.frame.size.width, label.frame.size.height);
	[rootViewController.view addSubview: label];
	
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
	activityIndicator.frame = CGRectMake((rootViewController.view.bounds.size.width - activityIndicator.frame.size.width) / 2.0, (rootViewController.view.bounds.size.height - label.frame.size.height) / 2.0 - activityIndicator.frame.size.height - 8, activityIndicator.frame.size.width, activityIndicator.frame.size.height);
	[activityIndicator startAnimating];
	[rootViewController.view addSubview: activityIndicator];
	
	self.window.rootViewController = rootViewController;
	[self.window makeKeyAndVisible];
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
