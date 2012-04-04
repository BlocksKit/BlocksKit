//
//  A2BlockClosure.h
//  A2DynamicDelegate
//
//  Created by Michael Ash on 9/17/10.
//  Copyright (c) 2010 Michael Ash. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//    * Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in the
//      documentation and/or other materials provided with the distribution.
//    * Neither the name of the  nor the
//      names of its contributors may be used to endorse or promote products
//      derived from this software without specific prior written permission.
//

#import "ffi.h"

@interface A2BlockClosure : NSObject {
    NSMutableArray *_allocations;
    ffi_cif _closureCIF;
    ffi_cif _innerCIF;
	NSUInteger _numberOfArguments;
    ffi_closure *_closure;
    void *_functionPointer;
    id _block;
}

- (id)initWithBlock: (id) block;

@property (nonatomic, readonly) id block;
@property (nonatomic, readonly) void *functionPointer;

@end