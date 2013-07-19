//
//  NSString+BlocksKit.m
//  BlocksKit
//
//  Created by Terry Lewis II on 7/19/13.
//  Copyright (c) 2013 Pandamonia LLC. All rights reserved.
//

#import "NSString+BlocksKit.h"

@implementation NSString (BlocksKit)

- (NSString *)filter:(BKStringFilterBlock)block {
    BOOL passedTest = NO;
    NSMutableString *mutableString = [NSMutableString string];
    for(NSUInteger i = 0; i < self.length; i++) {
        NSString *subString = [self substringWithRange:NSMakeRange(i, 1)];
        passedTest = block(subString, i);
        if(passedTest) [mutableString appendString:subString];
    }
    return [NSString stringWithString:mutableString];
}

- (NSString *)map:(BKStringTransformBlock)block {
    NSMutableString *mutableString = [NSMutableString string];
    for(NSUInteger i = 0; i < self.length; i++) {
        NSString *subString = [self substringWithRange:NSMakeRange(i, 1)];
        [mutableString appendString:block(subString, i)];
    }
    return [NSString stringWithString:mutableString];
}

-(BOOL)anyCharacter:(BKStringFilterBlock)block {
    BOOL passedTest = NO;
    for(NSUInteger i = 0; i < self.length; i++) {
        NSString *subString = [self substringWithRange:NSMakeRange(i, 1)];
        passedTest = block(subString, i);
        if(passedTest) break;
    }
    return passedTest;
}

-(BOOL)anyWord:(BKStringFilterBlock)block {
    BOOL passedTest = NO;
    NSArray *words = [self componentsSeparatedByString:@" "];
    for(NSUInteger i = 0; i < words.count; i++) {
        passedTest = block(words[i], i);
        if(passedTest) break;
    }
    return passedTest;
}

-(BOOL)allCharacters:(BKStringFilterBlock)block {
    BOOL passedTest = NO;
    for(NSUInteger i = 0; i < self.length; i++) {
        NSString *subString = [self substringWithRange:NSMakeRange(i, 1)];
        passedTest = block(subString, i);
        if(!passedTest) break;
    }
    return passedTest;
}

-(BOOL)allWords:(BKStringFilterBlock)block {
    BOOL passedTest = NO;
    NSArray *words = [self componentsSeparatedByString:@" "];
    for(NSUInteger i = 0; i < words.count; i++) {
        passedTest = block(words[i], i);
        if(!passedTest) break;
    }
    return passedTest;
}

@end
