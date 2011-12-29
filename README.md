Overview
========

Blocks in C and Objective-C are downright magical.  They make coding easier and potentially quicker, not to mention faster on the front end with multithreading and Grand Central Dispatch.  BlocksKit hopes to facilitate this kind of programming by removing some of the annoying - and, in some cases, impeding - limits on coding with blocks.

BlocksKit is a framework andr static library for iOS 4.0+ and Mac OS X 10.6+.

What's In The Box
=================

* Performing blocks on an `NSObject`, with or without delay.
* Key-value observation (`<NSKeyValueObserving>`) with block handlers.
* Associated objects in an Obj-C API.  (Not directly block-related.)
* `NSArray`, `NSSet`, `NSDictionary`, and `NSIndexSet` filtering and enumeration.
* Filtering for mutable collections.
* `NSInvocation` creation using a block.
* `NSTimer` block execution.
* Both delegation and block callbacks on `NSURLConnection`.
* Delegate callback for `NSCache`.

### UIKit Extensions

* `UIAlertView`, `UIActionSheet` with block callbacks and convenience methods.
* Block initializers for `UIControl` and `UIBarButtonItem`.
* Block initializers for `UIGestureRecognizer`.
* On-touch utilities for `UIView`.
* Block callbacks for `MFMailComposeViewController` and `MFMessageComposeViewController`.
* Delegate alternative for `UIWebView`.

Installation
============

BlocksKit can be added to a project using [CocoaPods](https://github.com/alloy/cocoapods).

### Framework

* Download a release of BlocksKit.
* Move BlocksKit.framework to your project's folder.  Drag it from there into your project.
* Add BlocksKit.framework to "Link Binary With Libraries" in your app's target. Make sure your app is linked with CoreGraphics, Foundation, MessageUI, and UIKit.
* In the build settings of your target or project, change "Other Linker Flags" (`OTHER_LDFLAGS`) to `-ObjC -all_load`.
* Insert `#import <BlocksKit/BlocksKit.h>` in your project's prefix header.
* Make amazing software.

### Library

* Download a release of BlocksKit.
* Move libBlocksKit.a and Headers to your project's folder, preferably a subfolder like "Vendor".
* In "Build Phases", Drag libBlocksKit.a into your target's "Link Binary With Libraries" build phase. 
* In the build settings of your target or project, change "Other Linker Flags" to `-ObjC -all_load`. Make sure your app is linked with CoreGraphics, Foundation, MessageUI, and UIKit.
* Change (or add) to "Header Search Paths" the relative path to BlocksKit's headers, like `$(SRCROOT)/Vendor/Headers`.
* Insert `#import <BlocksKit/BlocksKit.h>`` in your project's prefix header.

Documentation
=============

Documentation is exhaustive and done using [AppleDoc](https://github.com/tomaz/appledoc).  

An Xcode 4 compatible documentation set is available [using this Atom link](http://www.dizzytechnology.com/data/com.dizzytech.BlocksKit.atom).  Add it to Xcode 4's preferences and it'll download automatically.

You can also view the documentation online [at my website](http://dizzytechnology.com/data/BlocksKit).

License
=======

BlocksKit is created and maintained by Zachary Waldowski under the MIT license [(hello, nice to meet you)](https://github.com/zwaldowski).  All of the included code is licensed either under BSD, MIT, or is in the public domain.  **The project itself is free for use in any and all projects.**  You can use BlocksKit in any project, public or private, with or without attribution.

Unsure about your rights?  [Read more.](http://www.opensource.org/licenses/mit-license.php)

Contributors
============

BlocksKit takes, repurposes, fiddles with, and groups together a variety of block-related code generally found here on GitHub.

The following people (in alphabetical order) have their code lovingly enshrined in BlocksKit:

* [Alexsander Akers](https://github.com/pandamonia).
* [Michael Ash](https://github.com/mikeash).
* [Jiva DeVoe](https://github.com/jivadevoe).
* [Igor Evsukov](https://github.com/evsukov89).
* [Corey Floyd](https://github.com/coreyfloyd).
* [Landon Fuller](http://plausiblelabs.com).
* [Mirko Kiefer](https://github.com/mirkok).
* [Robin Lu](https://github.com/robin).
* [Jake Marsh](https://github.com/jakemarsh).
* [Andy Matuschak](https://github.com/andymatuschak).
* [Aleks Nesterow](https://github.com/nesterow).
* [Kevin O'Neill](https://github.com/kevinoneill).
* [Jonathan Rentzch](https://github.com/rentzch).
* [Peter Steinberger](https://github.com/steipete).
* [Jon Sterling](https://github.com/jonsterling).
* [Martin Schürrer](https://github.com/MSch).
* [Jonathan Wight](https://github.com/schwa).

Individual credits exist in the header files and documentation.