Overview
========

Blocks in C and Objective-C are downright magical.  They make coding easier and potentially quicker, not to mention faster on the front end with multithreading and Grand Central Dispatch.  BlocksKit hopes to facilitate this kind of programming by removing some of the annoying - and, in some cases, impeding - limits on coding with blocks.

BlocksKit is a static library for iOS 3.2 and up.  It can technically work on Mac OS X 10.6+ (with Chameleon for the UIKit stuff), but this project does not encompass that target at this time.

What's Included
===============

* Performing blocks on an `NSObject`.
* Key-value observation (`<NSKeyValueObserving>`) using a block handler
* Associated objects using an Obj-C API.  (Not directly block-related.)
* `NSArray`, `NSSet`, and `NSDictionary` filter utilities
* BKMacros, for more quickly typing out the above.
* `NSInvocation` creation using blocks
* `NSTimer` block execution
* `UIAlertView`, `UIActionSheet` with block callbacks
* Block initializers for `UIControl` and `UIBarButtonItem`
* Initializer for `UIGestureRecognizer`
* On-touch utilities for `UIView`.
* both delegation and block callbacks on `NSURLConnection`

Installation
============

* Clone the repository.
* In Xcode 4, click-and-drag (or add using File > Add Files to Project) the BlocksKit XCode project into a project or workspace.
* In the build phases of a target, add libBlocksKit.a to the "Target Dependencies" and "Link Binary with Libraries".
* In the build settings, change "All Linker Flags" to `-ObjC -all_load` and "Header Search Paths" to `$(BUILT_PRODUCTS_DIR)/../BlocksKit/**`.
* In any header file, insert `#import "BlocksKit/BlocksKit.h"`.  _This is a change from previous version._ It is not recommended to insert the import statement in your project prefix, as it will break Xcode 4's Code Sense for the entire project.


Documentation
=============

Documentation is exhaustive and done using [AppleDoc](https://github.com/tomaz/appledoc).  

An Xcode 4 compatible documentation set is available [using this Atom link](http://www.dizzytechnology.com/data/com.dizzytech.BlocksKit.atom).  Add it to Xcode 4's preferences and it'll download automatically.

You can also view the documentation online [at my website](http://dizzytechnology.com/data/BlocksKit).

License
=======

BlocksKit is created and maintained by Zachary Waldowski under the MIT license [(hello, nice to meet you)](https://github.com/zwaldowski).  All of the included code is licensed either under BSD, MIT, or is in the public domain.  The project itself is free for use in any and all projects.

Unsure about your rights?  [Read more.](http://www.opensource.org/licenses/mit-license.php)

Contributors
============

BlocksKit takes, repurposes, fiddles with, and groups together a variety of block-related code generally found here on GitHub.

The following people (in alphabetical order) have their code lovingly enshrined in BlocksKit:

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

Individual credits exist in the header files and, consequently, in the documentation.