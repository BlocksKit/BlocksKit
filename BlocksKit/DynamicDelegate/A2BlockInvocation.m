//
//  A2BlockInvocation.m
//  BlocksKit
//

#import "A2BlockInvocation.h"

NSString *const A2IncompatibleMethodSignatureKey = @"incompatibleMethodSignature";

#pragma mark Block Internals

typedef NS_OPTIONS(int, BKBlockFlags) {
	BKBlockFlagsHasCopyDisposeHelpers = (1 << 25),
	BKBlockFlagsHasSignature          = (1 << 30)
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

NS_INLINE BOOL typesCompatible(const char *a, const char *b) {
    if (a[0] == b[0]) { return YES; }
    NSUInteger aSize, aAlign, bSize, bAlign;
    NSGetSizeAndAlignment(a, &aSize, &aAlign);
    NSGetSizeAndAlignment(a, &bSize, &bAlign);
    if (aSize == bSize && aAlign == bAlign) { return YES; }
    return !!strcmp(a, b);
}

@interface A2BlockInvocation ()

@property (nonatomic, readonly) NSMethodSignature *blockSignature;

@end

@implementation A2BlockInvocation

/** Determines if two given signatures (block or method) are compatible.

 A signature is compatible with another signature if their return types and
 parameter types are equal, minus the parameter types dedicated to the Obj-C
 method reciever and selector or a block literal argument.

 @param signatureA Any signature object reflecting a block or method signature
 @param signatureB Any signature object reflecting a block or method signature
 @return YES if the given signatures may be used to dispatch for one another
 */
+ (BOOL)isSignature:(NSMethodSignature *)signatureA compatibleWithSignature:(NSMethodSignature *)signatureB __attribute__((pure))
{
	if (!signatureA || !signatureB) return NO;
	if ([signatureA isEqual:signatureB]) return YES;
	if (!typesCompatible(signatureA.methodReturnType, signatureB.methodReturnType)) return NO;

	NSMethodSignature *methodSignature = nil, *blockSignature = nil;
	if (signatureA.numberOfArguments > signatureB.numberOfArguments) {
		methodSignature = signatureA;
		blockSignature = signatureB;
	} else if (signatureB.numberOfArguments > signatureA.numberOfArguments) {
		methodSignature = signatureB;
		blockSignature = signatureA;
	} else {
		return NO;
	}

	NSUInteger numberOfArguments = methodSignature.numberOfArguments;
	for (NSUInteger i = 2; i < numberOfArguments; i++) {
        if (!typesCompatible([methodSignature getArgumentTypeAtIndex:i], [blockSignature getArgumentTypeAtIndex:i - 1])) {
			return NO;
        }
	}

	return YES;
}

/** Inspects the given block literal and returns a compatible type signature.

 Unlike a typical method signature, a block type signature has no `self` (`'@'`)
 or `_cmd` (`':'`) parameter, but instead just one parameter for the block itself
 (`'@?'`).

 @param block An Objective-C block literal
 @return A method signature matching the declared prototype for the block
 */
+ (NSMethodSignature *)typeSignatureForBlock:(id)block __attribute__((pure, nonnull(1)))
{
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

	return [NSMethodSignature signatureWithObjCTypes:signature];
}

/// Creates a method signature compatible with a given block signature.
+ (NSMethodSignature *)methodSignatureForBlockSignature:(NSMethodSignature *)original
{
	if (!original) return nil;

	if (original.numberOfArguments < 1) {
		return nil;
	}

	if (original.numberOfArguments >= 2 && strcmp(@encode(SEL), [original getArgumentTypeAtIndex:1]) == 0) {
		return original;
	}

	// initial capacity is num. arguments - 1 (@? -> @) + 1 (:) + 1 (ret type)
	// optimistically assuming most signature components are char[1]
	NSMutableString *signature = [[NSMutableString alloc] initWithCapacity:original.numberOfArguments + 1];

	const char *retTypeStr = original.methodReturnType;
	[signature appendFormat:@"%s%s%s", retTypeStr, @encode(id), @encode(SEL)];

	for (NSUInteger i = 1; i < original.numberOfArguments; i++) {
		const char *typeStr = [original getArgumentTypeAtIndex:i];
		NSString *type = [[NSString alloc] initWithBytesNoCopy:(void *)typeStr length:strlen(typeStr) encoding:NSUTF8StringEncoding freeWhenDone:NO];
		[signature appendString:type];
	}

	return [NSMethodSignature signatureWithObjCTypes:signature.UTF8String];
}

+ (NSMethodSignature *)methodSignatureForBlock:(id)block
{
	NSMethodSignature *original = [self typeSignatureForBlock:block];
	if (!original) return nil;
	return [self methodSignatureForBlockSignature:original];
}

- (instancetype)initWithBlock:(id)block methodSignature:(NSMethodSignature *)methodSignature blockSignature:(NSMethodSignature *)blockSignature
{
	self = [super init];
	if (self) {
		_block = [block copy];
		_methodSignature = methodSignature;
		_blockSignature = blockSignature;
	}
	return self;
}

- (instancetype)initWithBlock:(id)block
{
	NSParameterAssert(block);
	NSMethodSignature *blockSignature = [[self class] typeSignatureForBlock:block];
	NSMethodSignature *methodSignature = [[self class] methodSignatureForBlockSignature:blockSignature];
	NSAssert(methodSignature, @"Incompatible block: %@", block);
	return (self = [self initWithBlock:block methodSignature:methodSignature blockSignature:blockSignature]);
}

- (instancetype)initWithBlock:(id)block methodSignature:(NSMethodSignature *)methodSignature
{
	NSParameterAssert(block);
	NSMethodSignature *blockSignature = [[self class] typeSignatureForBlock:block];
	if (![[self class] isSignature:methodSignature compatibleWithSignature:blockSignature]) {
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Attempted to create block invocation with incompatible signatures" userInfo:@{A2IncompatibleMethodSignatureKey: methodSignature}];
	}
	return (self = [self initWithBlock:block methodSignature:methodSignature blockSignature:blockSignature]);
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
