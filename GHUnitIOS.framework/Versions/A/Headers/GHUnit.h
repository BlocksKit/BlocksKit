//
//  GHUnit.h
//  GHUnit
//
//  Created by Gabriel Handford on 1/19/09.
//  Copyright 2009. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "GHTestCase.h"
#import "GHAsyncTestCase.h"
#import "GHTestSuite.h"
#import "GHTestMacros.h"
#import "GHTestRunner.h"

#import "GHTest.h"
#import "GHTesting.h"
#import "GHTestOperation.h"
#import "GHTestGroup.h"
#import "GHTest+JUnitXML.h"
#import "GHTestGroup+JUnitXML.h"
#import "NSException+GHTestFailureExceptions.h"
#import "NSValue+GHValueFormatter.h"

#if TARGET_OS_IPHONE
#import "GHUnitIOSAppDelegate.h"
#endif

#ifdef DEBUG
#define GHUDebug(fmt, ...) do { \
fputs([[[NSString stringWithFormat:fmt, ##__VA_ARGS__] stringByAppendingString:@"\n"] UTF8String], stdout); \
} while(0)
#else
#define GHUDebug(fmt, ...) do {} while(0)
#endif

/*! 
 @mainpage GHUnit
 
 
 GHUnit is a test framework for Objective-C (Mac OS X 10.5 and above and iPhone 3.x and above).
 It can be used with SenTestingKit, GTM or all by itself. 
 
 For example, your test cases will be run if they subclass any of the following:
 
 - GHTestCase
 - SenTestCase
 - GTMTestCase
 
 
 Source: http://github.com/gabriel/gh-unit
 
 View docs online: http://gabriel.github.com/gh-unit/

 
 This manual is divided in the following sections:
 - @subpage Installing
 - @subpage Examples
 - @subpage CommandLine "Command Line & Makefiles"
 - @subpage TestMacros  
 - @subpage Building
 - @subpage EnvVariables 
 - @subpage Customizing
 - @subpage Hudson 
 
 
 @image html http://rel.me.s3.amazonaws.com/gh-unit/images/GHUnit-IPhone-0.4.18.png
 @image html http://rel.me.s3.amazonaws.com/gh-unit/images/GHUnit-0.4.18.png 
 
 @section Notes Notes
 
 GHUnit was inspired by and uses parts of GTM (google-toolbox-for-mac) code, mostly from UnitTesting: http://code.google.com/p/google-toolbox-for-mac/source/browse/trunk/UnitTesting/
 
 */
 
/*!
 @page Installing Installing
 
 @ref InstallingIOSXcode4
 
 @ref InstallMacOSXXcode4
 
 @subpage InstallingXcode3
 
 @section InstallingIOSXcode4 Installing in Xcode 4 (iOS)
 
 @subsection CreateTestTargetXcode4 Create a Test Target
 
 - You'll want to create a separate Test target. Select the project file for your app in the Project Navigator. From there, select the Add Target + symbol at the bottom of the window.
 
 @image html http://rel.me.s3.amazonaws.com/gh-unit/images/Installing/1_add_target.png
 
 - Select iOS, Application, Window-based Application. Select Next.
 
 @image html http://rel.me.s3.amazonaws.com/gh-unit/images/Installing/2_select_application.png
 
 - Name it Tests or something similar. Select Finish.
 
 @image html http://rel.me.s3.amazonaws.com/gh-unit/images/Installing/3_name_it.png
 
 @subsection ConfigureTestTargetXcode4 Configure the Test Target
 
 - Download and copy the GHUnitIOS.framework to your project. Command click on Frameworks in the Project Navigator and select: Add Files to "MyTestable"...
 
 @image html http://rel.me.s3.amazonaws.com/gh-unit/images/Installing/6_add_framework.png
 
 - Select GHUnitIOS.framework and make sure the only the Tests target is selected.
 
 @image html http://rel.me.s3.amazonaws.com/gh-unit/images/Installing/7_add_framework_dialog.png
 
 - We want to enable use of Objective-C categories, which isn't enabled for static libraries by default. In the Tests target, Build Settings, under Other Linker Flags, add <tt>-ObjC</tt> and <tt>-all_load</tt>.
 
 @image html http://rel.me.s3.amazonaws.com/gh-unit/images/Installing/8_other_linker_flags.png
 
 - Select and delete the files from the existing Tests folder. Leave the Supporting Files folder. GHUnit will provide the application delegate below.
 
 @image html http://rel.me.s3.amazonaws.com/gh-unit/images/Installing/9_remove_test_files.png
 
 - By default, the Tests-Info.plist file includes MainWindow_iPhone and MainWindow_iPad for Main nib file base name. You should remove both these fields.
 
 @image html http://rel.me.s3.amazonaws.com/gh-unit/images/Installing/9b_fix_plist.png
 
 - After removing these entries, the Tests-Info.plist should look like this.
 
 @image html http://rel.me.s3.amazonaws.com/gh-unit/images/Installing/9c_fixed_plist.png

 - In Tests folder, in Supporting Files, main.m, replace the last argument of UIApplicationMain with @"GHUnitIPhoneAppDelegate".
 
 @image html http://rel.me.s3.amazonaws.com/gh-unit/images/Installing/10_main.png
 
 - Select the Tests target, iPhone Simulator configuration:
 
 @image html http://rel.me.s3.amazonaws.com/gh-unit/images/Installing/11_select_target.png
 
 - Hit Run, and you'll hopefully see the test application running (but without any tests).
 
 @image html http://rel.me.s3.amazonaws.com/gh-unit/images/Installing/12_running.png
 
 @subsection CreateTestXcode4 Create a Test
 
 - Command click on the Tests folder and select: New File...
 - Under iOS, Cocoa Touch, select Objective-C class and select Next. Leave the default subclass and select Next again.
 - Name the file MyTest.m and make sure its enabled only for the "Tests" target.
 - Delete the MyTest.h file and replace the MyTest.m file with:
 
 @code
 #import <GHUnitIOS/GHUnit.h> 
 
 @interface MyTest : GHTestCase { }
 @end
 
 @implementation MyTest
 
 - (void)testStrings {       
   NSString *string1 = @"a string";
   GHTestLog(@"I can log to the GHUnit test console: %@", string1);
 
   // Assert string1 is not NULL, with no custom error description
   GHAssertNotNULL(string1, nil);
 
   // Assert equal objects, add custom error description
   NSString *string2 = @"a string";
   GHAssertEqualObjects(string1, string2, @"A custom error message. string1 should be equal to: %@.", string2);
 }
 
 @end
 @endcode
 
 @image html http://rel.me.s3.amazonaws.com/gh-unit/images/Installing/13_adding_test.png
 
 - Now run the "Tests" target. Hit the Run button in the top right.
 
 @image html http://rel.me.s3.amazonaws.com/gh-unit/images/Installing/14_running_with_test.png

 @subsection InstallWhatsNextXcode4 Whats next?
 
 There aren't any more steps required, but you might be interested in:
 
 - @ref Examples "More Examples"
 - @ref CommandLine "Running from the Command Line"
 - @ref Makefile "Install a Makefile"
 
 */
 
/*!
 @page InstallingXcode3 Installing in Xcode 3
 
 @section InstallingIOSXcode3 Installing in Xcode 3 (iOS)
 
 - Add a <tt>New Target</tt>. Select <tt>iOS -> Application</tt>. Name it <tt>Tests</tt> (or something similar).
 - Copy and add <tt>GHUnitIOS.framework</tt> into your project: Add Files to ..., select <tt>GHUnitIOS.framework</tt>, and select the <tt>Tests</tt> target.
 - Add the following frameworks to <tt>Linked Libraries</tt>:
    - <tt>GHUnitIOS.framework</tt>
    - <tt>CoreGraphics.framework</tt>
    - <tt>Foundation.framework</tt>
    - <tt>UIKit.framework</tt>
 - In Build Settings, under 'Framework Search Paths' make sure the (parent) directory to GHUnitIOS.framework is listed.
 - In Build Settings, under 'Other Linker Flags' in the <tt>Tests</tt> target, add <tt>-ObjC</tt> and <tt>-all_load</tt>
 - By default, the Tests-Info.plist file includes <tt>MainWindow</tt> for <tt>Main nib file base name</tt>. You should clear this field.
 - Add the GHUnitIOSTestMain.m (http://github.com/gabriel/gh-unit/blob/master/Project-iOS/GHUnitIOSTestMain.m) file into your project and make sure its enabled for the "Tests" target.
 - (Optional) Create and and set a prefix header (<tt>Tests_Prefix.pch</tt>) and add <tt>#import <GHUnitIOS/GHUnit.h></tt> to it, and then you won't have to include that import for every test.
 - @ref Examples "Create a test"
 - Build and run the "Tests" target.
 - (Optional) @ref Makefile "Install Makefile"
 
 
 @section InstallMacOSXXcode4 Installing in Xcode 4 (Mac OS X)
 
 - Add a <tt>New Target</tt>. Select <tt>Application -> Cocoa Application</tt>. Name it <tt>Tests</tt> (or something similar).
 - Copy and add <tt>GHUnit.framework</tt> into your project: Add Files to 'App'..., select <tt>GHUnit.framework</tt>, and select only the "Tests" target.
 - In the "Tests" target, in Build Settings, add <tt>@@loader_path/../Frameworks</tt> to <tt>Runpath Search Paths</tt>.
 - In the "Tests" target, in Build Phases, select <tt>Add Build Phase</tt> and then <tt>Add Copy Files</tt>. 
    - Change the Destination to <tt>Frameworks</tt>.
    - Drag <tt>GHUnit.framework</tt> from the project file view into the the Copy Files build phase.
    - Make sure the copy phase appears before any <tt>Run Script</tt> phases.
 - Copy GHUnitTestMain.m (http://github.com/gabriel/gh-unit/tree/master/Classes-MacOSX/GHUnitTestMain.m) into your project and include in the Test target. You should delete the existing main.m file (or replace the contents of the existing main.m with GHUnitTestMain.m).
 - By default, the Tests-Info.plist file includes <tt>MainWindow</tt> for <tt>Main nib file base name</tt>. You should clear this field. You can also delete the existing MainMenu.xib and files like TestsAppDelegate.*.
 - @ref Examples "Create a test"
 - Build and run the "Tests" target.
 - (Optional) @ref Makefile "Install Makefile"
 
 @section InstallMacOSXXcode3 Installing in Xcode 3 (Mac OS X)
 
 You can install it globally in /Library/Frameworks or with a little extra effort embed it with your project.
 
 @subsection InstallLibraryFrameworks Installing in /Library/Frameworks
 
 - Copy <tt>GHUnit.framework</tt> to <tt>/Library/Frameworks/</tt>
 - Add a <tt>New Target</tt>. Select <tt>Cocoa -> Application</tt>. Name it <tt>Tests</tt> (or something similar).
 - In the <tt>Target 'Tests' Info</tt> window, <tt>General</tt> tab:
    - Add a linked library, under <tt>Mac OS X 10.X SDK</tt> section, select <tt>GHUnit.framework</tt>
    - If your main target is a library: Add a linked library, and select your main target.
    - If your main target is an application, you will need to include these source files in the <tt>Test</tt> project manually. 
    - Add a direct dependency, and select your project. (This will cause your application or framework to build before the test target.)
 - Copy GHUnitTestMain.m (http://github.com/gabriel/gh-unit/tree/master/Classes-MacOSX/GHUnitTestMain.m) into your project and include in the Test target.
 - Now create a test (either by subclassing <tt>SenTestCase</tt> or <tt>GHTestCase</tt>), adding it to your test target. (See example test case below.)
 - By default, the Tests-Info.plist file includes <tt>MainWindow</tt> for <tt>Main nib file base name</tt>. You should clear this field.
 - @ref Examples "Create a test"
 - (Optional) @ref Makefile "Install Makefile"
 
 @subsection InstallProject Installing in your project
 
 - Add a <tt>New Target</tt>. Select <tt>Cocoa -> Application</tt>. Name it <tt>Tests</tt> (or something similar).
 - In the Finder, copy <tt>GHUnit.framework</tt> to your project directory (maybe in MyProject/Frameworks/.)
 - In the <tt>Tests</tt> target, add the <tt>GHUnit.framework</tt> files (from MyProject/Frameworks/). It should now be visible as a <tt>Linked Framework</tt> in the target. 
 - In the <tt>Tests</tt> target, under Build Settings, add <tt>@loader_path/../Frameworks</tt> to <tt>Runpath Search Paths</tt> (Under All Configurations)
 - In the <tt>Tests</tt> target, add <tt>New Build Phase</tt> | <tt>New Copy Files Build Phase</tt>. 
    - Change the Destination to <tt>Frameworks</tt>.
    - Drag <tt>GHUnit.framework</tt> into the the build phase
    - Make sure the copy phase appears before any <tt>Run Script</tt> phases 
 - Copy GHUnitTestMain.m (http://github.com/gabriel/gh-unit/tree/master/Classes-MacOSX/GHUnitTestMain.m) into your project and include in the Test target.
 
 - If your main target is a library: 
    - In the <tt>Target 'Tests' Info</tt> window, <tt>General</tt> tab: 
        - Add a linked library, and select your main target; This is so you can link your test target against your main target, and then you don't have to manually include source files in both targets.
 - If your main target is an application, you will need to include these source files to the <tt>Test</tt> project manually.
 
 - Now create a test (either by subclassing <tt>SenTestCase</tt> or <tt>GHTestCase</tt>), adding it to your test target. (See example test case below.)
 - By default, the Tests-Info.plist file includes <tt>MainWindow</tt> for <tt>Main nib file base name</tt>. You should clear this field.
 - @ref Examples "Create a test"
 - (Optional) @ref Makefile "Install Makefile"
 */
 
/*!
 @page Building Building
 
 For iOS, run <tt>make</tt> from within the <tt>Project-iOS</tt> directory. The framework is in <tt>Project-iOS/build/Framework/</tt>.
 
 For Mac OS X, the framework build is stored in <tt>Project/build/Release/</tt>.
 */

/*!
 @page Examples Examples
 
 - @ref ExampleTestCase
 - @ref ExampleAsyncTestCase
 
 @section ExampleTestCase Example Test Case
 
 For example <tt>ExampleTest.m</tt>:
 
 @code
 // For iOS
 #import <GHUnitIOS/GHUnit.h> 
 // For Mac OS X
 //#import <GHUnit/GHUnit.h>
 
 @interface ExampleTest : GHTestCase { }
 @end
 
 @implementation ExampleTest
 
 - (BOOL)shouldRunOnMainThread {
   // By default NO, but if you have a UI test or test dependent on running on the main thread return YES.
   // Also an async test that calls back on the main thread, you'll probably want to return YES.
   return NO;
 }
 
 - (void)setUpClass {
   // Run at start of all tests in the class
 }
 
 - (void)tearDownClass {
   // Run at end of all tests in the class
 }
 
 - (void)setUp {
   // Run before each test method
 }
 
 - (void)tearDown {
   // Run after each test method
 }	
 
 - (void)testFoo {       
   NSString *a = @"foo";
   GHTestLog(@"I can log to the GHUnit test console: %@", a);
 
   // Assert a is not NULL, with no custom error description
   GHAssertNotNULL(a, nil);
 
   // Assert equal objects, add custom error description
   NSString *b = @"bar";
   GHAssertEqualObjects(a, b, @"A custom error message. a should be equal to: %@.", b);
 }
 
 - (void)testBar {
   // Another test
 }
 
 @end
 @endcode
 
 @section ExampleAsyncTestCase Example Async Test Case
 
 @code
 // For iOS
 #import <GHUnitIOS/GHUnit.h> 
 // For Mac OS X
 //#import <GHUnit/GHUnit.h> 
 
 @interface ExampleAsyncTest : GHAsyncTestCase { }
 @end
 
 @implementation ExampleAsyncTest
  
 - (void)testURLConnection {
   
   // Call prepare to setup the asynchronous action.
   // This helps in cases where the action is synchronous and the
   // action occurs before the wait is actually called.
   [self prepare];

   NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]];
   NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];

   // Wait until notify called for timeout (seconds); If notify is not called with kGHUnitWaitStatusSuccess then
   // we will throw an error.
   [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];

   [connection release];
 }
 
 - (void)connectionDidFinishLoading:(NSURLConnection *)connection {
   // Notify of success, specifying the method where wait is called.
   // This prevents stray notifies from affecting other tests.
   [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testURLConnection)];
 }
 
 - (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
   // Notify of connection failure
   [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testURLConnection)];
 }
 
 - (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
   GHTestLog(@"%@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
 } 
 
 @end
 @endcode
 
 
 @section ExampleProjects Example Projects
 
 Example projects can be found at: http://github.com/gabriel/gh-unit/tree/master/Examples/ 
  
 */
 
/*!
 @page EnvVariables Environment Variables
 
 @section GHUnitEnvVariables GHUnit Environment Variables
 
 Go into the "Get Info" contextual menu of your (Tests) executable (inside the "Executables" group in the left panel of Xcode). 
 Then go in the "Arguments" tab. You can add the following environment variables:
 
 @verbatim
 GHUNIT_CLI - Default NO; Runs tests on the command line (see Debugger Console, Cmd-Shift-R)
 GHUNIT_RERAISE - Default NO; If an exception is encountered it re-raises it allowing you to crash into the debugger
 GHUNIT_AUTORUN - Default NO; If YES, tests will start automatically
 GHUNIT_AUTOEXIT - Default NO; If YES, will exit upon test completion (no matter what); For command line MacOSX testing
 @endverbatim
 
 
 @section EnvVariablesTest Test Environment Variables (Recommended)
 
 Go into the "Get Info" contextual menu of your (Tests) executable (inside the "Executables" group in the left panel of Xcode). 
 Then go in the "Arguments" tab. You can add the following environment variables:
 
 @verbatim
 Environment Variable:                 Default:  Set to:
 NSDebugEnabled                           NO       YES
 NSZombieEnabled                          NO       YES
 NSDeallocateZombies                      NO       NO (or YES)
 NSHangOnUncaughtException                NO       YES
 NSAutoreleaseFreedObjectCheckEnabled     NO       YES
 @endverbatim
 
 If Using NSDeallocateZombies=NO, then all objects will leak so be sure to turn it off when debugging memory leaks.
 
 For more info on these varaiables see NSDebug.h (http://theshadow.uw.hu/iPhoneSDKdoc/Foundation.framework/NSDebug.h.html)
 
 For malloc debugging:
 
 @verbatim
 MallocStackLogging
 MallocStackLoggingNoCompact
 MallocScribble
 MallocPreScribble
 MallocGuardEdges
 MallocDoNotProtectPrelude
 MallocDoNotProtectPostlude
 MallocCheckHeapStart
 MallocCheckHeapEach
 @endverbatim
 
 If you see a message like:
 
 @verbatim
 2009-10-15 13:02:24.746 Tests[38615:40b] *** -[Foo class]: message sent to deallocated instance 0x1c8e680
 @endverbatim
 
 Re-run (in gdb) with <tt>MallocStackLogging=YES</tt> (or <tt>MallocStackLoggingNoCompact=YES</tt>), then if you run under gdb:
 
 @verbatim
 (gdb) shell malloc_history 38615 0x1c8e680
 
 ALLOC 0x1a9ad10-0x1a9ad6f [size=96]: thread_a024a500 |start | main | UIApplicationMain | GSEventRun | GSEventRunModal | CFRunLoopRunInMode | CFRunLoopRunSpecific | __NSThreadPerformPerform | -[GHTestGroup _run:] | -[GHTest run] | +[GHTesting runTest:selector:withObject:exception:interval:] | -[Foo foo] | +[NSObject alloc] | +[NSObject allocWithZone:] | _internal_class_createInstance | _internal_class_createInstanceFromZone | calloc | malloc_zone_calloc 
 
 @endverbatim
 
 Somewhere between runTest and NSObject alloc (in [Foo foo]) there may be an object that wasn't retained. 38615 is the thread id from "2009-10-15 13:02:24.746 Tests[38615:40b]", and 0x1c8e680 is the  address in "message sent to deallocated instance 0x1c8e680".
 
 Also using <tt>MallocScribble=YES</tt> causes the malloc library to overwrite freed memory with a well-known value (0x55), and occasionally checks freed malloc blocks to make sure the memory has not been over-written overwritten written since it was cleared.
 
 For more info on these variables see MallocDebug (http://developer.apple.com/mac/library/documentation/Performance/Conceptual/ManagingMemory/Articles/MallocDebug.html)
 
 For more info on malloc_history see malloc_history (http://developer.apple.com/mac/library/documentation/Darwin/Reference/ManPages/man1/malloc_history.1.html)
 
 */

/*!
 
 @page CommandLine Command Line
 
 @section CommandLineRunningTests Running from the Command Line
 
 To run the tests from the command line:
 
 - Copy the RunTests.sh (http://github.com/gabriel/gh-unit/tree/master/Scripts/RunTests.sh) file into your project in the same directory as the xcodeproj file.
 
 - In the Tests target, Build Phases, Select Add Build Phase + button, and select Add Run Script.
 
 @image html http://rel.me.s3.amazonaws.com/gh-unit/images/RunningCLI/2_add_build_phase.png

 - For the script enter: <tt>sh RunTests.sh</tt>
 
 @image html http://rel.me.s3.amazonaws.com/gh-unit/images/RunningCLI/3_configure_phase.png
 
 The path to RunTests.sh should be relative to the xcode project file (.xcodeproj). You can uncheck 'Show environment variables in build log' if you want.
 
 - Now run the tests From the command line:
 
 @verbatim
 // For iOS app
 GHUNIT_CLI=1 xcodebuild -target Tests -configuration Debug -sdk iphonesimulator build
 
 // For mac app
 GHUNIT_CLI=1 xcodebuild -target Tests -configuration Debug -sdk macosx build	
 @endverbatim
 
 If you get and error like: <tt>Couldn't register Tests with the bootstrap server.</tt> it means an iPhone simulator is running and you need to close it.
 
 @subsection CommandLineEnv Command Line Environment
 
 The RunTests.sh script will only run the tests if the env variable GHUNIT_CLI is set. This is why this RunScript phase is ignored when running the test GUI. This is how we use a single Test target for both the GUI and command line testing.
 
 This may seem strange that we run via xcodebuild with a RunScript phase in order to work on the command line, but otherwise we may not have the environment settings or other Xcode specific configuration right.
 
 @section Makefile Makefile
 
 Follow the directions above for adding command line support.
 
 Example Makefile's for Mac or iPhone apps:
 
 - Makefile (Mac OS X): http://github.com/gabriel/gh-unit/tree/master/Project/Makefile.example (for a Mac App)
 - Makefile (iOS): http://github.com/gabriel/gh-unit/tree/master/Project-iOS/Makefile.example (for an iOS App)
 
 The script will return a non-zero exit code on test failure.
 
 To run the tests via the Makefile:
 
 @verbatim
 make test
 @endverbatim
 
 Unfortunately, running Mac OS X from the command line isn't always supported since certain frameworks can't work
 headless and will seg fault.
 
 @section RunningATest Running a Test Case / Single Test
 
 The <tt>TEST</tt> environment variable can be used to run a single test or test case.
 
 @verbatim
 // Run all tests in GHSlowTest
 make test TEST="GHSlowTest"
 
 // Run the method testSlowA in GHSlowTest	
 make test TEST="GHSlowTest/testSlowA"
 @endverbatim
 
 */

/*!
  
 @page TestMacros Test Macros
 
 The following test macros are included. 
 
 These macros are directly from: GTMSenTestCase.h (http://code.google.com/p/google-toolbox-for-mac/source/browse/trunk/UnitTesting/GTMSenTestCase.h)
 prefixed with GH so as not to conflict with the GTM macros if you are using those in your project.
 
 The <tt>description</tt> argument appends extra information for when the assert fails; though most of the time you might leave it as nil.
 
 @code
 GHAssertNoErr(a1, description, ...)
 GHAssertErr(a1, a2, description, ...)
 GHAssertNotNULL(a1, description, ...)
 GHAssertNULL(a1, description, ...)
 GHAssertNotEquals(a1, a2, description, ...)
 GHAssertNotEqualObjects(a1, a2, desc, ...)
 GHAssertOperation(a1, a2, op, description, ...)
 GHAssertGreaterThan(a1, a2, description, ...)
 GHAssertGreaterThanOrEqual(a1, a2, description, ...)
 GHAssertLessThan(a1, a2, description, ...)
 GHAssertLessThanOrEqual(a1, a2, description, ...)
 GHAssertEqualStrings(a1, a2, description, ...)
 GHAssertNotEqualStrings(a1, a2, description, ...)
 GHAssertEqualCStrings(a1, a2, description, ...)
 GHAssertNotEqualCStrings(a1, a2, description, ...)
 GHAssertEqualObjects(a1, a2, description, ...)
 GHAssertEquals(a1, a2, description, ...)
 GHAbsoluteDifference(left,right) (MAX(left,right)-MIN(left,right))
 GHAssertEqualsWithAccuracy(a1, a2, accuracy, description, ...)
 GHFail(description, ...)
 GHAssertNil(a1, description, ...)
 GHAssertNotNil(a1, description, ...)
 GHAssertTrue(expr, description, ...)
 GHAssertTrueNoThrow(expr, description, ...)
 GHAssertFalse(expr, description, ...)
 GHAssertFalseNoThrow(expr, description, ...)
 GHAssertThrows(expr, description, ...)
 GHAssertThrowsSpecific(expr, specificException, description, ...)
 GHAssertThrowsSpecificNamed(expr, specificException, aName, description, ...)
 GHAssertNoThrow(expr, description, ...)
 GHAssertNoThrowSpecific(expr, specificException, description, ...)
 GHAssertNoThrowSpecificNamed(expr, specificException, aName, description, ...)
 @endcode

 */
 
/*!
 
 @page Customizing Customizing
 
 @section CustomTests Custom Test Case Classes
 
 You can register additional classes at runtime; if you have your own. For example:
 
 @code
 [[GHTesting sharedInstance] registerClassName:@"MySpecialTestCase"];
 @endcode 
 
 @section AlternateIOSAppDelegate Using an Alternate iOS Application Delegate
 
 If you want to use a custom application delegate in your test environment, you should subclass GHUnitIOSAppDelegate:
 
 @code
 @interface MyTestApplicationDelegate : GHUnitIOSAppDelegate { }
 @end
 @endcode
 
 Then in GHUnitIOSTestMain.m:
 
 @code
 retVal = UIApplicationMain(argc, argv, nil, @"MyTestApplicationDelegate");
 @endcode
 
 I am looking into removing this dependency but this will work in the meantime.
 
 @section UsingSenTesting Using SenTestingKit
 
 You can also use GHUnit with SenTestCase, for example:
 
 @code
 #import <SenTestingKit/SenTestingKit.h>
 
 @interface MyTest : SenTestCase { }
 @end
 
 @implementation MyTest
 
 - (void)setUp {
   // Run before each test method
 }
 
 - (void)tearDown {
   // Run after each test method
 }
 
 - (void)testFoo {
   // Assert a is not NULL, with no custom error description
   STAssertNotNULL(a, nil);
 
   // Assert equal objects, add custom error description
   STAssertEqualObjects(a, b, @"Foo should be equal to: %@. Something bad happened", bar);
 }
 
 - (void)testBar {
   // Another test
 }
 
 @end
 @endcode

 */
 
/*!
 
 @page Hudson Hudson
 
 @section Using Using Hudson with GHUnit
 
 Hudson (http://hudson-ci.org/) is a continuous
 integration server that has a broad set of support and plugins, and is easy to set up. You
 can use Hudson to run your GHUnit tests after every checkin, and report the
 results to your development group in a variety of ways (by email, to Campfire,
 and so on).
 
 Here's how to set up Hudson with GHUnit.
 
 1. Follow the instructions to set up a Makefile for your GHUnit project.
 
 2. Download <tt>hudson.war</tt> from http://hudson-ci.org/.
 Run it with <tt>java -jar hudson.war</tt>. It will start up on 
 http://localhost:8080/
 
 3. Go to <tt>Manage Hudson -> Manage Plugins</tt> and install whatever plugins you
 need for your project.  For instance, you might want to install the Git 
 and GitHub plugins if you host your code on GitHub (http://www.github.com)
 
 4. Create a new job for your project and click on <tt>Configure</tt>. Most of the options
 are self-explanatory or can be figured out with the online help. You probably
 want to configure <tt>Source Code Management</tt>, and then under <tt>Build Triggers</tt> check
 <tt>Poll SCM</tt> and add a schedule of <tt>* * * * *</tt> (which checks your source control
 system for new changes once a minute).
 
 5. Under <tt>Build</tt>, enter the following command:
 
 @verbatim
 make clean && WRITE_JUNIT_XML=YES make test
 @endverbatim
 
 6. Under <tt/>Post-build Actions</tt>, check <tt/>Publish JUnit test result report</tt> and enter
 the following in <tt>Test report XMLs</tt>:
 
 @verbatim
 build/test-results/ *.xml     (Remove the extra-space, which is there to work around doxygen bug)
 @endverbatim
 
 That's all it takes. Check in a change that breaks one of your tests. Hudson
 should detect the change, run a build and test, and then report the failure.
 Fix the test, check in again, and you should see a successful build report.
 
 @section Troubleshooting Troubleshooting
 
 If your Xcode build fails with a set of font-related errors, you may be running
 Hudson headless (e.g., via an SSH session). Launch Hudson via Terminal.app on 
 the build machine (or otherwise attach a DISPLAY to the session) in order to 
 address this.   
  
 */
 