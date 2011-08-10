//
//  MimeBody.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MimeBody.h"


@implementation MimeBody

@synthesize text = text_;
@synthesize boundary = boudary_;
@synthesize parts = parts_;

#pragma mark - Inherit Methods

- (void)dealloc {
	self.text = nil;
	self.boundary = nil;
	self.parts = nil;
	[super dealloc];
}

- (NSData*)createBodyData {
	return nil;
}

@end
