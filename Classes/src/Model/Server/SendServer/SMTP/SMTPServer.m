//
//  SMTPServer.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SMTPServer.h"
#import "MailUtil.h"


@interface SMTPServer (PrivateDelegateHandling)
- (NSInteger)helo;
- (NSInteger)sendRecipientAddress:(NSString*)email;
@end

@implementation SMTPServer

@synthesize smtp = smtp_;
@synthesize esmtp = esmtp_;

#define ILLEGAL_OPERATION 999u
#define ILLEGAL_AUTHMECHANISM 9999u

#pragma mark -
#pragma mark Inherit Methods

- (id)init {
	if ((self = [super init])) {
		self.smtp = mailsmtp_new(0, NULL);
		self.esmtp = YES;
	}
	return self;
}

- (void)dealloc {
	mailsmtp_free(self.smtp);
	[super dealloc];
}

- (NSInteger)connect {
	assert(self.smtp != NULL);
	int retCode = MAILSMTP_NO_ERROR;
	if (self.ssl)
		retCode = mailsmtp_ssl_connect(self.smtp, [self.address cStringUsingEncoding:NSUTF8StringEncoding], self.portNo);
	else
		retCode = mailsmtp_socket_connect(self.smtp, [self.address cStringUsingEncoding:NSUTF8StringEncoding], self.portNo);
	if (retCode == MAILSMTP_NO_ERROR) self.connected = YES;
	return retCode;
}

- (NSInteger)disconnect {
	assert(self.smtp != NULL);
	if (!self.connected) @throw [NSError errorWithDomain:@"SMTP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	int retCode = mailsmtp_quit(self.smtp);
	if (retCode == MAILSMTP_NO_ERROR) self.connected = NO;
	return retCode;
}

- (NSInteger)startTLS {
	assert(self.smtp != NULL);
	if (!self.esmtp) return MAILSMTP_ERROR_NOT_IMPLEMENTED;
	if (!self.connected) @throw [NSError errorWithDomain:@"SMTP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	int retCode = mailesmtp_starttls(self.smtp);
	if (retCode == MAILSMTP_NO_ERROR) {
		mailstream_low* low = mailstream_get_low(self.smtp->stream);
		int fd = mailstream_low_get_fd(low);
		mailstream_low* modLow = mailstream_low_tls_open(fd);
		mailstream_low_free(low);
		mailstream_set_low(self.smtp->stream, modLow);
		retCode = mailesmtp_ehlo(self.smtp);
	}
	return retCode;
}

- (NSInteger)noop {
	assert(self.smtp != NULL);
	if (!self.connected) @throw [NSError errorWithDomain:@"SMTP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	int retCode = mailsmtp_noop(self.smtp);
	return retCode;
}

- (NSInteger)authServer {
	assert(self.smtp != NULL && self.mechanism != NONE && self.mechanism != APOP);
	if (!self.connected) @throw [NSError errorWithDomain:@"SMTP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	char* userName = [MailUtil createCharStream:self.userName];
	char* password = [MailUtil createCharStream:self.password];
	char* address = (char*)[self.address cStringUsingEncoding:NSUTF8StringEncoding];
	char* local_ip_port = [MailUtil createFillIpPort:self.smtp->stream];
	char* remote_ip_port = [MailUtil createFillIpPort:self.smtp->stream];
	char* mechanism = [MailUtil createMechanism:self.mechanism];
	int retCode = mailesmtp_auth_sasl(self.smtp, mechanism, address, local_ip_port, remote_ip_port, userName, userName, password, address);
	return retCode;
}


#pragma mark -
#pragma mark Public Methods

- (id)initWithResource:(mailsmtp*)smtp {
	if ((self = [super init])) {
		self.smtp = smtp;
		self.esmtp = YES;
	}
	return self;
}

- (BOOL)elho {
	assert(self.smtp != NULL);
	if (!self.connected) @throw [NSError errorWithDomain:@"SMTP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	int retCode = mailesmtp_ehlo(self.smtp);
	if (retCode == MAILSMTP_ERROR_NOT_IMPLEMENTED) {
		self.esmtp = NO;
		NSLog(@"ESMTP isnot supported....");
		retCode = [self helo];
	}
	return (retCode == MAILSMTP_NO_ERROR) ? YES : NO;
}

- (NSInteger)sendFromAddress:(NSString*)email {
	assert(self.smtp != NULL);
	if (!self.connected) @throw [NSError errorWithDomain:@"SMTP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	int retCode = mailsmtp_mail(self.smtp, [email cStringUsingEncoding:NSUTF8StringEncoding]);
	return retCode;
}

- (NSInteger)sendRecipients:(NSArray*)recipients {
	NSInteger retCode = MAILSMTP_NO_ERROR;
	for (NSDictionary* addressDic in recipients) {
		if (retCode != MAILSMTP_NO_ERROR) break;
		retCode = [self sendRecipientAddress:(NSString*)[addressDic objectForKey:@"email"]];
	}
	return retCode;
}

- (NSInteger)sendMessage:(NSData*)message {
	assert(self.smtp != NULL);
	if (!self.connected) @throw [NSError errorWithDomain:@"SMTP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	int retCode = mailsmtp_data(self.smtp);
	if (retCode == MAILSMTP_NO_ERROR) {
		retCode = mailsmtp_data_message(self.smtp, (const char*)[message bytes], (size_t)[message length]);
	}
	return retCode;
}

#pragma mark -
#pragma mark Private Methods

- (NSInteger)helo {
	assert(self.smtp != NULL);
	if (!self.connected) @throw [NSError errorWithDomain:@"SMTP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	int retCode = mailsmtp_helo(self.smtp);
	return retCode;
}

- (NSInteger)sendRecipientAddress:(NSString*)email {
	assert(self.smtp != NULL);
	if (!self.connected) @throw [NSError errorWithDomain:@"SMTP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	int retCode = mailsmtp_rcpt(self.smtp, [email cStringUsingEncoding:NSUTF8StringEncoding]);
	return retCode;
}


@end
