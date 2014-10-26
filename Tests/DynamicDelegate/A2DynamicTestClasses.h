//
//  A2DynamicTestClasses.h
//  BlocksKit Unit Tests
//

#import <Foundation/Foundation.h>

#pragma mark -

@protocol TestReturnObjectDelegate <NSObject>

- (NSString *)testReturnObject;

@end

@interface TestReturnObject : NSObject

- (BOOL)test;

@property (nonatomic, assign) id <TestReturnObjectDelegate> delegate;

@end

#pragma mark -

typedef struct _MyStruct {
	BOOL first;
	BOOL second;
} MyStruct;

@protocol TestReturnStructDelegate <NSObject>

- (MyStruct)testReturnStruct;

@end

@interface TestReturnStruct : NSObject

- (BOOL)test;

@property (nonatomic, assign) id <TestReturnStructDelegate> delegate;

@end

#pragma mark -

@protocol TestPassObjectDelegate <NSObject>

- (BOOL)testWithObject:(NSString *)obj;

@end

@interface TestPassObject : NSObject

- (BOOL)test;

@property (nonatomic, assign) id <TestPassObjectDelegate> delegate;

@end

#pragma mark -

@protocol TestPassCharDelegate <NSObject>

- (BOOL)testWithChar:(char)chr;

@end

@interface TestPassChar : NSObject

- (BOOL)test;

@property (nonatomic, assign) id <TestPassCharDelegate> delegate;

@end

#pragma mark -

@protocol TestPassUCharDelegate <NSObject>

- (BOOL)testWithUChar:(unsigned char)uchr;

@end

@interface TestPassUChar : NSObject

- (BOOL)test;

@property (nonatomic, assign) id <TestPassUCharDelegate> delegate;

@end

#pragma mark -

@protocol TestPassShortDelegate <NSObject>

- (BOOL)testWithShort:(short)shrt;

@end

@interface TestPassShort : NSObject

- (BOOL)test;

@property (nonatomic, assign) id <TestPassShortDelegate> delegate;

@end

#pragma mark -

@protocol TestPassUShortDelegate <NSObject>

- (BOOL)testWithUShort:(unsigned short)ushrt;

@end

@interface TestPassUShort : NSObject

- (BOOL)test;

@property (nonatomic, assign) id <TestPassUShortDelegate> delegate;

@end

#pragma mark -

@protocol TestPassIntDelegate <NSObject>

- (BOOL)testWithInt:(int)inte;

@end

@interface TestPassInt : NSObject

- (BOOL)test;

@property (nonatomic, assign) id <TestPassIntDelegate> delegate;

@end

#pragma mark -

@protocol TestPassUIntDelegate <NSObject>

- (BOOL)testWithUInt:(unsigned int)uint;

@end

@interface TestPassUInt : NSObject

- (BOOL)test;

@property (nonatomic, assign) id <TestPassUIntDelegate> delegate;

@end

#pragma mark -

@protocol TestPassLongDelegate <NSObject>

- (BOOL)testWithLong:(long)lng;

@end

@interface TestPassLong : NSObject

- (BOOL)test;

@property (nonatomic, assign) id <TestPassLongDelegate> delegate;

@end

#pragma mark -

@protocol TestPassULongDelegate <NSObject>

- (BOOL)testWithULong:(unsigned long)ulong;

@end

@interface TestPassULong : NSObject

- (BOOL)test;

@property (nonatomic, assign) id <TestPassULongDelegate> delegate;

@end

#pragma mark -

@protocol TestPassLongLongDelegate <NSObject>

- (BOOL)testWithLongLong:(long long)llong;

@end

@interface TestPassLongLong : NSObject

- (BOOL)test;

@property (nonatomic, assign) id <TestPassLongLongDelegate> delegate;

@end

#pragma mark -

@protocol TestPassULongLongDelegate <NSObject>

- (BOOL)testWithULongLong:(unsigned long long)ullong;

@end

@interface TestPassULongLong : NSObject

- (BOOL)test;

@property (nonatomic, assign) id <TestPassULongLongDelegate> delegate;

@end

#pragma mark -

@protocol TestPassFloatDelegate <NSObject>

- (BOOL)testWithFloat:(float)flt;

@end

@interface TestPassFloat : NSObject

- (BOOL)test;

@property (nonatomic, assign) id <TestPassFloatDelegate> delegate;

@end

#pragma mark -

@protocol TestPassDoubleDelegate <NSObject>

- (BOOL)testWithDouble:(double)dbl;

@end

@interface TestPassDouble : NSObject

- (BOOL)test;

@property (nonatomic, assign) id <TestPassDoubleDelegate> delegate;

@end

#pragma mark -

@protocol TestPassArrayDelegate <NSObject>

- (BOOL)testWithArray:(int [])ary;

@end

@interface TestPassArray : NSObject

- (BOOL)test;

@property (nonatomic, assign) id <TestPassArrayDelegate> delegate;

@end

#pragma mark -

@protocol TestPassStructDelegate <NSObject>

- (BOOL)testPassStruct:(MyStruct)stret;

@end

@interface TestPassStruct : NSObject

- (BOOL)test;

@property (nonatomic, assign) id <TestPassStructDelegate> delegate;

@end

#pragma mark -

@protocol TestClassMethodProtocol <NSObject>

+ (BOOL)testWithObject:(NSString *)obj;

@end

@interface TestClassMethod : NSObject

- (BOOL)test;

@property (nonatomic, assign) id <TestClassMethodProtocol> delegate;

@end
