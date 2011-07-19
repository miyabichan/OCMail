//
//  MailOperator.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MailOperator.h"
#import "Categories.h"
#import "Server.h"
#import "IMAPServer.h"
#import "POP3Server.h"
#import "SMTPServer.h"


@interface MailOperator (PrivateDelegateHandling)
- (BOOL)connectSendServer;
- (BOOL)authSendServer;
- (BOOL)sendFromAddress:(InternetAddress*)address;
- (BOOL)sendRecipients:(NSArray*)recipients;
@end


@implementation MailOperator

@synthesize sendServer = sendServer_;
@synthesize receiveServer = receiveServer_;
@synthesize folders = folders_;
@synthesize imapUse = imapUse_;


#pragma mark - Inherit Methods

- (void)dealloc {
	self.sendServer = nil;
	self.receiveServer = nil;
	self.folders = nil;
	[super dealloc];
}


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

- (id)initWithSendServer:(MailServer*)sendServer receiveServer:(MailServer*)receiveServer {
	if ((self = [super init])) {
		if ([sendServer isKindOfClass:[SMTPServer class]])
			self.sendServer = sendServer;
		[self createRecieveServer:receiveServer];
	}
	return self;
}

- (BOOL)sendMessage:(MimeMessage*)message {
	assert(self.sendServer != nil && [self.sendServer isKindOfClass:[SMTPServer class]]);
	if (![self connectSendServer]) return NO;
	if (![NSString isEmpty:self.sendServer.userName] && ![self authSendServer]) return NO;
	if (![self sendFromAddress:message.from]) return NO;
	return YES;
}


#pragma mark - Private Methods

- (BOOL)connectSendServer {
	if ([self.sendServer connect] != MAILSMTP_NO_ERROR) return NO;
	return YES;
}

- (BOOL)authSendServer {
	if ([self.sendServer authServer] != MAILSMTP_NO_ERROR) return NO;
	return YES;
}

- (BOOL)sendFromAddress:(InternetAddress*)address {
	if ([((SMTPServer*)self.sendServer) sendFromAddress:address.address] != MAILSMTP_NO_ERROR) return NO;
	return YES;
}

- (BOOL)sendRecipients:(NSArray*)recipients {
	if ([((SMTPServer*)self.sendServer) sendRecipients:recipients] != MAILSMTP_NO_ERROR) return NO;
	return YES;
}

@end
