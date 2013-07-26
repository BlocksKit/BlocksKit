//
//  BlocksKit
//
//  The Objective-C block utilities you always wish you had.
//
//  Copyright (c) 2011-2012 Pandamonia LLC.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <BlocksKit/NSArray+BlocksKit.h>
#import <BlocksKit/NSDictionary+BlocksKit.h>
#import <BlocksKit/NSIndexSet+BlocksKit.h>
#import <BlocksKit/NSInvocation+BlocksKit.h>
#import <BlocksKit/NSMutableArray+BlocksKit.h>
#import <BlocksKit/NSMutableDictionary+BlocksKit.h>
#import <BlocksKit/NSMutableIndexSet+BlocksKit.h>
#import <BlocksKit/NSMutableOrderedSet+BlocksKit.h>
#import <BlocksKit/NSMutableSet+BlocksKit.h>
#import <BlocksKit/NSObject+BKAssociatedObjects.h>
#import <BlocksKit/NSObject+BKBlockExecution.h>
#import <BlocksKit/NSObject+BKBlockObservation.h>
#import <BlocksKit/NSOrderedSet+BlocksKit.h>
#import <BlocksKit/NSSet+BlocksKit.h>
#import <BlocksKit/NSTimer+BlocksKit.h>

#import "BKGlobals.h"

#import "BKMacros.h"

#import "NSObject+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"
#import "NSObject+BlockObservation.h"

#import "NSArray+BlocksKit.h"
#import "NSMutableArray+BlocksKit.h"
#import "NSSet+BlocksKit.h"
#import "NSMutableSet+BlocksKit.h"
#import "NSDictionary+BlocksKit.h"
#import "NSMutableDictionary+BlocksKit.h"
#import "NSIndexSet+BlocksKit.h"
#import "NSMutableIndexSet+BlocksKit.h"
#import "NSOrderedSet+BlocksKit.h"
#import "NSMutableOrderedSet+BlocksKit.h"

#import "NSInvocation+BlocksKit.h"
#import "NSTimer+BlocksKit.h"

#import "NSURLConnection+BlocksKit.h"
#import "NSCache+BlocksKit.h"

#if BK_HAS_UIKIT
#import "UIAlertView+BlocksKit.h"
#import "UIActionSheet+BlocksKit.h"
#import "UIBarButtonItem+BlocksKit.h"
#import "UIControl+BlocksKit.h"
#import "UIGestureRecognizer+BlocksKit.h"
#import "UIPopoverController+BlocksKit.h"
#import "UITextField+BlocksKit.h"
#import "UIView+BlocksKit.h"
#import "UIWebView+BlocksKit.h"
#import "MFMailComposeViewController+BlocksKit.h"
#import "MFMessageComposeViewController+BlocksKit.h"
#else
// AppKit extensions
#endif
