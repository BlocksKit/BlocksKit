# A2DynamicDelegate
----

## Overview

Most programming languages conceptualize a reusable "unit of work" to simplify context and scope in a program and its classes. These might be called "closures" or "lambdas". Since iOS 4.0 and Mac OS X 10.6, we have our own:  blocks.

When used a dynamic, messaging language like Objective-C, blocks - functions as objects - overlap quite a bit with the selector pattern. This is especially true when it comes to delegation, where Objective-C provides us with an interesting feature called protocols.

There are many places in Cocoa where blocks would make more sense than delegation for simplistic functions like callbacks, and Apple is slowly moving toward these at the typically glacial pace of operating system frameworks.

A2DynamicDelegate serves to help bridge the gap between old and new, dynamically creating properties for blocks that equate the contents of a delegate's protocol.

## Features

* Dynamic block properties that take the guesswork out of implementing and maintaining custom blocks for a class.
* Map custom block properties to selectors on data sources (`FooDataSource`), delegates (`FooDelegate`), and arbitrary protocols (`BarProtocol`).
* Implement a delegate for a given class.

## Usage

A2DynamicDelegate is made up of the two A2BlockDelegate and A2DynamicDelegate headers and implementations. Simply add them to an Xcode project.

### A2BlockDelegate

Call one of the methods in the `A2BlockDelegate` category on a class to add a block property to that class:

	@implementation UIAlertView(FooBlockHelpers)
	
	+ (void)load {
		@autoreleasepool {
			[self linkCategoryBlockProperty: @"shouldEnableFirstOtherButtonBlock" withDelegateMethod: @selector(alertViewShouldEnableFirstOtherButton:)];
			[self linkCategoryBlockProperty: @"willDismissBlock" withDelegateMethod: @selector(alertView:willDismissWithButtonIndex:)];
		}
	}

	@end

Or, alternatively, do it using a dictionary:

	@implementation UIAlertView(FooBlockHelpers)
	
	+ (void)load {
		@autoreleasepool {
			NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
			 @"shouldEnableFirstOtherButtonBlock", @"alertViewShouldEnableFirstOtherButton:",
			 @"willDismissBlock", @"alertView:willDismissWithButtonIndex:",
			 nil];
			[self linkDelegateMethods:dict];
		}
	}

	@end

A2BlockDelegate automatically guesses which protocol to use for the implementation. A data source protocol (i.e. `FooDataSource` over `FooDelegate`) can be used using `+linkCategoryBlockProperty:withDataSourceMethod:` or `+linkDataSourceMethods:`. One can manually be specified using `+linkCategoryBlockProperty:withProtocol:method:` or `+linkProtocol:methods:`. 

Do note that you can freely extend a class using `+load`. Unlike all category implementations, the runtime will run multiple `+load` methods. Use it wisely, though; `+load` is called whenever a class is first referred to.

### A2DynamicDelegate

A2DynamicDelegate is the core by which A2BlockDelegate works. An instance of a dynamic delegate can automatically synthesize and edit methods for use in a delegate using the `-implementMethod:withBlock:`, `-blockImplementationForMethod:`, and `-removeBlockImplementationForMethod:` methods. Methods also exist for implementing class methods.

A2DynamicDelegate also implements three getters in a category on `NSObject` that generates a delegate object that facilitates calling the blocks you set.

After setting up a class' block properties using A2BlockDelegate, set the delegate of an instance using A2DynamicDelegate, like so:

	- (IBAction)annoyUser {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Hello World!" message: @"This alert's delegate is implemented using blocks. That's so cool!" delegate:nil cancelButtonTitle: @"Meh." otherButtonTitles: @"Woo!", nil];

	// Implement -alertViewShouldEnableFirstOtherButton:
		alertView.shouldEnableFirstOtherButtonBlock = ^(UIAlertView *alertView) {
			NSLog(@"Message: %@", alertView.message);
			return YES;
		};

	// Implement -alertView:willDismissWithButtonIndex:
		alertView.willDismissBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
			NSLog(@"You pushed button #%d (%@)", buttonIndex, [alertView buttonTitleAtIndex: buttonIndex]);
		};

		// Set the delegate
		alertView.delegate = alertView.dynamicDelegate;

		[alertView show];
	}

And, yeah, it works. Pretty neat, huh?

##### More information can be found in the *Demo* project.

## License

A2DynamicDelegate is created and maintained by Alex Akers. Derp derp derp derp derp derp derp. **More about your rights here.**