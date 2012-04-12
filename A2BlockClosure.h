//
//  A2BlockClosure.h
//  A2DynamicDelegate
//
//  Created by Michael Ash on 9/17/10.
//  Copyright (c) 2010 Michael Ash. All rights reserved.
//  Licensed under BSD.
//

#import <Foundation/Foundation.h>

@interface A2BlockClosure : NSObject {
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