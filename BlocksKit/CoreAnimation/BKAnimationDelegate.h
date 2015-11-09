//
//  BKAnimationDelegate.h
//  BlocksKit
//
//  Contributed by Sergio Padrino
//

#import <QuartzCore/QuartzCore.h>

typedef void (^BKAnimationDelegateStartBlock)(CAAnimation *anim);
typedef void (^BKAnimationDelegateStopBlock)(CAAnimation *anim, BOOL finished);

/** Block-based delegate for CAAnimations.
 
 Block-based replacement for CAAnimationDelegate category methods on NSObject.
 
 Example of usage:
 
 CAAnimation *animation = …;
 animation.delegate = [BKAnimationDelegate animationDelegateWithStartBlock:… stopBlock:…];
 
 Created by [Sergio Padrino](https://github.com/sergiou87) and contributed to
 BlocksKit.
 */
@interface BKAnimationDelegate : NSObject

+ (instancetype)animationDelegateWithStartBlock:(BKAnimationDelegateStartBlock)startBlock
									  stopBlock:(BKAnimationDelegateStopBlock)stopBlock;

@end
