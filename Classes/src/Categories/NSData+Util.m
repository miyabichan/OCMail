//
//  NSData+Util.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSData+Util.h"
#import "NSString+Util.h"

@interface NSData (PrivateDelegateHandling)
+ (NSData*)base64DecodeWithData:(NSData*)data;
+ (NSData*)base64DecodeWithString:(NSString*)text;
@end


@implementation NSData (Util)

#pragma mark - Private Methods

+ (NSData*)base64DecodeWithData:(NSData*)data {
	unsigned long ixtext = 0;
	unsigned long lentext = [data length];
	unsigned char ch = 0;
	unsigned char inbuf[4], outbuf[3];
	short i = 0, ixinbuf = 0;
	BOOL flignore = NO;
	BOOL flendtext = NO;
	
	const unsigned char *bytes = [data bytes];
	NSMutableData *result = [NSMutableData dataWithCapacity:lentext];
	
	while (1) {
		if(ixtext >= lentext) break;
		ch = bytes[ixtext++];
		flignore = NO;
		
		if((ch >= 'A') && (ch <= 'Z')) ch = ch - 'A';
		else if ((ch >= 'a') && (ch <= 'z')) ch = ch - 'a' + 26;
		else if ((ch >= '0') && (ch <= '9')) ch = ch - '0' + 52;
		else if (ch == '+') ch = 62;
		else if (ch == '=') flendtext = YES;
		else if (ch == '/') ch = 63;
		else flignore = YES;
		
		if(!flignore) {
			short ctcharsinbuf = 3;
			BOOL flbreak = NO;
			
			if (flendtext) {
				if (!ixinbuf) break;
				if ((ixinbuf == 1) || (ixinbuf == 2)) ctcharsinbuf = 1;
				else ctcharsinbuf = 2;
				ixinbuf = 3;
				flbreak = YES;
			}
			
			inbuf [ixinbuf++] = ch;
			
			if(ixinbuf == 4) {
				ixinbuf = 0;
				outbuf [0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
				outbuf [1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
				outbuf [2] = ((inbuf[2] & 0x03) << 6 ) | (inbuf[3] & 0x3F);
				
				for(i = 0; i < ctcharsinbuf; i++)
					[result appendBytes:&outbuf[i] length:1];
			}

			if(flbreak) break;
		}
	}

	return [NSData dataWithData:result];
}

+ (NSData*)base64DecodeWithString:(NSString*)text {
	NSStringEncoding encoding = [text smallestEncoding];
	NSData* data = [text dataUsingEncoding:encoding];
	return [self base64DecodeWithData:data];
}

#pragma mark - Public Methods

+ (BOOL)isEmpty:(NSData*)data {
	if (data == nil) return YES;
	NSString* string = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
	return [NSString isEmpty:string];
}

+ (NSData*)base64Encode:(NSString*)string encoding:(NSStringEncoding)encoding {
	return [[NSString base64Encode:string encoding:encoding] dataUsingEncoding:encoding];
}

+ (NSData*)base64Encode:(NSData*)data {
	return [[NSString base64Encode:data] dataUsingEncoding:NSASCIIStringEncoding];
}

+ (NSData*)base64Decode:(id)base64 {
	if (![base64 class]) return nil;
	if ([base64 isKindOfClass:[NSData class]]) return [self base64DecodeWithData:(NSData*)base64];
	if ([base64 isKindOfClass:[NSString class]]) return [self base64DecodeWithString:(NSString*)base64];
	return nil;
}

@end
