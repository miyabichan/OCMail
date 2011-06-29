//
//  MailUtil.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MailUtil.h"
#import "Categories.h"
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

typedef enum {
	NSQuotedPrintable = 0,
	NSBase64,
} NSEncodingType;

@interface MailUtil (PrivateDelegateHandling)
// This function from DINH Viet Hoa
// See http://article.gmane.org/gmane.mail.libetpan.user/377
static int fill_ip_port(mailstream* stream, char* ip_port, size_t local_ip_port_len);
+ (NSString*)createEncodeName:(NSStringEncoding)encoding;
+ (NSStringEncoding)createEncoding:(NSString*)encodeName;
+ (NSEncodingType)createEncodingType:(const char)character;
+ (NSRegularExpression*)createRegExp:(NSString* const)pattern;
+ (NSString*)createAddress:(NSString*)encodedPersonal regExp:(NSRegularExpression*)regExp bracketed:(BOOL)bracketed;
@end


#pragma mark -

@implementation MailUtil

#pragma mark - Private Mathods

// This function from DINH Viet Hoa
// See http://article.gmane.org/gmane.mail.libetpan.user/377
static int fill_ip_port(mailstream* stream, char* ip_port, size_t local_ip_port_len) {
	mailstream_low* low = mailstream_get_low(stream);
	int fd = mailstream_low_get_fd(low);
	struct sockaddr_in name;
	socklen_t namelen = sizeof(name);
	char ip_port_buf[128];
	int r = getpeername(fd, (struct sockaddr*) &name, &namelen);
	if (r < 0)
		return -1;
	
	if (inet_ntop(AF_INET, &name.sin_addr, ip_port_buf, sizeof(ip_port_buf)))
		return -1;
	
	snprintf(ip_port, local_ip_port_len, "%s;%i", ip_port_buf, ntohs(name.sin_port));
	return 0;
}

+ (NSString*)createEncodeName:(NSStringEncoding)encoding {
	switch (encoding) {
		case NSJapaneseEUCStringEncoding:
			return @"EUC-JP";
		case NSUTF8StringEncoding:
			return @"UTF-8";
		case NSISOLatin1StringEncoding:
			return @"ISO-8859-1";
		case NSShiftJISStringEncoding:
			return @"Shift_JIS";
		case NSISOLatin2StringEncoding:
			return @"ISO-8859-2";
		case NSUnicodeStringEncoding:
			return @"UTF-16";
		case NSWindowsCP1251StringEncoding:
			return @"Windows-1251";
		case NSWindowsCP1252StringEncoding:
			return @"Windows-1252";
		case NSWindowsCP1253StringEncoding:
			return @"Windows-1253";
		case NSWindowsCP1254StringEncoding:
			return @"Windows-1254";
		case NSWindowsCP1250StringEncoding:
			return @"Windows-1250";
		case NSISO2022JPStringEncoding:
			return @"ISO-2022-JP";
	}
	return nil;
}

+ (NSStringEncoding)createEncoding:(NSString*)encodeName {
	NSString* lowerName = [encodeName lowercaseString];
	if ([lowerName isEqualToString:@"euc-jp"]) return NSJapaneseEUCStringEncoding;
	if ([lowerName isEqualToString:@"utf-8"]) return NSUTF8StringEncoding;
	if ([lowerName isEqualToString:@"iso-8859-1"]) return NSISOLatin1StringEncoding;
	if ([lowerName isEqualToString:@"shift_jis"]) return NSShiftJISStringEncoding;
	if ([lowerName isEqualToString:@"iso-8859-2"]) return NSISOLatin2StringEncoding;
	if ([lowerName isEqualToString:@"utf-16"]) return NSUnicodeStringEncoding;
	if ([lowerName isEqualToString:@"windows-1251"]) return NSWindowsCP1251StringEncoding;
	if ([lowerName isEqualToString:@"windows-1252"]) return NSWindowsCP1252StringEncoding;
	if ([lowerName isEqualToString:@"windows-1253"]) return NSWindowsCP1253StringEncoding;
	if ([lowerName isEqualToString:@"windows-1254"]) return NSWindowsCP1254StringEncoding;
	if ([lowerName isEqualToString:@"windows-1250"]) return NSWindowsCP1250StringEncoding;
	if ([lowerName isEqualToString:@"iso-2022-jp"]) return NSISO2022JPStringEncoding;
	return NSASCIIStringEncoding;
}

+ (NSEncodingType)createEncodingType:(const char)character {
	switch (character) {
		case 'Q':
			return NSQuotedPrintable;		
		default:
			return NSBase64;
	}
}

+ (NSRegularExpression*)createRegExp:(NSString* const)pattern {
	NSError* error = nil;
	NSRegularExpression* regExp =
	[NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionAnchorsMatchLines error:&error];
	if (error) @throw error;
	
	return regExp;
}

+ (NSString*)createAddress:(NSString*)encodedPersonal regExp:(NSRegularExpression*)regExp bracketed:(BOOL)bracketed {
	NSTextCheckingResult* result= 
	[regExp firstMatchInString:encodedPersonal options:0 range:NSMakeRange(0, [encodedPersonal length])];
	NSString* address = [encodedPersonal substringWithRange:[result range]];
	if (bracketed)
		return [address substringWithRange:NSMakeRange(1, ([address length] - 2))];
	return address;
}


#pragma mark - Public Methods

+ (char*)createFillIpPort:(mailstream*)stream {
	char* ip_port = NULL;
	char ip_port_buf[128];
	int ret = fill_ip_port(stream, ip_port_buf, sizeof(ip_port_buf));
	if (ret >= 0 ) ip_port = ip_port_buf;
	return ip_port;
}

+ (char*)createCharStream:(NSString*)name {
	char* stream = (char*)[name cStringUsingEncoding:NSUTF8StringEncoding];
	if (stream == NULL) stream = "";
	return stream;
}

+ (char*)createMechanism:(AuthMechanism)mechanism {
	NSString* mechaStr = @"";
	switch (mechanism) {
		case PLAIN:
			mechaStr = @"PLAIN";
			break;
		case LOGIN:
			mechaStr = @"LOGIN";
			break;
		case APOP:
			mechaStr = @"APOP";
			break;
		case CRAM_MD5:
			mechaStr = @"CRAM-MD5";
			break;
		case DIGEST_MD5:
			mechaStr = @"DIGEST-MD5";
			break;
		default:
			break;
	}
	return (char*)[mechaStr cStringUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString*)encodePersonal:(NSString*)personal encoding:(NSStringEncoding)encoding {
	if (encoding == NSASCIIStringEncoding) return personal;
	NSString* encName = [self createEncodeName:encoding];
	if ([NSString isEmpty:encName]) return personal;
	NSMutableString* encodedPersonal = [NSMutableString stringWithFormat:@"=?%@", encName];
	[encodedPersonal appendString:@"?B?"]; // Encoding only 'B'("BASE64", RFC2045), No use 'Q'.
	[encodedPersonal appendString:[NSString base64Encode:personal encoding:encoding]];
	[encodedPersonal appendString:@"?="];
	return encodedPersonal;
}

+ (NSString*)decodePersonal:(NSString*)encodedPersonal {
	NSString* beginText = [encodedPersonal substringWithRange:NSMakeRange(0, 2)];
	if (![beginText isEqualToString:@"=?"]) return encodedPersonal;
	NSArray* elements = [encodedPersonal componentsSeparatedByString:@"?"];
	if ([NSArray isEmpty:elements] || elements.count != 5) return encodedPersonal;
	NSString* encodeName = (NSString*)[elements objectAtIndex:1]; // =?(ENCODE_NAME)?(Q or B)?(TEXT)?=
	NSStringEncoding encoding = [self createEncoding:encodeName];
	NSEncodingType type = [self createEncodingType:[((NSString*)[elements objectAtIndex:2]) characterAtIndex:0]]; // =?(ENCODE_NAME)?(Q or B)?(TEXT)?=
	NSString* personal = nil;
	if (type == NSBase64) {
		personal = [NSString base64Decode:(NSString*)[elements objectAtIndex:3] encoding:encoding]; // =?(ENCODE_NAME)?(Q or B)?(TEXT)?=
	} else {
		NSString* personal = [((NSString*)[elements objectAtIndex:3]) stringByReplacingOccurrencesOfString:@"__" withString:@" "]; // =?(ENCODE_NAME)?(Q or B)?(TEXT)?=
		personal = [personal stringByReplacingOccurrencesOfString:@"=" withString:@"%"];
		personal = [personal stringByReplacingPercentEscapesUsingEncoding:encoding];
	}
	return personal;
}

+ (NSString*)createAddress:(NSString*)encodedPersonal {
	NSString* const singlePattern = @"^[[:alnum:]._-]+@[[:alnum:]_-]+\\.[[:alnum:]._-]+$";
	NSString* const mixedPattern = @"<[[:alnum:]._-]+@[[:alnum:]_-]+\\.[[:alnum:]._-]+>$";

	NSString* address = nil;
	
	NSRegularExpression* regExp = [self createRegExp:singlePattern];
	NSUInteger matchCount = [regExp numberOfMatchesInString:encodedPersonal options:0 range:NSMakeRange(0, [encodedPersonal length])];
	if (matchCount > 0) {
		address = [self createAddress:encodedPersonal regExp:regExp bracketed:NO];
	} else {
		regExp = [self createRegExp:mixedPattern];
		matchCount = [regExp numberOfMatchesInString:encodedPersonal options:0 range:NSMakeRange(0, [encodedPersonal length])];
		if (matchCount < 1) return nil;
		address = [self createAddress:encodedPersonal regExp:regExp bracketed:YES];
	}
	return address;
}

@end
