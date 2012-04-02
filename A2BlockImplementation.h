//
//  A2BlockImplementation.h
//  A2DynamicDelegate
//
//  Created by Zachary Waldowski on 4/1/12.
//  Copyright (c) 2012 Pandamonia LLC. All rights reserved.
//
//  This and related files includes code by the following:
//   - Landon Fuller, plblockimp
//     Copyright (c) 2011, Plausible Labs Cooperative, Inc.
//     All rights reserved. Licensed under MIT.
//   - David Chisnall, GNUstep Objective-C Runtime
//     Copyright (c) 2011, The GNUstep Project
//     All rights reserved. Licensed under LGPL.
//   - The Objective-C Runtime Library 493.11
//     Copyright (c) 2012, Apple Inc.
//     All rights reserved. Licensed under APSL.
//

#include <objc/runtime.h>

extern IMP a2_imp_implementationWithBlock(id block);
extern IMP a2_imp_implementationWithArgumentsOnlyBlock(id block);
extern void *a2_imp_getBlock(IMP anImp);
extern BOOL a2_imp_removeBlock(IMP anImp);