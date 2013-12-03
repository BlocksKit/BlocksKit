//
//  A2DynamicTestClasses+A2BlockDelegate.m
//  BlocksKit
//
//  Created by Zach Waldowski on 12/3/13.
//
//

#import "A2DynamicTestClasses+A2BlockDelegate.h"
#import "NSObject+A2BlockDelegate.h"

@implementation TestReturnObject (A2BlockDelegate)

@dynamic testReturnObjectBlock;

+ (void)load {
	@autoreleasepool {
		[self bk_linkDelegateMethods:@{ @"testReturnObjectBlock": @"testReturnObject" }];
	}
}

@end

#pragma mark -

@implementation TestReturnStruct (A2BlockDelegate)

@dynamic testReturnStructBlock;

+ (void)load {
	@autoreleasepool {
		[self bk_linkDelegateMethods:@{ @"testReturnStructBlock": @"testReturnStruct" }];
	}
}

@end

#pragma mark -

@implementation TestPassObject (A2BlockDelegate)

@dynamic testWithObjectBlock;

+ (void)load {
	@autoreleasepool {
		[self bk_linkDelegateMethods:@{ @"testWithObjectBlock": @"testWithObject:" }];
	}
}

@end

#pragma mark -

@implementation TestPassChar (A2BlockDelegate)

@dynamic testWithCharBlock;

+ (void)load {
	@autoreleasepool {
		[self bk_linkDelegateMethods:@{ @"testWithCharBlock": @"testWithChar:" }];
	}
}

@end

#pragma mark -

@implementation TestPassUChar (A2BlockDelegate)

@dynamic testWithUCharBlock;

+ (void)load {
	@autoreleasepool {
		[self bk_linkDelegateMethods:@{ @"testWithUCharBlock": @"testWithUChar:" }];
	}
}

@end

#pragma mark -

@implementation TestPassShort (A2BlockDelegate)

@dynamic testWithShortBlock;

+ (void)load {
	@autoreleasepool {
		[self bk_linkDelegateMethods:@{ @"testWithShortBlock": @"testWithShort:" }];
	}
}

@end

#pragma mark -

@implementation TestPassUShort (A2BlockDelegate)

@dynamic testWithUShortBlock;

+ (void)load {
	@autoreleasepool {
		[self bk_linkDelegateMethods:@{ @"testWithUShortBlock": @"testWithUShort:" }];
	}
}

@end

#pragma mark -

@implementation TestPassInt (A2BlockDelegate)

@dynamic testWithIntBlock;

+ (void)load {
	@autoreleasepool {
		[self bk_linkDelegateMethods:@{ @"testWithIntBlock": @"testWithInt:" }];
	}
}

@end

#pragma mark -

@implementation TestPassUInt (A2BlockDelegate)

@dynamic testWithUIntBlock;

+ (void)load {
	@autoreleasepool {
		[self bk_linkDelegateMethods:@{ @"testWithUIntBlock": @"testWithUInt:" }];
	}
}

@end

#pragma mark -

@implementation TestPassLong (A2BlockDelegate)

@dynamic testWithLongBlock;

+ (void)load {
	@autoreleasepool {
		[self bk_linkDelegateMethods:@{ @"testWithLongBlock": @"testWithLong:" }];
	}
}

@end

#pragma mark -

@implementation TestPassULong (A2BlockDelegate)

@dynamic testWithULongBlock;

+ (void)load {
	@autoreleasepool {
		[self bk_linkDelegateMethods:@{ @"testWithULongBlock": @"testWithULong:" }];
	}
}

@end

#pragma mark -

@implementation TestPassLongLong (A2BlockDelegate)

@dynamic testWithLongLongBlock;

+ (void)load {
	@autoreleasepool {
		[self bk_linkDelegateMethods:@{ @"testWithLongLongBlock": @"testWithLongLong:" }];
	}
}

@end

#pragma mark -

@implementation TestPassULongLong (A2BlockDelegate)

@dynamic testWithULongLongBlock;

+ (void)load {
	@autoreleasepool {
		[self bk_linkDelegateMethods:@{ @"testWithULongLongBlock": @"testWithULongLong:" }];
	}
}

@end

#pragma mark -

@implementation TestPassFloat (A2BlockDelegate)

@dynamic testWithFloatBlock;

+ (void)load {
	@autoreleasepool {
		[self bk_linkDelegateMethods:@{ @"testWithFloatBlock": @"testWithFloat:" }];
	}
}

@end

#pragma mark -=

@implementation TestPassDouble (A2BlockDelegate)

@dynamic testWithDoubleBlock;

+ (void)load {
	@autoreleasepool {
		[self bk_linkDelegateMethods:@{ @"testWithDoubleBlock": @"testWithDouble:" }];
	}
}

@end

#pragma mark -

@implementation TestPassArray (A2BlockDelegate)

@dynamic testWithArrayBlock;

+ (void)load {
	@autoreleasepool {
		[self bk_linkDelegateMethods:@{ @"testWithArrayBlock": @"testWithArray:" }];
	}
}

@end

#pragma mark -

@implementation TestPassStruct (A2BlockDelegate)

@dynamic testWithStructBlock;

+ (void)load {
	@autoreleasepool {
		[self bk_linkDelegateMethods:@{ @"testWithStructBlock": @"testPassStruct:" }];
	}
}

@end
