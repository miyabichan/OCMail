//
//  MailOperatorTest.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/07/19.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MailOperatorTest.h"
#import "SMTPServer.h"
#import "MimeMessage.h"


@implementation MailOperatorTest

- (void)setUp {
	[super setUp];
	_mailOperator = [[MailOperator alloc] init];
}

- (void)tearDown {
	[_mailOperator release];
	[super tearDown];
}

#ifdef USE_CONNECT_SERVER

- (void)testSendMessage {
	_mailOperator.sendServer = [[[SMTPServer alloc] initWithAddress:@"smtp.test.test" portNo:465u ssl:YES userName:@"test" password:@"test"] autorelease]; 
	_mailOperator.sendServer.mechanism = CRAM_MD5;
	MimeMessage* message = [[[MimeMessage alloc] init] autorelease];
	message.from = [[InternetAddress alloc] initWithAddress:@"test@test.jp" personal:@"HOGE FOO"];
	message.subject = @"TEST Subject";
	message.toRecipients = [NSArray arrayWithObject:[[InternetAddress alloc] initWithAddress:@"com@com.com" personal:@""]];
	message.messageBody = [[[MimeBody alloc] init] autorelease];
	BOOL success = [_mailOperator sendMessage:message];
	assertThatBool(success, equalToBool(YES));
}

#endif

- (void)testSendMessage_Failure {
	_mailOperator.sendServer = [[[SMTPServer alloc] initWithAddress:@"xxxx.xxxx.xxx" portNo:25u ssl:NO] autorelease];
	BOOL success = [_mailOperator sendMessage:nil];
	assertThatBool(success, equalToBool(NO));
}

@end
