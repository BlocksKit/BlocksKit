//
//  BKAnimationDelegate.m
//  BlocksKit
//
//  Contributed by Sergio Padrino
//

#import "BKAnimationDelegate.h"

@interface BKAnimationDelegate ()

@property (nonatomic, strong) BKAnimationDelegateStartBlock startBlock;
@property (nonatomic, strong) BKAnimationDelegateStopBlock stopBlock;

@end

@implementation BKAnimationDelegate

+ (instancetype)animationDelegateWithStartBlock:(BKAnimationDelegateStartBlock)startBlock
									  stopBlock:(BKAnimationDelegateStopBlock)stopBlock
{
	return [[self alloc] initWithStartBlock:startBlock stopBlock:stopBlock];
}

- (instancetype)initWithStartBlock:(BKAnimationDelegateStartBlock)startBlock
						 stopBlock:(BKAnimationDelegateStopBlock)stopBlock
{
	if ((self = [super init]))
	{
		_startBlock = startBlock;
		_stopBlock = stopBlock;
	}
	
	return self;
}

- (void)animationDidStart:(CAAnimation *)anim
{
	if (self.startBlock)
		self.startBlock(anim);
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
	if (self.stopBlock)
		self.stopBlock(anim, flag);
}

@end
