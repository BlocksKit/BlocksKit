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

static char kActionSheetBlockDictionaryKey; 
static NSString *kActionSheetCancelBlockKey = @"UIActionSheetCancelBlock";
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

- (void)addButtonWithTitle:(NSString *)title handler:(BKBlock) block {
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    if (!self.delegate)
        self.delegate = self;
    
    NSAssert(title.length, @"A button without a title cannot be added to the action sheet.");
    NSInteger index = [self addButtonWithTitle:title];
    [self.blocks setObject:(block ? [[block copy] autorelease] : [NSNull null]) forKey:[NSNumber numberWithInteger:index]];
}

- (void)setDestructiveButtonWithTitle:(NSString *) title handler:(BKBlock) block {
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    if (!self.delegate)
        self.delegate = self;
    
    NSAssert(title.length, @"A button without a title cannot be added to the action sheet.");
    NSInteger index = [self addButtonWithTitle:title];
    [self.blocks setObject:(block ? [[block copy] autorelease] : [NSNull null]) forKey:[NSNumber numberWithInteger:index]];
    self.destructiveButtonIndex = index;
}

- (void)setCancelButtonWithTitle:(NSString *)title handler:(BKBlock)block {
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    if (!self.delegate)
        self.delegate = self;
    
    
    NSInteger index = -1;
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && !title)
        title = NSLocalizedString(@"Cancel", nil);
    if (title)
        index = [self addButtonWithTitle:title];
    [self.blocks setObject:(block ? [[block copy] autorelease] : [NSNull null]) forKey:kActionSheetCancelBlockKey];
    self.cancelButtonIndex = index;
}

#pragma mark Delegates

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSMutableDictionary *blocks = self.blocks;
    
    __block BKBlock actionBlock = nil;
    
    if (buttonIndex == self.cancelButtonIndex)
        actionBlock = [blocks objectForKey:kActionSheetCancelBlockKey];
    else
        actionBlock = [blocks objectForKey:[NSNumber numberWithInteger:buttonIndex]];
    
    if (actionBlock && (![actionBlock isEqual:[NSNull null]]))
        dispatch_async(dispatch_get_main_queue(), actionBlock);
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    __block BKBlock actionBlock = [self.blocks objectForKey:kActionSheetWillShowBlockKey];
    if (actionBlock && (![actionBlock isEqual:[NSNull null]]))
        dispatch_async(dispatch_get_main_queue(), actionBlock);
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet {
    __block BKBlock actionBlock = [self.blocks objectForKey:kActionSheetDidShowBlockKey];
    if (actionBlock && (![actionBlock isEqual:[NSNull null]]))
        dispatch_async(dispatch_get_main_queue(), actionBlock);    
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    __block BKIndexBlock actionBlock = [self.blocks objectForKey:kActionSheetWillDismissBlockKey];
    if (actionBlock && (![actionBlock isEqual:[NSNull null]]))
        dispatch_async(dispatch_get_main_queue(), ^{ actionBlock(buttonIndex); });    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    __block BKIndexBlock actionBlock = [self.blocks objectForKey:kActionSheetDidDismissBlockKey];
    if (actionBlock && (![actionBlock isEqual:[NSNull null]]))
        dispatch_async(dispatch_get_main_queue(), ^{ actionBlock(buttonIndex); });
}

#pragma mark Properties

- (NSMutableDictionary *)blocks {
    NSMutableDictionary *blocks = [self associatedValueForKey:&kActionSheetBlockDictionaryKey];
    if (!blocks) {
        blocks = [[NSMutableDictionary alloc] init];
        self.blocks = blocks;
        [blocks release];
    }
    return blocks;
}

- (void)setBlocks:(NSMutableDictionary *)blocks {
    [self associateValue:blocks withKey:&kActionSheetBlockDictionaryKey];
}

- (BKBlock)cancelBlock {
    return [self.blocks objectForKey:kActionSheetCancelBlockKey];
}

- (void)setCancelBlock:(BKBlock)cancelBlock {
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    if (!self.delegate)
        self.delegate = self;
    if (self.cancelButtonIndex == -1)
        [self setCancelButtonWithTitle:nil handler:cancelBlock];
    else
        [self.blocks setObject:(cancelBlock ? [[cancelBlock copy] autorelease] : [NSNull null]) forKey:kActionSheetCancelBlockKey];
}

- (BKBlock)willShowBlock {
    return [self.blocks objectForKey:kActionSheetWillShowBlockKey];    
}

- (void)setWillShowBlock:(BKBlock)willShowBlock {
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    if (!self.delegate)
        self.delegate = self;
    [self.blocks setObject:(willShowBlock ? [[willShowBlock copy] autorelease] : [NSNull null]) forKey:kActionSheetWillShowBlockKey];
}

- (BKBlock)didShowBlock {
    return [self.blocks objectForKey:kActionSheetDidShowBlockKey];
}

- (void)setDidShowBlock:(BKBlock)didShowBlock {
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    if (!self.delegate)
        self.delegate = self;
    [self.blocks setObject:(didShowBlock ? [[didShowBlock copy] autorelease] : [NSNull null]) forKey:kActionSheetDidShowBlockKey];
}

- (BKIndexBlock)willDismissBlock {
    return [self.blocks objectForKey:kActionSheetWillDismissBlockKey];
}

- (void)setWillDismissBlock:(BKIndexBlock)willDismissBlock {
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    if (!self.delegate)
        self.delegate = self;
    [self.blocks setObject:(willDismissBlock ? [[willDismissBlock copy] autorelease] : [NSNull null]) forKey:kActionSheetWillDismissBlockKey];
}

- (BKIndexBlock)didDismissBlock {
    return [self.blocks objectForKey:kActionSheetDidDismissBlockKey];
}

- (void)setDidDismissBlock:(BKIndexBlock)didDismissBlock {
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    if (!self.delegate)
        self.delegate = self;
    [self.blocks setObject:(didDismissBlock ? [[didDismissBlock copy] autorelease] : [NSNull null]) forKey:kActionSheetDidDismissBlockKey];
}

@end
