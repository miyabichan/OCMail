//
//  InternetAddress.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InternetAddress.h"
#import "Categories.h"
#import "MailUtil.h"


@implementation InternetAddress

@synthesize address = address_;
@synthesize personal = personal_;
@synthesize encodedPersonal = encodedPersonal_;


#pragma mark - Inherit Methods

- (void)dealloc {
	self.address = nil;
	self.personal = nil;
	self.encodedPersonal = nil;
	[super dealloc];
}

- (NSString*)description {
	if ([NSString isEmpty:self.address]) return nil;
	if ([NSString isEmpty:self.personal] && [NSString isEmpty:self.encodedPersonal]) return self.address;
	if ([NSString isEmpty:self.encodedPersonal]) self.encodedPersonal = self.personal;
	return [NSString stringWithFormat:@"%@ <%@>", self.encodedPersonal, self.address];
}


#pragma mark - Public Methods

- (id)initWithAddress:(NSString*)address personal:(NSString*)personal {
	if ((self = [super init])) {
		self.address = address;
		self.personal = personal;
	}
	return self;
}

- (id)initWithAddress:(NSString*)address personal:(NSString*)personal encoding:(NSStringEncoding)encoding {
	if ((self = [super init])) {
		self.address = address;
		self.personal = personal;
		self.encodedPersonal = [MailUtil encodeHeader:self.personal encoding:encoding];
	}
	return self;
}

#define TRIM_LENGTH 2

- (void)createEncodedPersonal:(NSStringEncoding)encoding {
	NSArray* texts = [MailUtil createShortTexts:self.personal];
	NSMutableString* encodedPersonal = [NSMutableString string];
	for (NSString* text in texts) {
		[encodedPersonal appendFormat:@"%@\n ", [MailUtil encodeHeader:text encoding:encoding]];
	}
	self.encodedPersonal = [encodedPersonal substringWithRange:NSMakeRange(0, encodedPersonal.length - TRIM_LENGTH)];
}

- (void)createEncodedPersonal:(NSString*)personal encoding:(NSStringEncoding)encoding {
	self.personal = personal;
	[self createEncodedPersonal:encoding];
}

- (void)createDecodedPersonal {
	self.personal = [MailUtil decodeHeader:self.encodedPersonal];
}

- (void)createDecodedPersonal:(NSString*)encodedPersonal {
	self.encodedPersonal = encodedPersonal;
	[self createDecodedPersonal];
}

@end
