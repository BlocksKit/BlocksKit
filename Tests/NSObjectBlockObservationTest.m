//
//  NSObjectBlockObservationTest.m
//  BlocksKit Unit Tests
//

#import "NSObjectBlockObservationTest.h"

@interface SubjectKVCAndKVO : NSObject

@property (nonatomic, getter=isKvc) BOOL kvc; //scalar
@property (nonatomic, retain) NSNumber *number;	  //scalar
@property (nonatomic, retain) NSObjectBlockObservationTest *test; //to-one
@property (nonatomic, retain) NSMutableArray *names; //ordered to-many
@property (nonatomic, retain) NSMutableSet *members; //unordered to-many

- (void)insertObject:(NSString *)name inNamesAtIndex:(NSUInteger)index;
- (void)removeObjectFromNamesAtIndex:(NSUInteger)index;
- (void)addMembersObject:(NSString *)member;
- (void)removeMembersObject:(NSString *)member;
@end

@implementation SubjectKVCAndKVO

@synthesize kvc=_kvc, test=_test, number=_number, names=_names, members=_members;

- (id)initSubjectWithTest:(NSObjectBlockObservationTest *)test {
	if ( (self = [super init]) ) {
		self.kvc = YES;
		self.test = test;
		self.number = [NSNumber numberWithInteger:0];
		self.names = [NSMutableArray arrayWithObjects:@"one",@"two",nil];
		self.members = [NSMutableSet setWithObjects:@"foo",@"bar",nil];
	}
	return self;
}

- (void)dealloc {
	[_number release];
	[_test release];
	[_names release];
	[_members release];
	[super dealloc];
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

- (void)setUpClass {
	_subject = [[SubjectKVCAndKVO alloc] initSubjectWithTest:self];
}

- (void)tearDownClass {
	[_subject release];
}

- (void)setUp {
	_total = 0;
}

- (void)action {
	_total += 1;
}

- (void)testBoolKeyValueObservation {
	BKObservationBlock observeBlock = ^(id obj, NSDictionary *change) {
		[(NSObjectBlockObservationTest *)obj action];
	};
	NSString *token = [self addObserverForKeyPath:@"subject.kvc" task:observeBlock];

	[self setValue:[NSNumber numberWithBool:NO] forKeyPath:@"subject.kvc"];
	GHAssertFalse(_subject.kvc,@"kvc is NO");
	GHAssertEquals(_total,1,@"total is %d",_total);
	[self removeObserverForKeyPath:@"subject.kvc" identifier:token];
}

- (void)testNSNumberKeyValueObservation {
	BKObservationBlock observeBlock = ^(id obj, NSDictionary *change) {
		[(NSObjectBlockObservationTest *)obj action];
	};
	NSString *token = [self addObserverForKeyPath:@"subject.number" task:observeBlock];

	NSNumber *number = [NSNumber numberWithInteger:1];
	[self setValue:number forKeyPath:@"subject.number"];
	GHAssertEquals(_subject.number,number,@"number is %@",_subject.number);
	GHAssertEquals(_total,1,@"total is %d",_total);
	
	[self removeObserverForKeyPath:@"subject.number" identifier:token];
}

- (void)testNSArrayKeyValueObservation {
	BKObservationBlock observeBlock = ^(id obj, NSDictionary *change) {
		[(NSObjectBlockObservationTest *)obj action];
	};
	NSString *token = [self addObserverForKeyPath:@"subject.names" task:observeBlock];

	NSMutableArray *names = [self mutableArrayValueForKeyPath:@"subject.names"];
	[names replaceObjectAtIndex:0 withObject:@"1"];
	[names replaceObjectAtIndex:1 withObject:@"2"];
	NSArray *target = [NSArray arrayWithObjects:@"1",@"2",nil];
	GHAssertEqualObjects(_subject.names,target,@"names are %@",_subject.names);
	GHAssertEquals(_total,2,@"total is %d",_total);
	
	[self removeObserverForKeyPath:@"subject.names" identifier:token];
}

- (void)testNSSetKeyValueObservation {
	BKObservationBlock observeBlock = ^(id obj, NSDictionary *change) {
		[(NSObjectBlockObservationTest *)obj action];
	};
	NSString *token = [self addObserverForKeyPath:@"subject.members" task:observeBlock];

	NSMutableSet *members = [self mutableSetValueForKeyPath:@"subject.members"];
	[members removeObject:@"bar"];
	[members addObject:@"one"];
	NSSet *target = [NSSet setWithObjects:@"foo",@"one",nil];
	GHAssertEqualObjects(_subject.members,target,@"members are %@",_subject.members);
	GHAssertEquals(_total,2,@"total is %d",_total);
	
	[self removeObserverForKeyPath:@"subject.members" identifier:token];
} 
@end
