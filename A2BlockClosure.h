//
//  A2BlockClosure.h
//  A2DynamicDelegate
//

#import <Foundation/Foundation.h>

@interface A2BlockClosure : NSObject {
@package
    NSMutableArray *_allocations;
    id _block;
    void *_methodCIF;
    void *_blockCIF;
    void *_closure;
    void *_functionPointer;
}

- (id)initWithBlock: (id) block methodSignature: (NSMethodSignature *) signature;

@property (nonatomic, readonly) id block;
@property (nonatomic, readonly) void *functionPointer;

@end