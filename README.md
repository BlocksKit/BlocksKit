[BlocksKit](http://pandamonia.github.com/BlocksKit)
===================================================

Blocks in C and Objective-C are downright magical.  They make coding easier and potentially quicker, not to mention faster on the front end with multithreading and Grand Central Dispatch.  BlocksKit hopes to facilitate this kind of programming by removing some of the annoying - and, in some cases, impeding - limits on coding with blocks.

BlocksKit is a framework for OS X Lion and newer and a static library for iOS 5 and newer.

Installation
============

BlocksKit can be added to a project using [CocoaPods](https://github.com/cocoapods/cocoapods). We also distribute a static library build.

### Library

* Download a release of BlocksKit.
* Download [libffi](https://github.com/pandamonia/libffi-iOS/archive/master.zip) and extract contents to BlocksKit/libffi/
* Run "Archive" in XCode.
* By default the static library will be compiled to `~/Library/Developer/Xcode/DerivedData`.
* Move libBlocksKit.a and Headers to your project's folder, preferably a subfolder like "Vendor".
* In "Build Phases", Drag libBlocksKit.a into your target's "Link Binary With Libraries" build phase. 
* In the build settings of your target or project, change "Other Linker Flags" to `-ObjC -all_load`. Make sure your app is linked with CoreGraphics, Foundation, MessageUI, and UIKit.
* Change (or add) to "Header Search Paths" the relative path to BlocksKit's headers, like `$(SRCROOT)/Vendor/Headers`.
* Insert `#import <BlocksKit/BlocksKit.h>` in your project's prefix header.

Documentation
=============

An Xcode 4 compatible documentation set is available [using this Atom link](http://pandamonia.github.com/BlocksKit/us.pandamonia.BlocksKit.atom). You may also view the documentation [online](http://pandamonia.github.com/BlocksKit/Documentation).

License
=======

BlocksKit is created and maintained by [Pandamonia LLC](https://github.com/pandamonia) under the MIT license.  **The project itself is free for use in any and all projects.**  You can use BlocksKit in any project, public or private, with or without attribution - though we prefer attribution! It helps us.

Unsure about your rights?  [Read more.](http://pandamonia.github.com/BlocksKit/index.html#license)

Individual credits for included code exist in the header files and documentation. We thank them for their contributions to the open source community.
