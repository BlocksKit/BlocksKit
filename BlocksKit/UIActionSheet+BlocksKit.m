//
//  UIActionSheet+BlocksKit.m
//  BlocksKit
//

#import "UIActionSheet+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"

@interface UIActionSheet (BlocksKitPrivate)
@property (nonatomic, retain) NSMutableDictionary *blocks;
@end

@implementation UIActionSheet (BlocksKit)

static char *kActionSheetBlockDictionaryKey = "UIActionSheetBlockHandlers"; 
static NSString *kActionSheetWillShowBlockKey = @"UIActionSheetWillShowBlock";
static NSString *kActionSheetDidShowBlockKey = @"UIActionSheetDidShowBlock";
static NSString *kActionSheetWillDismissBlockKey = @"UIActionSheetWillDismissBlock";
static NSString *kActionSheetDidDismissBlockKey = @"UIActionSheetDidDismissBlock";


#pragma mark Initializers

+ (id)sheetWithTitle:(NSString *)title {
    return [[[UIActionSheet alloc] initWithTitle:title] autorelease];
}

- (id)initWithTitle:(NSString *)title {
    return [self initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
}

#pragma mark Public methods

- (NSInteger)addButtonWithTitle:(NSString *)title handler:(BKBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    
    NSAssert(title.length, @"A button without a title cannot be added to an action sheet.");
    NSInteger index = [self addButtonWithTitle:title];
    
#if __has_feature(objc_arc)
    BKBlock handler = [block copy];
#else
    BKBlock handler = [[block copy] autorelease];
#endif
    
    [self.blocks setObject:handler forKey:[NSNumber numberWithInteger:index]];
    
    return index;
}

- (NSInteger)setDestructiveButtonWithTitle:(NSString *) title handler:(BKBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    
    NSAssert(title.length, @"A button without a title cannot be added to the action sheet.");
    NSInteger index = [self addButtonWithTitle:title];
    self.destructiveButtonIndex = index;
    
#if __has_feature(objc_arc)
    BKBlock handler = [block copy];
#else
    BKBlock handler = [[block copy] autorelease];
#endif
    
    [self.blocks setObject:handler forKey:[NSNumber numberWithInteger:index]];
    
    return index;
}

- (NSInteger)setCancelButtonWithTitle:(NSString *)title handler:(BKBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    
    NSInteger index = -1;
    
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && !title)
        title = NSLocalizedString(@"Cancel", nil);
    
    if (title)
        index = [self addButtonWithTitle:title];
    
#if __has_feature(objc_arc)
    BKBlock handler = [block copy];
#else
    BKBlock handler = [[block copy] autorelease];
#endif
    
    [self.blocks setObject:handler forKey:[NSNumber numberWithInteger:index]];
    self.cancelButtonIndex = index;
    
    return index;
}

#pragma mark Properties

- (NSMutableDictionary *)blocks {
    NSMutableDictionary *blocks = [self associatedValueForKey:kActionSheetBlockDictionaryKey];
    if (!blocks) {
        blocks = [NSMutableDictionary dictionary];
        [self associateValue:blocks withKey:kActionSheetBlockDictionaryKey];
    }
    return blocks;
}

- (void)setBlocks:(NSMutableDictionary *)blocks {
    [self associateValue:blocks withKey:kActionSheetBlockDictionaryKey];
}

- (BKBlock)cancelBlock {
    NSNumber *key = [NSNumber numberWithInteger:self.cancelButtonIndex];
    return [self.blocks objectForKey:key];
}

- (void)setCancelBlock:(BKBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    
    if (self.cancelButtonIndex == -1) {
        [self setCancelButtonWithTitle:nil handler:block];
    } else {
        NSNumber *key = [NSNumber numberWithInteger:self.cancelButtonIndex];
        
#if __has_feature(objc_arc)
        BKBlock handler = [block copy];
#else
        BKBlock handler = [[block copy] autorelease];
#endif
        
        [self.blocks setObject:handler forKey:key];
    }
}

- (BKBlock)willShowBlock {
    return [self.blocks objectForKey:kActionSheetWillShowBlockKey];    
}

- (void)setWillShowBlock:(BKBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    
#if __has_feature(objc_arc)
    BKBlock handler = [block copy];
#else
    BKBlock handler = [[block copy] autorelease];
#endif
    
    [self.blocks setObject:handler forKey:kActionSheetWillShowBlockKey];
}

- (BKBlock)didShowBlock {
    return [self.blocks objectForKey:kActionSheetDidShowBlockKey];
}

- (void)setDidShowBlock:(BKBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    
#if __has_feature(objc_arc)
    BKBlock handler = [block copy];
#else
    BKBlock handler = [[block copy] autorelease];
#endif
    
    [self.blocks setObject:handler forKey:kActionSheetDidShowBlockKey];
}

- (BKIndexBlock)willDismissBlock {
    return [self.blocks objectForKey:kActionSheetWillDismissBlockKey];
}

- (void)setWillDismissBlock:(BKIndexBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    
#if __has_feature(objc_arc)
    BKIndexBlock handler = [block copy];
#else
    BKIndexBlock handler = [[block copy] autorelease];
#endif
    
    [self.blocks setObject:handler forKey:kActionSheetWillDismissBlockKey];
}

- (BKIndexBlock)didDismissBlock {
    return [self.blocks objectForKey:kActionSheetDidDismissBlockKey];
}

- (void)setDidDismissBlock:(BKIndexBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    
#if __has_feature(objc_arc)
    BKIndexBlock handler = [block copy];
#else
    BKIndexBlock handler = [[block copy] autorelease];
#endif
    
    [self.blocks setObject:handler forKey:kActionSheetDidDismissBlockKey];
}

#pragma mark Delegates

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    BKBlock block = [self.blocks objectForKey:[NSNumber numberWithInteger:buttonIndex]];
    if (block)
        block();
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    BKBlock block = [self.blocks objectForKey:kActionSheetWillShowBlockKey];
    if (block)
        block();
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet {
    BKBlock block = [self.blocks objectForKey:kActionSheetDidShowBlockKey];
    if (block)
        block();
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    BKIndexBlock block = [self.blocks objectForKey:kActionSheetWillDismissBlockKey];
    if (block)
        block(buttonIndex);
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    BKIndexBlock block = [self.blocks objectForKey:kActionSheetDidDismissBlockKey];
    if (block)
        block(buttonIndex);
}

@end
