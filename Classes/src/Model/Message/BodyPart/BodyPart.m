//
//  BodyPart.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BodyPart.h"


@implementation BodyPart

@synthesize fileName = fileName_;
@synthesize contentType = contentType_;
@synthesize description = description_;
@synthesize disposition = disposition_;
@synthesize content = content_;
@synthesize encoding = encoding_;

#pragma mark - Inherit Methods

- (void)dealloc {
	self.fileName = nil;
	self.contentType = nil;
	self.description = nil;
	self.disposition = nil;
	self.content = nil;
	[super dealloc];
}

#pragma mark - Public Methods

- (id)initWithContent:(NSData*)content fileName:(NSString*)fileName contentType:(NSString*)contentType {
	if ((self = [super init])) {
		self.content = content;
		self.fileName = fileName;
		self.contentType = contentType;
	}
	return self;
}

- (id)initWithContent:(NSData*)content fileName:(NSString*)fileName contentType:(NSString*)contentType encoding:(NSStringEncoding)encoding {
	if ((self = [super init])) {
		self.content = content;
		self.fileName = fileName;
		self.contentType = contentType;
		self.encoding = encoding;
	}
	return self;
}

@end
