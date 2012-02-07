[BlocksKit](http://zwaldowski.github.com/BlocksKit)
===================================================

Blocks in C and Objective-C are downright magical.  They make coding easier and potentially quicker, not to mention faster on the front end with multithreading and Grand Central Dispatch.  BlocksKit hopes to facilitate this kind of programming by removing some of the annoying - and, in some cases, impeding - limits on coding with blocks.

BlocksKit is a framework and static library for iOS 4.0+ and Mac OS X 10.6+.

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

An Xcode 4 compatible documentation set is available [using this Atom link](http://zwaldowski.github.com/BlocksKit/com.dizzytechnology.BlocksKit.atom). You may also view the documentation [online](http://zwaldowski.github.com/BlocksKit/Documentation).

License
=======

BlocksKit is created and maintained by [Zachary Waldowski](https://github.com/zwaldowski) under the MIT license.  **The project itself is free for use in any and all projects.**  You can use BlocksKit in any project, public or private, with or without attribution.

Unsure about your rights?  [Read more.](http://zwaldowski.github.com/BlocksKit/index.html#license)

All of the included code is licensed either under BSD, MIT, or is in the public domain. A full list of contributors exists on the [project page](http://zwaldowski.github.com/BlocksKit/index.html#contributors). Individual credits exist in the header files and documentation. We thank them for their contributions to the open source community.