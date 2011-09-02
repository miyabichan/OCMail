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
- (NSArray*)createRecipients:(MimeMessage*)message;
- (BOOL)sendMimeMessage:(MimeMessage*)message;
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
	if (![self authSendServer]) return NO;
	if (![NSString isEmpty:self.sendServer.userName] && ![self authSendServer]) return NO;
	if (![self sendFromAddress:message.from]) return NO;
	if (![self sendRecipients:[self createRecipients:message]]) return NO;
	if (![self sendMimeMessage:message]) return NO;
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
	if ([NSArray isEmpty:recipients]) return NO;
	if ([((SMTPServer*)self.sendServer) sendRecipients:recipients] != MAILSMTP_NO_ERROR) return NO;
	return YES;
}

- (NSArray*)createRecipients:(MimeMessage*)message {
	NSMutableArray* recipients = [NSMutableArray array];
	if (![NSArray isEmpty:message.toRecipients]) [recipients addObjectsFromArray:message.toRecipients];
	if (![NSArray isEmpty:message.ccRecipients]) [recipients addObjectsFromArray:message.ccRecipients];
	if (![NSArray isEmpty:message.bccRecipients]) [recipients addObjectsFromArray:message.bccRecipients];
	return recipients;
}

- (BOOL)sendMimeMessage:(MimeMessage*)message {
	NSData* messageData = [message createMessageData];
	if ([NSData isEmpty:messageData]) return NO;
	if ([(SMTPServer*)self.sendServer sendMessage:messageData] != MAILSMTP_NO_ERROR) return NO;
	return YES;
}

@end
