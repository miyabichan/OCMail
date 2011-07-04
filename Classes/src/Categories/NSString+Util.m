//
//  NSString+Util.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSString+Util.h"
#import "NSData+Util.h"

@interface NSString (PrivateDelegateHandling)
+ (BOOL)isSigleByte:(NSString*)character;
@end


@implementation NSString (Util)

#pragma mark - Private Methods

+ (BOOL)isSigleByte:(NSString*)character {
	NSString* const singlePattern = @"[\\x20-\\x7E\\xA1-\\xDF]"; // Multi=Byte character's include 8bit-Kana, accents.
	NSRange match = [character rangeOfString:singlePattern options:NSRegularExpressionSearch];
	if (match.location != NSNotFound) {
		return YES;
	}
	return NO;
}


#pragma mark - Public Methods

+ (BOOL)isEmpty:(NSString*)string {
	if (string == nil) return YES;
	return (BOOL)(string.length == 0);
}

+ (NSString*)urlEncode:(NSString*)source {
	return (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)source, NULL, CFSTR(";,/?:@&=+$#"), kCFStringEncodingUTF8);
}

+ (NSString*)urlDecode:(NSString*)source {
	return (NSString*)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)source, CFSTR(""), kCFStringEncodingUTF8);
}

+ (unsigned int)convertHexString:(NSString*)hex {
	NSScanner* scanner = [NSScanner scannerWithString:hex];
	unsigned int value;
	[scanner scanHexInt:&value];
	return value;
}

static char encodingTable[64] = {
	'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
	'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
	'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
	'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/' };

+ (NSString*)base64Encode:(NSData*)data {
	unsigned long ixtext = 0;
	unsigned long lentext = [data length];
	long ctremaining = 0;
	unsigned char inbuf[3], outbuf[4];
	unsigned short i = 0;
	unsigned short charsonline = 0, ctcopy = 0;
	unsigned long ix = 0;
	const unsigned char *bytes = [data bytes];
	NSMutableString *result = [NSMutableString stringWithCapacity:lentext];
	
	while (1) {
		ctremaining = lentext - ixtext;
		if( ctremaining <= 0 ) break;
		
		for( i = 0; i < 3; i++ ) {
			ix = ixtext + i;
			if( ix < lentext ) inbuf[i] = bytes[ix];
			else inbuf [i] = 0;
		}
		
		outbuf [0] = (inbuf [0] & 0xFC) >> 2;
		outbuf [1] = ((inbuf [0] & 0x03) << 4) | ((inbuf [1] & 0xF0) >> 4);
		outbuf [2] = ((inbuf [1] & 0x0F) << 2) | ((inbuf [2] & 0xC0) >> 6);
		outbuf [3] = inbuf [2] & 0x3F;
		ctcopy = 4;
		
		switch (ctremaining) {
			case 1:
				ctcopy = 2;
				break;
			case 2:
				ctcopy = 3;
				break;
		}
		
		for (i = 0; i < ctcopy; i++) [result appendFormat:@"%c", encodingTable[outbuf[i]]];
		
		for (i = ctcopy; i < 4; i++) [result appendString:@"="];
		
		ixtext += 3;
		charsonline += 4;
	}
	return [NSString stringWithString:result];
}

+ (NSString*)base64Encode:(NSString*)string encoding:(NSStringEncoding)encoding {
	return [self base64Encode:[string dataUsingEncoding:encoding]];
}

+ (NSString*)base64Decode:(NSString*)base64 encoding:(NSStringEncoding)encoding {
	return [[[NSString alloc] initWithData:[NSData base64Decode:base64] encoding:encoding] autorelease];
}

+ (NSString*)base64Decode:(NSString*)base64 {
	NSStringEncoding encoding = [base64 smallestEncoding];
	return [self base64Decode:base64 encoding:encoding];
}

+ (NSUInteger)length:(NSString*)string {
	NSUInteger length = 0;
	NSUInteger i;
	for (i = 0; i < [string length]; ++i) {
		NSString *character = [string substringWithRange:NSMakeRange(i, 1)];
		++length;
		if (![self isSigleByte:character]) {
			++length;
		}
	}
	return length;
}

+ (BOOL)isAsciiOnly:(NSString*)string {
	NSUInteger i;
	for (i = 0; i < [string length]; ++i) {
		NSString* character = [string substringWithRange:NSMakeRange(i, 1)];
		NSString* encoded = [character stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		if (!encoded || [encoded length] > 3) return NO;
	}
	return YES;
}

@end
