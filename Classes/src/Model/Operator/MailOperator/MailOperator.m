//
//  MailOperator.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MailOperator.h"
#import "IMAPServer.h"
#import "POP3Server.h"
#import "SMTPServer.h"


@implementation MailOperator

@synthesize sendServer = sendServer_;
@synthesize receiveServer = receiveServer_;
@synthesize imapUse = imapUse_;


#pragma mark - Public Methods

- (void)createRecieveServer:(MailServer*)receiveServer {
	if ([receiveServer isMemberOfClass:[IMAPServer class]]) {
		self.receiveServer = receiveServer;
		self.imapUse = YES;
	} else if ([receiveServer isMemberOfClass:[POP3Server class]]) {
		self.receiveServer = receiveServer;
		self.imapUse = NO;
	}
	return;
}

- (id)initWithElements:(MailServer*)sendServer receiveServer:(MailServer*)receiveServer {
	if ((self = [super init])) {
		if ([sendServer isKindOfClass:[SMTPServer class]])
			self.sendServer = sendServer;
		[self createRecieveServer:receiveServer];
	}
	return self;
}

- (BOOL)sendMessage {
	return YES;
}

@end
