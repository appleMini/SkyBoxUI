//
//  NSString+JRTTF.m
//
//
//  Created by Valerio Mazzeo on 24/04/13.
//  Copyright (c) 2013 Valerio Mazzeo. All rights reserved.
//

#import "NSString+JRTTF.h"

@implementation NSString (TTF)

static NSDictionary * s_unicodeToCheatCodes = nil;
static NSDictionary * s_cheatCodesToUnicode = nil;

+ (void)initializeTtfCheatCodes
{
    NSDictionary *forwardMap = @{
                                @"\U0000e600": @":wxz:",
                                @"\U0000e601": @":xz:",
                                @"\U0000e602": @":yjt:",
                                @"\U0000e603": @":fh2:",
                                @"\U0000e604": @":pz:",
                                
                                @"\U0000e605": @":th:",
                                @"\U0000e61c": @":jujue:",
                                @"\U0000e606": @":xz2:",
                                @"\U0000e607": @":zdlj:",
                                @"\U0000e608": @":zdlj2:",
                                @"\U0000e609": @":wry:",
                                
                                @"\U0000e60a": @":yyjr:",
                                @"\U0000e60b": @":cx-dj:",
                                @"\U0000e60c": @":cx-mr:",
                                @"\U0000e60d": @":sz-dj:",
                                @"\U0000e60e": @":sz-mr:",
                                @"\U0000e60f": @":wddj-dj:",
                                @"\U0000e617": @":q-x1:",
                                @"\U0000e618": @":q-x2:",
                                @"\U0000e619": @":q-x3:",
                                @"\U0000e61a": @":q-x4:",
                                @"\U0000e61b": @":pm-xz:"
    };
        


    NSMutableDictionary *reversedMap = [NSMutableDictionary dictionaryWithCapacity:[forwardMap count]];
    [forwardMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSArray class]]) {
            for (NSString *object in obj) {
                [reversedMap setObject:key forKey:object];
            }
        } else {
            [reversedMap setObject:key forKey:obj];
        }
    }];

    @synchronized(self) {
        s_unicodeToCheatCodes = forwardMap;
        s_cheatCodesToUnicode = [reversedMap copy];
    }
}

- (NSString *)stringByReplacingTtfCheatCodesWithUnicode
{
    if (!s_cheatCodesToUnicode) {
        [NSString initializeTtfCheatCodes];
    }
    
    if ([self rangeOfString:@":"].location != NSNotFound) {
        __block NSMutableString *newText = [NSMutableString stringWithString:self];
        [s_cheatCodesToUnicode enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            [newText replaceOccurrencesOfString:key withString:obj options:NSLiteralSearch range:NSMakeRange(0, newText.length)];
        }];
        return newText;
    }
    
    return self;
}

- (NSString *)stringByReplacingTtfUnicodeWithCheatCodes
{
    if (!s_cheatCodesToUnicode) {
        [NSString initializeTtfCheatCodes];
    }
    
    if (self.length) {
        __block NSMutableString *newText = [NSMutableString stringWithString:self];
        [s_unicodeToCheatCodes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *string = ([obj isKindOfClass:[NSArray class]] ? [obj firstObject] : obj);
            [newText replaceOccurrencesOfString:key withString:string options:NSLiteralSearch range:NSMakeRange(0, newText.length)];
        }];
        return newText;
    }
    return self;
}

@end
