# A2DynamicDelegate

## Overview

Many programming languages (e.g. Ruby, Python, Lisp) conceptualize a reusable self-contained "unit of work" to simplify context and scope. In these languages, they are called "closures" or "lambdas." Since OS X 10.6 and iOS 4.0, Objective-C (as well as C and C++) developers have their own: blocks.

Whereas functions have to be defined in a static or global scope, blocks can be defined inline, allowing a block to utilize variables in its local scope. Apple Developer clarifies this in its [_A Short Practical Guide to Blocks_](http://developer.apple.com/library/ios/featuredarticles/Short_Practical_Guide_Blocks/):

> An even more valuable advantage of blocks over other forms of callback is that a block shares data in the local lexical scope. If you implement a method and in that method define a block, the block has access to the local variables and parameters of the method (including stack variables) as well as to functions and global variables, including instance variables.

There are many places in Objective-C where blocks make more sense than methods for delegation or simplistic function-like callbacks. While Apple is slowly migrating toward block callbacks (at the typically glacial pace of OS frameworks), A2DynamicDelegate serves to help bridge this gap by dynamically implementing protocol methods with blocks and creating block properties that do the same.

For the same reason that blocks are better than functions because they can take advantage of its declaring scope, a dynamic (block-implemented) delegate is better than a normal delegate. Instead of having to set an instance or static variable for every piece of data that you want to pass between a creating a delegating object and receiving delegate methods, you can access them directly from the block.

## Features

* **A2DynamicDelegate**: Implement a class's delegate, datasource, or other delegated protocol by associating protocol methods with block implementations.
* **A2BlockDelegate**: Create custom block properties in a category on a delegating object and dynamically map them to delegate (`UIAlertViewDelegate`), datasource (`UITableViewDataSource`), or other delegated protocol (`NSErrorRecoveryAttempting`) methods.

## Getting Started

A2DynamicDelegate is made up of six files: _A2DynamicDelegate.{h,m}_, _A2BlockDelegate.{h,m}_, and _A2BlockClosure.{h,m}_. It also depends on [_libffi_](https://github.com/atgreen/libffi), a copy of which is included in the binary releases.

For the sake of convenience, you can either build the **iOS Library** target or download a binary release and use the `libA2DynamicDelegate.a` static library in place of the _.m_ source files. This is useful for projects that use ARC because A2DynamicDelegate does not support it. (See below.)

1. Copy the included files to your Xcode project.
2. Implement protocol methods with blocks.
3. (Optional) Look at how much simpler your code is.

## A2DynamicDelegate

Implement a class's delegate, datasource, or other delegated protocol by associating protocol methods with block implementations.

### Getting an `A2DynamicDelegate` Instance

To get the dynamic delegate for an object, use one of the three getters defined in `NSObject(A2DynamicDelegate)`. 

* `-dynamicDataSource` assumes protocol `FooBarDataSource` for instances of class `FooBar`.
* `-dynamicDelegate` assumes protocol `FooBarDelegate` for instances of class `FooBar`.
* `-dynamicDelegateForProtocol:` receives protocol explicitly.

#### Why can't I just alloc-init an `A2DynamicDelegate` instance?

Calling one of the above methods allows us to storing the dynamic delegate as an associated object of the delegating object. This not only allows us to later retrieve the delegate, but it also creates a strong relationship to the delegate. Since delegates are weak references on the part of the delegating object, a dynamic delegate would be deallocated immediately after its declaring scope ends. Therefore, this strong relationship is required to ensure that the delegate's lifetime is at least as long as that of the delegating object.

### Usage

A dynamic delegate instance automatically implements protocol methods using the following methods:

- `-implementMethod:withBlock:`: Implement a protocol method.
- `-blockImplementationForMethod:`: Get block implementation. (Can also be used to check if method has block implementation.)
- `-removeBlockImplementationForMethod:`: Remove block implementation for protocol method. methods.

Methods also exist for implementing class methods.

### Example

	- (IBAction) annoyUser
	{
		// Create an alert view
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Hello World!" message: @"This alert's delegate is implemented using blocks. That's so cool!" delegate: nil cancelButtonTitle: @"Meh." otherButtonTitles: @"Woo!", nil];

		// Get the dynamic delegate
		A2DynamicDelegate *dd = alertView.dynamicDelegate;
		
		// Implement -alertViewShouldEnableFirstOtherButton:
		[dd implementMethod: @selector(alertViewShouldEnableFirstOtherButton:) withBlock: ^(UIAlertView *alertView) {
			NSLog(@"Message: %@", alertView.message);
			return YES;
		}];

		// Implement -alertView:willDismissWithButtonIndex:
		[dd implementMethod: @selector(alertView:willDismissWithButtonIndex:) withBlock: ^(UIAlertView *alertView, NSInteger buttonIndex) {
			NSLog(@"You pushed button #%d (%@)", buttonIndex, [alertView buttonTitleAtIndex: buttonIndex]);
		}];

		// Set the delegate
		alertView.delegate = dd;

		[alertView show];
		[alertView release];
	}

A2DynamicDelegate is designed to be 'plug and play'. It just works. Pretty neat, huh?

*Dont't forget to check out the Demo project.*

### Advanced Example

The dynamic delegate returned from one of the `-dynamic*` methods is actually part of a class cluster. For a dynamic delegate for protocol `UIAlertViewDelegate`, the following chain is produced:

* `A2DynamicDelegate`
* `A2DynamicUIAlertViewDelegate`
* `A2DynamicUIAlertViewDelegate/983C3E20-285D-11E1-BFC2-0800200C9A66`

Therefore, you can actually create a subclass of A2DynamicDelegate in order to provide custom handling.

**UIAlertView+A2DynamicDelegate.h**:

	#import <dispatch/dispatch.h> // typedef void (^dispatch_block_t)(void);
	
	@interface UIAlertView (A2DynamicDelegate)
	
	- (NSInteger) addButtonWithTitle: (NSString *) title handler: (dispatch_block_t) block;
	- (dispatch_block_t) handlerForButtonAtIndex: (NSInteger) index;
	
	@end
	
	@interface A2DynamicUIAlertViewDelegate : A2DynamicDelegate
	
	@end

**UIAlertView+A2DynamicDelegate.m**:

	@interface UIAlertView (A2DynamicDelegate)
	
	- (NSInteger) addButtonWithTitle: (NSString *) title handler: (dispatch_block_t) block
	{
		NSInteger index = [self addButtonWithTitle: title];
		id key = [NSNumber numberWithInteger: index];
		
		if (block)
			[self.dynamicDelegate.handlers setObject: block forKey: key];
		else
			[self.dynamicDelegate.handlers removeObjectForKey: key];
		
		return index;
	}
	- (dispatch_block_t) handlerForButtonAtIndex: (NSInteger) index
	{
		id key = [NSNumber numberWithInteger: index];
		return [self.dynamicDelegate.handlers objectForKey: key];
	}
	
	@end
	
	@implementation A2DynamicUIAlertViewDelegate
	
	- (void) alertView: (UIAlertView *) alertView clickedButtonAtIndex: (NSInteger) buttonIndex
	{
		id key = [NSNumber numberWithInteger: buttonIndex];
		dispatch_block_t block = [self.handlers objectForKey: key];
		if (block) block();
		
		void (^buttonClicked)(UIAlertView *, NSInteger) = [self blockImplementationForMethod: _cmd];
		if (buttonClicked) buttonClicked(alertView, buttonIndex);
	}

	@end

## A2BlockDelegate

Create custom block properties in a category on a delegating object and dynamically map them to delegate (`UIAlertViewDelegate`), datasource (`UITableViewDataSource`), or other delegated protocol (`NSErrorRecoveryAttempting`) methods.

### Usage

Call one of the methods in the `A2BlockDelegate` category on a class to add a block property to that class.

Just like A2DynamicDelegate, A2BlockDelegate 
A2BlockDelegate automatically guesses which protocol to use for the implementation. A data source protocol (i.e. `FooDataSource` over `FooDelegate`) can be used using `+linkCategoryBlockProperty:withDataSourceMethod:` or `+linkDataSourceMethods:`. One can manually be specified using `+linkCategoryBlockProperty:withProtocol:method:` or `+linkProtocol:methods:`. 

* Data Source: Assumes protocol `FooBarDataSource` for class `FooBar`
    * `+linkCategoryBlockProperty:withDataSourceMethod:`
    * `+linkDataSourceMethods:`
* Delegate: Assumes protocol `FooBarDelegate` for instances of class `FooBar`
	* `+linkCategoryBlockProperty:withDelegateMethod`
	* `+linkDelegateMethods:`
* Explicit Protocol
	* `+linkCategoryBlockProperty:withProtocol:method:`
	* `+linkProtocol:methods:`

These methods should be called in a category's `+load` method, before the application starts. Unlike `+initialize` which is only called once and should not be overwritten in a category, `+load` is called on all classes and categories before `main()` is called.

### Example

**UIAlertView+A2BlockDelegate.h**:

	@interface UIAlertView (A2BlockDelegate)
	
	// Block properties must be (nonatomic, copy).
	@property (nonatomic, copy) BOOL (^shouldEnableFirstOtherButtonBlock)(UIAlertView *);
	@property (nonatomic, copy) void (^willDismissBlock)(UIAlertView *, NSInteger);
	
	@end

**UIAlertView+A2BlockDelegate.m**:

	@implementation UIAlertView (A2BlockDelegate)
	
	// Block properties must be dynamic. This means that the accessors
	// are provided at runtime (in this case, by A2BlockDelegate).
	
	@dynamic shouldEnableFirstOtherButtonBlock;
	@dynamic willDismissBlock;
	
	+ (void) load
	{
		/**
		 * In older code, this would be:
		 *
		 *    NSAutoreleasePool *pool = [NSAutoreleasePool new];
		 *    /* ... Code ... */
		 *    [pool release];
		 *
		 **/
		
		@autoreleasepool
		{
			[self linkCategoryBlockProperty: @"shouldEnableFirstOtherButtonBlock" withDelegateMethod: @selector(alertViewShouldEnableFirstOtherButton:)];
			[self linkCategoryBlockProperty: @"willDismissBlock" withDelegateMethod: @selector(alertView:willDismissWithButtonIndex:)];
		}
	}

	@end

Or, alternatively, do it using a dictionary:

	NSDictionary *methods = [NSDictionary dictionaryWithObjectsAndKeys:
							 @"shouldEnableFirstOtherButtonBlock", @"alertViewShouldEnableFirstOtherButton:",
							 @"willDismissBlock", @"alertView:willDismissWithButtonIndex:", nil];
	[self linkDelegateMethods: methods];

**Somewhere*:

	- (IBAction) annoyUser
	{
		// Create an alert view
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Hello World!" message: @"This alert's delegate is implemented using blocks. That's so cool!" delegate: nil cancelButtonTitle: @"Meh." otherButtonTitles: @"Woo!", nil];

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
		[alertView release];
	}


## A2DynamicDelegate and ARC

**What is ARC?** Automatic Reference Counting (or ARC) for Objective-C makes memory management the job of the compiler.

**A2DynamicDelegate does not support ARC.**  As a precaution, there is a `#error` compiler directive in each _.m_ file if it compiled with ARC. Without these precautions, the implementations will build without errors, your application will crash at runtime if A2DynamicDelegate is used.

**This is limitation of the Objective-C runtime library.** The `objc_allocateClassPair` function used by A2DynamicDelegate crashes with an `EXC_BAD_ACCESS` exception if called under ARC.

## License

A2DynamicDelegate is licensed by [Alexsander Akers](http://alexsander.ca) and [Pandamonia LLC](http://pandamonia.us) under the Simplified BSD License, which is reproduced in its entirety here:

> Copyright (c) 2011, Alexsander Akers
> All rights reserved.
> 
> Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
> 
> - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
> - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
> 
> THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.