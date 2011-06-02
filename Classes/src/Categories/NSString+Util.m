//
//  NSString+Util.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSString+Util.h"


@implementation NSString (Util)

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

@end
