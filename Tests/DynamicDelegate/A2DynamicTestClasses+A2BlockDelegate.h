//
//  A2DynamicTestClasses+A2BlockDelegate.h
//  BlocksKit
//
//  Created by Zach Waldowski on 12/3/13.
//
//

#import <Foundation/Foundation.h>
#import "A2DynamicTestClasses.h"

#pragma mark -

@interface TestReturnObject (A2BlockDelegate)

@property (nonatomic, copy) NSString *(^testReturnObjectBlock)(void);

@end

#pragma mark -

@interface TestReturnStruct (A2BlockDelegate)

@property (nonatomic, copy) MyStruct(^testReturnStructBlock)(void);

@end

#pragma mark -

@interface TestPassObject (A2BlockDelegate)

@property (nonatomic, copy) BOOL(^testWithObjectBlock)(NSString *);

@end

#pragma mark -

@interface TestPassChar (A2BlockDelegate)

@property (nonatomic, copy) BOOL(^testWithCharBlock)(char);

@end

#pragma mark -

@interface TestPassUChar (A2BlockDelegate)

@property (nonatomic, copy) BOOL(^testWithUCharBlock)(unsigned char);

@end

#pragma mark -

@interface TestPassShort (A2BlockDelegate)

@property (nonatomic, copy) BOOL(^testWithShortBlock)(short);

@end

#pragma mark -

@interface TestPassUShort (A2BlockDelegate)

@property (nonatomic, copy) BOOL(^testWithUShortBlock)(unsigned short);

@end

#pragma mark -

@interface TestPassInt (A2BlockDelegate)

@property (nonatomic, copy) BOOL(^testWithIntBlock)(int);

@end

#pragma mark -

@interface TestPassUInt (A2BlockDelegate)

@property (nonatomic, copy) BOOL(^testWithUIntBlock)(unsigned int);

@end

#pragma mark -

@interface TestPassLong (A2BlockDelegate)

@property (nonatomic, copy) BOOL(^testWithLongBlock)(long);

@end

#pragma mark -

@interface TestPassULong (A2BlockDelegate)

@property (nonatomic, copy) BOOL(^testWithULongBlock)(unsigned long);

@end

#pragma mark -

@interface TestPassLongLong (A2BlockDelegate)

@property (nonatomic, copy) BOOL(^testWithLongLongBlock)(long long);

@end

#pragma mark -

@interface TestPassULongLong (A2BlockDelegate)

@property (nonatomic, copy) BOOL(^testWithULongLongBlock)(unsigned long long);

@end

#pragma mark -

@interface TestPassFloat (A2BlockDelegate)

@property (nonatomic, copy) BOOL(^testWithFloatBlock)(float);

@end

#pragma mark -=

@interface TestPassDouble (A2BlockDelegate)

@property (nonatomic, copy) BOOL(^testWithDoubleBlock)(double);

@end

#pragma mark -

@interface TestPassArray (A2BlockDelegate)

@property (nonatomic, copy) BOOL(^testWithArrayBlock)(int []);

@end

#pragma mark -

@interface TestPassStruct (A2BlockDelegate)

@property (nonatomic, copy) BOOL(^testWithStructBlock)(MyStruct);

@end
