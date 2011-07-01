//
//  NSString+Util.h
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (Util)

+ (BOOL)isEmpty:(NSString*)string;

+ (NSString*)urlEncode:(NSString*)source;

+ (NSString*)urlDecode:(NSString*)source;

+ (unsigned int)convertHexString:(NSString*)hex;

+ (NSString*)base64Encode:(NSData*)data;

+ (NSString*)base64Encode:(NSString*)string encoding:(NSStringEncoding)encoding;

+ (NSString*)base64Decode:(NSString*)base64 encoding:(NSStringEncoding)encoding;

+ (NSString*)base64Decode:(NSString*)base64;

+ (NSUInteger)length:(NSString*)string;

@end
