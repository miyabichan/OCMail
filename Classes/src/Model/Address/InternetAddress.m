//
//  InternetAddress.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InternetAddress.h"
#import "MailUtil.h"


@implementation InternetAddress

@synthesize address = address_;
@synthesize personal = personal_;
@synthesize encodedPersonal = encodedPersonal_;


#pragma mark - Inherit Methods

- (NSString*)description {
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

- (void)createEncodedPersonal:(NSStringEncoding)encoding {
	self.encodedPersonal = [MailUtil encodePersonal:self.personal encoding:encoding];
}

- (void)createEncodedPersonal:(NSString*)personal encoding:(NSStringEncoding)encoding {
	self.personal = personal;
	[self createEncodedPersonal:encoding];
}

- (void)createDecodedPersonal {
	
}

- (void)createDecodedPersonal:(NSString*)encodedPersonal {
	self.encodedPersonal = encodedPersonal;
	
}


@end
