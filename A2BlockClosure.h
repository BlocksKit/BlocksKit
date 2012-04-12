//
//  A2BlockClosure.h
//  A2DynamicDelegate
//
//  Created by Michael Ash on 9/17/10.
//  Copyright (c) 2010 Michael Ash. All rights reserved.
//  Licensed under BSD.
//

#import <Foundation/Foundation.h>
#import "ffi.h"

@interface A2BlockClosure : NSObject {
    NSMutableArray *_allocations;
    ffi_cif _methodCIF;
    ffi_cif _blockCIF;
	NSUInteger _numberOfArguments;
    ffi_closure *_closure;
    void *_functionPointer;
    id _block;
}

- (id)initWithBlock: (id) block methodSignature: (NSMethodSignature *) signature;

@property (nonatomic, readonly) id block;
@property (nonatomic, readonly) void *functionPointer;

@end