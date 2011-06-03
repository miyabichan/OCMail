//
//  POP3Server.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "POP3Server.h"
#import "MailUtil.h"


@interface POP3Server (PrivateDelegateHandling)
- (NSInteger)authWithUserName:(const char*)userName password:(const char*)password address:(const char*)address;
- (carray*)createCArray;
- (NSInteger)sendCommand:(NSString*)str;
@end


@implementation POP3Server

@synthesize pop3 = pop3_;

#define ILLEGAL_OPERATION 999u
#define ILLEGAL_AUTHMECHANISM 9999u

#pragma mark -
#pragma mark Inherit Methods

- (id)init {
	if ((self = [super init])) {
		self.pop3 = mailpop3_new(0, NULL);
	}
	return self;
}

- (void)dealloc {
	mailpop3_free(self.pop3);
	[super dealloc];
}

- (NSInteger)connect {
	assert(self.pop3 != NULL);
	int retCode = MAILPOP3_NO_ERROR;
	if (self.ssl)
		retCode = mailpop3_ssl_connect(self.pop3, [self.address cStringUsingEncoding:NSUTF8StringEncoding], self.portNo);
	else
		retCode = mailpop3_socket_connect(self.pop3, [self.address cStringUsingEncoding:NSUTF8StringEncoding], self.portNo);
	return retCode;
}

- (NSInteger)disconnect {
	assert(self.pop3 != NULL);
	if (self.pop3->pop3_stream == NULL) @throw [NSError errorWithDomain:@"POP3 ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	int retCode = mailpop3_quit(self.pop3);
	return retCode;
}

- (NSInteger)startTLS {
	assert(self.pop3 != NULL);
	if (self.pop3->pop3_stream == NULL) @throw [NSError errorWithDomain:@"POP3 ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	int retCode = mailpop3_socket_starttls(self.pop3);
	return retCode;
}

- (NSInteger)noop {
	assert(self.pop3 != NULL);
	if (self.pop3->pop3_stream == NULL || !self.authorized)
		@throw [NSError errorWithDomain:@"POP3 ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	int retCode = mailpop3_noop(self.pop3);
	return retCode;
}

- (NSInteger)authServer {
	assert(self.pop3 != NULL);
	if (self.pop3->pop3_stream == NULL) @throw [NSError errorWithDomain:@"POP3 ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	char* userName = [MailUtil createCharStream:self.userName];
	char* password = [MailUtil createCharStream:self.password];
	char* address = (char*)[self.address cStringUsingEncoding:NSUTF8StringEncoding];
	return [self authWithUserName:userName password:password address:address];
}


#pragma mark -
#pragma mark Public Methods

- (id)initWithResource:(mailpop3*)pop3 {
	if ((self = [super init])) {
		self.pop3 = pop3;
	}
	return self;
}

- (NSArray*)mailList {
	carray* pop3s = [self createCArray];
	if (!pop3s) return nil;
	NSMutableArray* mails = [NSMutableArray array];
	NSUInteger i;
	for (i = 1; i <= carray_count(pop3s); ++i) {
		char* result = NULL;
		size_t length = 0;
		NSInteger retCode = mailpop3_retr(self.pop3, i, &result, &length);
		if (retCode == MAILPOP3_NO_ERROR && result)
			[mails addObject:[NSString stringWithCString:result encoding:NSUTF8StringEncoding]];
	}
	return mails;
}

- (NSArray*)uidlList {
	carray* pop3s = [self createCArray];
	if (!pop3s) return nil;
	NSMutableArray* uidls = [NSMutableArray array];
	NSUInteger i;
	for (i = 1; i <= carray_count(pop3s); ++i) {
		struct mailpop3_msg_info* msg_info = NULL;
		NSInteger retCode = mailpop3_get_msg_info(self.pop3, i, &msg_info);
		if (retCode == MAILPOP3_NO_ERROR && msg_info && msg_info->msg_uidl)
			[uidls addObject:[NSString stringWithCString:msg_info->msg_uidl encoding:NSUTF8StringEncoding]];
	}
	return uidls;
}

#define UNLIMITED_LINE 0

- (NSArray*)topList {
	carray* pop3s = [self createCArray];
	if (!pop3s) return nil;
	NSMutableArray* tops = [NSMutableArray array];
	NSUInteger i;
	for (i = 1; i <= carray_count(pop3s); ++i) {
		char* result = NULL;
		size_t length = 0;
		NSInteger retCode = mailpop3_top(self.pop3, i, UNLIMITED_LINE, &result, &length);
		if (retCode == MAILPOP3_NO_ERROR)
			[tops addObject:[NSString stringWithCString:result encoding:NSUTF8StringEncoding]];
	}
	return tops;
}

- (NSInteger)delete:(NSUInteger)index {
	assert(self.pop3 != NULL);
	if (self.pop3->pop3_stream == NULL || !self.authorized)
		@throw [NSError errorWithDomain:@"POP3 ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	int retCode = mailpop3_dele(self.pop3, index);
	return retCode;
}

- (NSInteger)reset {
	assert(self.pop3 != NULL);
	if (self.pop3->pop3_stream == NULL || !self.authorized)
		@throw [NSError errorWithDomain:@"POP3 ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	int retCode = mailpop3_rset(self.pop3);
	return retCode;
}

- (NSArray*)capability {
	assert(self.pop3 != NULL);
	if (self.pop3->pop3_stream == NULL) @throw [NSError errorWithDomain:@"POP3 ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	clist* capa_list = NULL;
	NSMutableArray* capas = [NSMutableArray array];
	int retCode = mailpop3_capa(self.pop3, &capa_list);
	if (retCode != MAILPOP3_NO_ERROR || !capa_list) return nil;
	clistiter* iter;
	for (iter = clist_begin(capa_list); iter != NULL; iter = clist_next(iter)) {
		struct mailpop3_capa* pop3_capa = clist_content(iter);
		if (!pop3_capa || !pop3_capa->cap_name) continue;
		NSString* capaName = [NSString stringWithCString:(char*)pop3_capa->cap_name encoding:NSUTF8StringEncoding];
		[capas addObject:capaName];
	}
	if (capa_list) mailpop3_capa_resp_free(capa_list);
	return capas;
}


#pragma mark -
#pragma mark Private Methods

- (NSInteger)authWithUserName:(const char*)userName password:(const char*)password address:(const char*)address {
	int retCode = MAILPOP3_NO_ERROR;
	switch (self.mechanism) {
		case NONE:
			retCode = mailpop3_login(self.pop3, userName, password);
			break;
		case APOP:
			retCode = mailpop3_login_apop(self.pop3, userName, password);
			break;
		default: {
			char* local_ip_port = [MailUtil createFillIpPort:self.pop3->pop3_stream];
			char* remote_ip_port = [MailUtil createFillIpPort:self.pop3->pop3_stream];
			char* mechamism = [MailUtil createMechanism:self.mechanism];
			retCode = mailpop3_auth(self.pop3, mechamism, address, local_ip_port, remote_ip_port, userName, userName, password, address);
		}
			break;
	}
	if (retCode == MAILPOP3_NO_ERROR) self.authorized = YES;
	return retCode;
}

- (carray*)createCArray {
	assert(self.pop3 != NULL);
	if (self.pop3->pop3_stream == NULL || !self.authorized)
		@throw [NSError errorWithDomain:@"POP3 ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	carray* mails = NULL;
	mailpop3_list(self.pop3, &mails);
	return mails;
}

@end
