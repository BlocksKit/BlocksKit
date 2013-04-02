//
//  NSObjectBlockObservationTest.m
//  BlocksKit Unit Tests
//
//  Created by Kai Wu on 7/5/11.
//  Copyright (c) 2011-2012 Pandamonia LLC. All rights reserved.
//

#import "NSObjectBlockObservationTest.h"

@interface SubjectKVCAndKVO : NSObject

@property (nonatomic, getter=isKVC) BOOL kvc; //scalar
@property (nonatomic, strong) NSNumber *number;	  //scalar
@property (nonatomic, strong) NSObjectBlockObservationTest *test; //to-one
@property (nonatomic, strong) NSMutableArray *names; //ordered to-many
@property (nonatomic, strong) NSMutableSet *members; //unordered to-many

- (void)insertObject:(NSString *)name inNamesAtIndex:(NSUInteger)index;
- (void)removeObjectFromNamesAtIndex:(NSUInteger)index;
- (void)addMembersObject:(NSString *)member;
- (void)removeMembersObject:(NSString *)member;

@end

@implementation SubjectKVCAndKVO

- (id)initSubjectWithTest:(NSObjectBlockObservationTest *)test {
	if ( (self = [super init]) ) {
		self.kvc = YES;
		self.test = test;
		self.number = @(0);
		self.names = [@[ @"one", @"two" ] mutableCopy];
		self.members = [NSMutableSet setWithArray: @[ @"foo", @"bar" ]];
	}
	return self;
}

- (void)insertObject:(NSString *)name inNamesAtIndex:(NSUInteger)index {
	[_names insertObject:name atIndex:index];
}

- (void)removeObjectFromNamesAtIndex:(NSUInteger)index {
	[_names removeObjectAtIndex:index];
}

- (void)addMembersObject:(NSString *)member {
	[_members addObject:member];
}

- (void)removeMembersObject:(NSString *)member {
	[_members removeObject:member];
}

@end

@implementation NSObjectBlockObservationTest  {
	SubjectKVCAndKVO *_subject; 
	NSInteger _total;
}

- (void)setUp {
	_subject = [[SubjectKVCAndKVO alloc] initSubjectWithTest:self];
	_total = 0;
}

- (void)action {
	_total += 1;
}

- (void)testBoolKeyValueObservation {
	BKSenderBlock observeBlock = ^(id obj) {
		[(NSObjectBlockObservationTest *)obj action];
	};
	NSString *token = [self addObserverForKeyPath:@"subject.kvc" task:observeBlock];

	[self setValue:@NO forKeyPath:@"subject.kvc"];
	STAssertFalse(_subject.kvc, @"kvc is NO");
	STAssertEquals(_total, (NSInteger)1, @"total is %d", _total);
	[self removeObserverForKeyPath:@"subject.kvc" identifier:token];
}

- (void)testNSNumberKeyValueObservation {
	BKSenderBlock observeBlock = ^(id obj) {
		[(NSObjectBlockObservationTest *)obj action];
	};
	NSString *token = [self addObserverForKeyPath:@"subject.number" task:observeBlock];

	NSNumber *number = @1;
	[self setValue:number forKeyPath:@"subject.number"];
	STAssertEquals(_subject.number,number,@"number is %@",_subject.number);
	STAssertEquals(_total, (NSInteger)1, @"total is %d", _total);
	
	[self removeObserverForKeyPath:@"subject.number" identifier:token];
}

- (void)testNSArrayKeyValueObservation {
	BKSenderBlock observeBlock = ^(id obj) {
		[(NSObjectBlockObservationTest *)obj action];
	};
	NSString *token = [self addObserverForKeyPath:@"subject.names" task:observeBlock];

	NSMutableArray *names = [self mutableArrayValueForKeyPath:@"subject.names"];
	names[0] = @"1";
	names[1] = @"2";
	NSArray *target = @[ @"1", @"2" ];
	STAssertEqualObjects(_subject.names,target,@"names are %@",_subject.names);
	STAssertEquals(_total, (NSInteger)2, @"total is %d", _total);
	[self removeObserverForKeyPath:@"subject.names" identifier:token];
}

- (void)testNSSetKeyValueObservation {
	BKSenderBlock observeBlock = ^(id obj) {
		[(NSObjectBlockObservationTest *)obj action];
	};
	NSString *token = [self addObserverForKeyPath:@"subject.members" task:observeBlock];

	NSMutableSet *members = [self mutableSetValueForKeyPath:@"subject.members"];
	[members removeObject:@"bar"];
	[members addObject:@"one"];
	NSSet *target = [NSSet setWithArray: @[ @"foo", @"one" ]];
	STAssertEqualObjects(_subject.members,target,@"members are %@",_subject.members);
	STAssertEquals(_total, (NSInteger)2, @"total is %d", _total);
	[self removeObserverForKeyPath:@"subject.members" identifier:token];
}


- (void)testMultipleKeyValueObservation {
    NSString *token = [self addObserverForKeyPaths: @[@"subject.kvc", @"subject.number"] task:^(id obj, NSString *keyPath) {
        [(NSObjectBlockObservationTest *)obj action];
    }];
    NSNumber *number = @1;
    [self setValue:@NO forKeyPath:@"subject.kvc"];
    [self setValue:number forKeyPath:@"subject.number"];
    STAssertFalse(_subject.kvc, @"kvc is NO");
	STAssertEquals(_subject.number,number,@"number is %@",_subject.number);
	STAssertEquals(_total, (NSInteger)2, @"total is %d", _total);
    [self removeObserversWithIdentifier: token];
}

- (void)testMultipleOnlyOneKeyValueObservation {
    NSString *token = [self addObserverForKeyPaths: @[@"subject.kvc"] task:^(id obj, NSString *keyPath) {
        [(NSObjectBlockObservationTest *)obj action];
    }];
    [self setValue:@NO forKeyPath:@"subject.kvc"];
    STAssertFalse(_subject.kvc, @"kvc is NO");
	STAssertEquals(_total, (NSInteger)1, @"total is %d", _total);
    [self removeObserversWithIdentifier: token];    
}

@end
