//
//  A2BlockInvocation.m
//  BlocksKit
//

#import "A2BlockInvocation.h"

#ifndef NSFoundationVersionNumber10_8
#define NSFoundationVersionNumber10_8 945.00
#endif

#ifndef NSFoundationVersionNumber_iOS_6_0
#define NSFoundationVersionNumber_iOS_6_0  993.00
#endif

#pragma mark Block Internals

typedef NS_OPTIONS(int, BKBlockFlags) {
	BKBlockFlagsHasCopyDisposeHelpers	= (1 << 25),
	BKBlockFlagsHasSignature			= (1 << 30)
};

typedef struct _BKBlock {
	__unused Class isa;
	BKBlockFlags flags;
	__unused int reserved;
	void (__unused *invoke)(struct _BKBlock *block, ...);
	struct {
		unsigned long int reserved;
		unsigned long int size;
		// requires BKBlockFlagsHasCopyDisposeHelpers
		void (*copy)(void *dst, const void *src);
		void (*dispose)(const void *);
		// requires BKBlockFlagsHasSignature
		const char *signature;
		const char *layout;
	} *descriptor;
	// imported variables
} *BKBlockRef;

static NSMethodSignature *a2_blockGetSignature(id block) {
	BKBlockRef layout = (__bridge void *)block;

	if (!(layout->flags & BKBlockFlagsHasSignature))
		return nil;

	void *desc = layout->descriptor;
	desc += 2 * sizeof(unsigned long int);

	if (layout->flags & BKBlockFlagsHasCopyDisposeHelpers)
		desc += 2 * sizeof(void *);

	if (!desc)
		return nil;
    
    const char *signature = (*(const char **)desc);
    
#if (TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MIN_REQUIRED < 60000) || (TARGET_OS_MAC && __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_8)
    static BOOL shouldStrip = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if TARGET_OS_IPHONE
        shouldStrip = (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_6_0);
#elif TARGET_OS_MAC
        shouldStrip = (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber10_8);
#else
        shouldStrip = YES;
#endif
    });
    
    if (shouldStrip) {
        NSMutableString *mutableSignature = [NSMutableString stringWithUTF8String:signature];
        [mutableSignature replaceOccurrencesOfString:@"\"[^\"]*\"" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, mutableSignature.length)];
        signature = [mutableSignature UTF8String];
    }
#endif
    
	return [NSMethodSignature signatureWithObjCTypes:signature];
}

static __unused BOOL a2_methodSignaturesCompatible(NSMethodSignature *methodSignature, NSMethodSignature *blockSignature)
{
	if (methodSignature.methodReturnType[0] != blockSignature.methodReturnType[0])
		return NO;

	NSUInteger numberOfArguments = methodSignature.numberOfArguments;
	for (NSUInteger i = 2; i < numberOfArguments; i++) {
		if ([methodSignature getArgumentTypeAtIndex:i][0] != [blockSignature getArgumentTypeAtIndex:i - 1][0])
			return NO;
	}
	return YES;
}

@interface A2BlockInvocation ()

@property (nonatomic, strong, readwrite) NSMethodSignature *methodSignature;
@property (nonatomic, copy, readwrite) id block;

@property (nonatomic) NSMethodSignature *blockSignature;

@end

@implementation A2BlockInvocation

- (instancetype)initWithBlock:(id)block methodSignature:(NSMethodSignature *)methodSignature
{
	NSParameterAssert(block);
	NSMethodSignature *blockSignature = a2_blockGetSignature(block);
    
	NSAssert(blockSignature, @"Incompatible block: %@", block);
	NSAssert(a2_methodSignaturesCompatible(methodSignature, blockSignature), @"Attempted to create block invocation with incompatible signatures");
    
	self = [super init];
	if (self) {
		self.block = block;
		self.methodSignature = methodSignature;
		self.blockSignature = blockSignature;
	}
	return self;
}

- (BOOL)invokeWithInvocation:(NSInvocation *)outerInv returnValue:(out NSValue **)outReturnValue setOnInvocation:(BOOL)setOnInvocation
{
	NSParameterAssert(outerInv);

	NSMethodSignature *sig = self.methodSignature;

	if (![outerInv.methodSignature isEqual:sig]) {
		NSAssert(0, @"Attempted to invoke block invocation with incompatible frame");
		return NO;
	}

	NSInvocation *innerInv = [NSInvocation invocationWithMethodSignature:self.blockSignature];

	void *argBuf = NULL;

	for (NSUInteger i = 2; i < sig.numberOfArguments; i++) {
		const char *type = [sig getArgumentTypeAtIndex:i];
		NSUInteger argSize;
		NSGetSizeAndAlignment(type, &argSize, NULL);

		if (!(argBuf = reallocf(argBuf, argSize))) {
			return NO;
		}

		[outerInv getArgument:argBuf atIndex:i];
		[innerInv setArgument:argBuf atIndex:i - 1];
	}

	[innerInv invokeWithTarget:self.block];

	NSUInteger retSize = sig.methodReturnLength;
	if (retSize) {
		if (outReturnValue || setOnInvocation) {
			if (!(argBuf = reallocf(argBuf, retSize))) {
				return NO;
			}

			[innerInv getReturnValue:argBuf];

			if (setOnInvocation) {
				[outerInv setReturnValue:argBuf];
			}

			if (outReturnValue) {
				*outReturnValue = [NSValue valueWithBytes:argBuf objCType:sig.methodReturnType];
			}
		}
	} else {
		if (outReturnValue) {
			*outReturnValue = nil;
		}
	}

	free(argBuf);

	return YES;
}

- (void)invokeWithInvocation:(NSInvocation *)inv
{
	[self invokeWithInvocation:inv returnValue:NULL setOnInvocation:YES];
}

- (BOOL)invokeWithInvocation:(NSInvocation *)inv returnValue:(out NSValue **)returnValue
{
	return [self invokeWithInvocation:inv returnValue:returnValue setOnInvocation:NO];
}

@end
