//
//  UIActionSheet+BlocksKit.m
//  BlocksKit
//

#import "UIActionSheet+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"

@interface UIActionSheet (BlocksKitPrivate)
@property (nonatomic, readonly) NSMutableDictionary *handlers;
@end

@implementation UIActionSheet (BlocksKit)

static char *kActionSheetBlockDictionaryKey = "UIActionSheetBlockHandlers"; 
static NSString *kActionSheetWillShowBlockKey = @"UIActionSheetWillShowBlock";
static NSString *kActionSheetDidShowBlockKey = @"UIActionSheetDidShowBlock";
static NSString *kActionSheetWillDismissBlockKey = @"UIActionSheetWillDismissBlock";
static NSString *kActionSheetDidDismissBlockKey = @"UIActionSheetDidDismissBlock";

#pragma mark Initializers

+ (id)sheetWithTitle:(NSString *)title {
    return BK_AUTORELEASE([[UIActionSheet alloc] initWithTitle:title]);
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
    
    block = BK_AUTORELEASE([block copy]);
    [self.handlers setObject:block forKey:[NSNumber numberWithInteger:index]];
    
    return index;
}

- (NSInteger)setDestructiveButtonWithTitle:(NSString *) title handler:(BKBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    
    NSAssert(title.length, @"A button without a title cannot be added to the action sheet.");
    NSInteger index = [self addButtonWithTitle:title];
    self.destructiveButtonIndex = index;
    
    block = BK_AUTORELEASE([block copy]);    
    [self.handlers setObject:block forKey:[NSNumber numberWithInteger:index]];
    
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
    
    block = BK_AUTORELEASE([block copy]);
    [self.handlers setObject:block forKey:[NSNumber numberWithInteger:index]];
    self.cancelButtonIndex = index;
    
    return index;
}

#pragma mark Properties

- (NSMutableDictionary *)handlers {
    NSMutableDictionary *handlers = [self associatedValueForKey:kActionSheetBlockDictionaryKey];
    if (!handlers) {
        handlers = [NSMutableDictionary dictionary];
        [self associateValue:handlers withKey:kActionSheetBlockDictionaryKey];
    }
    return handlers;
}

- (BKBlock)cancelBlock {
    NSNumber *key = [NSNumber numberWithInteger:self.cancelButtonIndex];
    BKBlock block = [self.handlers objectForKey:key];
    return BK_AUTORELEASE([block copy]);
}

- (void)setCancelBlock:(BKBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    
    if (self.cancelButtonIndex == -1) {
        [self setCancelButtonWithTitle:nil handler:block];
    } else {
        NSNumber *key = [NSNumber numberWithInteger:self.cancelButtonIndex];
        
        block = BK_AUTORELEASE([block copy]);
        [self.handlers setObject:block forKey:key];
    }
}

- (BKBlock)willShowBlock {
    BKBlock block = [self.handlers objectForKey:kActionSheetWillShowBlockKey]; 
    return BK_AUTORELEASE([block copy]);   
}

- (void)setWillShowBlock:(BKBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    
    block = BK_AUTORELEASE([block copy]);
    [self.handlers setObject:block forKey:kActionSheetWillShowBlockKey];
}

- (BKBlock)didShowBlock {
    BKBlock block = [self.handlers objectForKey:kActionSheetDidShowBlockKey];
    return BK_AUTORELEASE([block copy]);
}

- (void)setDidShowBlock:(BKBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    
    block = BK_AUTORELEASE([block copy]);
    [self.handlers setObject:block forKey:kActionSheetDidShowBlockKey];
}

- (BKIndexBlock)willDismissBlock {
    BKIndexBlock block = [self.handlers objectForKey:kActionSheetWillDismissBlockKey];
    return BK_AUTORELEASE([block copy]);
}

- (void)setWillDismissBlock:(BKIndexBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    
    block = BK_AUTORELEASE([block copy]);
    [self.handlers setObject:block forKey:kActionSheetWillDismissBlockKey];
}

- (BKIndexBlock)didDismissBlock {
    BKIndexBlock block = [self.handlers objectForKey:kActionSheetDidDismissBlockKey];
    return BK_AUTORELEASE([block copy]);
}

- (void)setDidDismissBlock:(BKIndexBlock)block {
    if (!self.delegate)
        self.delegate = self;
    NSAssert([self.delegate isEqual:self], @"A block-backed button cannot be added when the delegate isn't self.");
    
    block = BK_AUTORELEASE([block copy]);
    [self.handlers setObject:block forKey:kActionSheetDidDismissBlockKey];
}

#pragma mark Delegates

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    BKBlock block = [self.handlers objectForKey:[NSNumber numberWithInteger:buttonIndex]];
    if (block)
        block();
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    BKBlock block = [self.handlers objectForKey:kActionSheetWillShowBlockKey];
    if (block)
        block();
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet {
    BKBlock block = [self.handlers objectForKey:kActionSheetDidShowBlockKey];
    if (block)
        block();
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    BKIndexBlock block = [self.handlers objectForKey:kActionSheetWillDismissBlockKey];
    if (block)
        block(buttonIndex);
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    BKIndexBlock block = [self.handlers objectForKey:kActionSheetDidDismissBlockKey];
    if (block)
        block(buttonIndex);
}

@end
