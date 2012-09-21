//
//  A2BlockClosure.h
//  A2DynamicDelegate
//

#import <Foundation/Foundation.h>

@interface A2BlockClosure : NSObject {
@private
    NSMutableArray *_allocations;
	id _block;
	id _methodSignature;
	void *_functionInterface;
}

@property (nonatomic, copy) id block;
@property (nonatomic, strong) NSMethodSignature *methodSignature;
@property (nonatomic, readonly) void *functionInterface;
@property (nonatomic, readonly) void(*function)(void);

- (id)initWithBlock: (id) block methodSignature: (NSMethodSignature *) signature;

- (void)callWithInvocation:(NSInvocation *)invoc;

@end