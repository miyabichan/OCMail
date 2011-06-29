//
//  MimeMessage.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MimeMessage.h"


@implementation MimeMessage

@synthesize messageId = messageId_;
@synthesize subject = subject_;
@synthesize contentType = contentType_;
@synthesize encoding = encoding_;
@synthesize date = date_;
@synthesize from = from_;
@synthesize sender = sender_;
@synthesize replyTo = replyTo_;
@synthesize receiveTo = receiveTo_;
@synthesize receiveCc = receiveCc_;
@synthesize receiveBcc = receiveBcc_;
@synthesize headers = headers_;
@synthesize messageBody = messageBody_;

#pragma mark - Inherit Methods

- (void)dealloc {
	self.messageId = nil;
	self.subject = nil;
	self.contentType = nil;
	self.encoding = nil;
	self.date = nil;
	self.from = nil;
	self.sender = nil;
	self.replyTo = nil;
	self.receiveTo = nil;
	self.receiveCc = nil;
	self.receiveBcc = nil;
	self.headers = nil;
	self.messageBody = nil;
	[super dealloc];
}

#pragma mark - Private Methods

- (NSString*)createMessageString {
	return nil;
}

#pragma mark - Public Methods

- (NSData*)createMessageData {
	return nil;
}


@end
