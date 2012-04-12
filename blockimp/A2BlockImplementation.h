//
//  A2BlockImplementation.h
//  A2DynamicDelegate
//
//  Created by Landon Fuller on 4/14/11.
//  Copyright (c) 2011 Plausible Labs Cooperative, Inc. All rights reserved.
//  Licensed under MIT.
//

#import <Foundation/Foundation.h>

extern IMP a2_imp_implementationWithBlock(id block);
extern id a2_imp_getBlock(IMP anImp);
extern BOOL a2_imp_removeBlock(IMP anImp);

extern BOOL a2_blockIsCompatible(id block, NSMethodSignature *signature);