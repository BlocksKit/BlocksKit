#
#  BlocksKit
#
#  The Objective-C block utilities you always wish you had.
#
#  Copyright (c) 2011-2012, 2013-2014 Zachary Waldowski
#  Copyright (c) 2012-2013 Pandamonia LLC
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.
#

SHELL = /bin/bash -e -o pipefail
IPHONE32 = -scheme 'BlocksKit iOS Legacy' -sdk iphonesimulator -destination 'name=iPhone Retina (4-inch)'
IPHONE64 = -scheme 'BlocksKit iOS Legacy' -sdk iphonesimulator -destination 'name=iPhone Retina (4-inch 64-bit)'
MACOSX = -scheme 'BlocksKit Mac' -sdk macosx
XCODEBUILD = xcodebuild -project BlocksKit.xcodeproj

default: clean ios macosx

clean:
	$(XCODEBUILD) clean

ios:
	$(XCODEBUILD) -scheme 'BlocksKit iOS Legacy' build

macosx:
	$(XCODEBUILD) -scheme 'BlocksKit Mac' build

test: test-iphone32 test-iphone64 test-macosx

test-iphone32:
	$(XCODEBUILD) $(IPHONE32) test | xcpretty -c

test-iphone64:
	$(XCODEBUILD) $(IPHONE64) test | xcpretty -c

test-macosx:
	$(XCODEBUILD) $(MACOSX) test | xcpretty -c

ci: test
