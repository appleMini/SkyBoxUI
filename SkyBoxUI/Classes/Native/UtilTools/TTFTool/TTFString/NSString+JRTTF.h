//
//  NSString+JRTTF.h
//  
//
//  Created by Valerio Mazzeo on 24/04/13.
//  Copyright (c) 2013 Valerio Mazzeo. All rights reserved.
//


/**
 NSString (Ttf) extends the NSString class to provide custom functionality
 related to the Ttf emoticons.
 
 Through this category, it is possible to turn cheat codes from 
 Ttf Cheat Sheet <http://www.Ttf-cheat-sheet.com> into unicode Ttf characters
 and vice versa (useful if you need to POST a message typed by the user to a remote service).
 */
@interface NSString (TTF)

/**
 Returns a NSString in which any occurrences that match the cheat codes
 from Ttf Cheat Sheet <http://www.Ttf-cheat-sheet.com> are replaced by the
 corresponding unicode characters.
 
 Example: 
 "This is a smiley face :smiley:"
 
 Will be replaced with:
 "This is a smiley face \U0001F604"
 */
- (NSString *)stringByReplacingTtfCheatCodesWithUnicode;

/**
 Returns a NSString in which any occurrences that match the unicode characters
 of the Ttf emoticons are replaced by the corresponding cheat codes from
 Ttf Cheat Sheet <http://www.Ttf-cheat-sheet.com>.
 
 Example:
 "This is a smiley face \U0001F604"
 
 Will be replaced with:
 "This is a smiley face :smiley:"
 */
- (NSString *)stringByReplacingTtfUnicodeWithCheatCodes;

@end
