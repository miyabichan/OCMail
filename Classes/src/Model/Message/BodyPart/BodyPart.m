//
//  BodyPart.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BodyPart.h"


@implementation BodyPart

@synthesize contentType = contentType_;
@synthesize encoding = encoding_;
@synthesize description = description_;
@synthesize disposition = disposition_;
@synthesize boundary = boudary_;
@synthesize content = content_;

#pragma mark - Inherit Methods

- (void)dealloc {
	self.contentType = nil;
	self.encoding = nil;
	self.description = nil;
	self.disposition = nil;
	self.boundary = nil;
	self.content = nil;
	[super dealloc];
}

@end
