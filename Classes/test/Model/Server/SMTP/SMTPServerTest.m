//
//  SMTPServerTest.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SMTPServerTest.h"
#import "Categories.h"
#import "PrimitiveToNumber.h"

@implementation SMTPServerTest

- (void)setUp {
	[super setUp];
	_smtpServer = [[SMTPServer alloc] init];
}

- (void)tearDown {
	[_smtpServer release];
	[super tearDown];
}

- (void)testInit {
	assertThat(_smtpServer, notNilValue());
	NSString* addrStr = [NSString stringWithFormat:@"%p", _smtpServer.smtp];
	NSLog(@"addrstr: %@", addrStr);
	unsigned int addr = [NSString convertHexString:addrStr];
	assertThatInt(addr, greaterThan(numberInt(0)));
	NSLog(@"addr: %d", addr);
}

- (void)testInitWithSMTP {
	[_smtpServer release];
	_smtpServer = [[SMTPServer alloc] initWithResource:mailsmtp_new(0, NULL)];
	assertThat(_smtpServer, notNilValue());
	NSString* addrStr = [NSString stringWithFormat:@"%p", _smtpServer.smtp];
	NSLog(@"addrstr: %@", addrStr);
	unsigned int addr = [NSString convertHexString:addrStr];
	assertThatInt(addr, greaterThan(numberInt(0)));
	NSLog(@"addr: %d", addr);
}

#ifdef SMTP_CONNECT

- (void)testConnect {
	_smtpServer.address = @"mail.mail.mail";
	_smtpServer.portNo = 25u;
	NSInteger ret = [_smtpServer connect];
	assertThatInt(ret, equalToInt(MAILSMTP_NO_ERROR));
}

- (void)testConnect_SSL {
	_smtpServer.address = @"mail.mail.mail";
	_smtpServer.portNo = 465u;
	_smtpServer.ssl = YES;
	NSInteger ret = [_smtpServer connect];
	assertThatInt(ret, equalToInt(MAILSMTP_NO_ERROR));
}

- (void)testConnect_NotExist {
	_smtpServer.address = @"yyyy.ooooo";
	_smtpServer.portNo = 1080u;
	NSInteger ret = [_smtpServer connect];
	assertThatInteger(ret, isNot(equalToInt(MAILSMTP_NO_ERROR)));
}

- (void)testDisconnect {
	_smtpServer.address = @"mail.mail.mail";
	_smtpServer.portNo = 25u;
	NSInteger ret = [_smtpServer connect];
	assertThat(numberInt(ret), equalToInt(MAILSMTP_NO_ERROR));
	ret = [_smtpServer disconnect];
	assertThatInteger(ret, equalToInt(MAILSMTP_NO_ERROR));
}

- (void)testDisconnect_Error {
	_smtpServer.address = @"mail.mail.mail";
	_smtpServer.portNo = 25u;
	@try {
		[_smtpServer disconnect];
		STFail(nil);
	} @catch (NSError* e) {
		assertThat(e, notNilValue());
		assertThat([e domain], equalTo(@"SMTP ERROR"));
		assertThatInt([e code], equalTo(numberInt(999u)));
	}
}

- (void)testEhlo {
	_smtpServer.address = @"mail.mail.mail";
	_smtpServer.portNo = 25u;
	NSInteger ret = [_smtpServer connect];
	assertThat(numberInt(ret), equalToInt(MAILSMTP_NO_ERROR));
	BOOL ehlo = [_smtpServer elho];
	assertThatBool(ehlo, equalToBool(YES));
}

- (void)testEhlo_Error {
	_smtpServer.address = @"mail.mail.mail";
	_smtpServer.portNo = 25u;
	@try {
		[_smtpServer elho];
		STFail(nil);
	} @catch (NSError* e) {
		assertThat(e, notNilValue());
		assertThat([e domain], equalTo(@"SMTP ERROR"));
		assertThatInt([e code], equalTo(numberInt(999u)));
	}
}

- (void)testEhlo_ConnectError {
	_smtpServer.address = @"yyyy.ooooo";
	_smtpServer.portNo = 1080u;
	@try {
		[_smtpServer connect];
		[_smtpServer elho];
		STFail(nil);
	} @catch (NSError* e) {
		assertThat(e, notNilValue());
		assertThat([e domain], equalTo(@"SMTP ERROR"));
		assertThatInt([e code], equalTo(numberInt(999u)));
	}
}

- (void)testNoop {
	_smtpServer.address = @"mail.mail.mail";
	_smtpServer.portNo = 25u;
	NSInteger ret = [_smtpServer connect];
	assertThat(numberInt(ret), equalToInt(MAILSMTP_NO_ERROR));
	ret = [_smtpServer noop];
	assertThat(numberInt(ret), equalToInt(MAILSMTP_NO_ERROR));
}

- (void)testNoop_Error {
	_smtpServer.address = @"mail.mail.mail";
	_smtpServer.portNo = 25u;
	@try {
		[_smtpServer noop];
	} @catch (NSError* e) {
		assertThat(e, notNilValue());
		assertThat([e domain], equalTo(@"SMTP ERROR"));
		assertThatInt([e code], equalTo(numberInt(999u)));
	}
}

- (void)testNoop_ConnectError {
	_smtpServer.address = @"yyyy.ooooo";
	_smtpServer.portNo = 1080u;
	@try {
		[_smtpServer connect];
		[_smtpServer noop];
	} @catch (NSError* e) {
		assertThat(e, notNilValue());
		assertThat([e domain], equalTo(@"SMTP ERROR"));
		assertThatInt([e code], equalTo(numberInt(999u)));
	}
}

- (void)checkConnection {
	NSInteger ret = [_smtpServer connect];
	assertThat(numberInt(ret), equalToInt(MAILSMTP_NO_ERROR));
	BOOL ehlo = [_smtpServer elho];
	assertThatBool(ehlo, equalToBool(YES));
}

- (void)testStartTLS {
	_smtpServer.address = @"mail.mail.mail";
	_smtpServer.portNo = 587u;
	[self checkConnection];
	NSInteger ret = [_smtpServer startTLS];
	assertThat(numberInt(ret), equalToInt(MAILSMTP_NO_ERROR));
}

#ifdef USE_SMTP_AUTH

- (void)testAuthServer {
	_smtpServer.address = @"mail.mail.mail";
	_smtpServer.portNo = 25u;
	_smtpServer.userName = @"anyuser";
	_smtpServer.password = @"password";
	_smtpServer.mechanism = PLAIN;
	[self checkConnection];
	NSInteger ret = [_smtpServer authServer];
	assertThat(numberInt(ret), equalToInt(MAILSMTP_NO_ERROR));
}

- (void)testAuthServer_CRAMMD5 {
	_smtpServer.address = @"mail.mail.mail";
	_smtpServer.portNo = 465u;
	_smtpServer.userName = @"anyuser";
	_smtpServer.password = @"password";
	_smtpServer.mechanism = CRAM_MD5;
	_smtpServer.ssl = YES;
	[self checkConnection];
	NSInteger ret = [_smtpServer authServer];
	assertThat(numberInt(ret), equalToInt(MAILSMTP_NO_ERROR));

}

- (void)testAuthServer_DIGESTMD5 {
	_smtpServer.address = @"mail.mail.mail";
	_smtpServer.portNo = 587u;
	_smtpServer.userName = @"anyuser";
	_smtpServer.password = @"password";
	_smtpServer.mechanism = DIGEST_MD5;
	_smtpServer.ssl = YES;
	[self checkConnection];
	NSInteger ret = [_smtpServer authServer];
	assertThat(numberInt(ret), equalToInt(MAILSMTP_NO_ERROR));
}

#endif

- (void)testSendFromAddress {
	_smtpServer.address = @"mail.mail.mail";
	_smtpServer.portNo = 25u;
	[self checkConnection];
	NSInteger ret = [_smtpServer sendFromAddress:@"foo@foo.foo"];
	assertThat(numberInt(ret), equalToInt(MAILSMTP_NO_ERROR));
}

- (void)testSendRecipients {
	_smtpServer.address = @"mail.mail.mail";
	_smtpServer.portNo = 25u;
	NSArray* array = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObject:@"hoge@hoge.jp" forKey:@"email"], [NSDictionary dictionaryWithObject:@"foo@foo.jp" forKey:@"email"], nil];
	[self checkConnection];
	NSInteger ret = [_smtpServer sendFromAddress:@"foo@foo.foo"];
	assertThat(numberInt(ret), equalToInt(MAILSMTP_NO_ERROR));
	ret = [_smtpServer sendRecipients:array];
	assertThat(numberInt(ret), equalToInt(MAILSMTP_NO_ERROR));
}

#ifdef SENDMAIL_TEST

- (void)testSendMessage {
	_smtpServer.address = @"mail.mail.mail";
	_smtpServer.portNo = 25u;
	NSArray* array = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObject:@"anyone@mail.mail" forKey:@"email"], [NSDictionary dictionaryWithObject:@"name@mail.mail" forKey:@"email"], nil];
	[self checkConnection];
	NSInteger ret = [_smtpServer sendFromAddress:@"me@mail.mail"];
	assertThat(numberInt(ret), equalToInt(MAILSMTP_NO_ERROR));
	ret = [_smtpServer sendRecipients:array];
	assertThat(numberInt(ret), equalToInt(MAILSMTP_NO_ERROR));
	NSString* format = @"Date: %@\r\nFrom: me@mail.mail\r\nTo: anyone@mail.mail\r\nCc: name@mail.mail\r\nSubject: OCUnit Test\r\n\r\nSend to Test Mail.";
	NSString* message = [NSString stringWithFormat:format, [NSDate dateToRFC2822:[NSDate date]]];
	ret = [_smtpServer sendMessage:[message dataUsingEncoding:NSUTF8StringEncoding]];
	assertThat(numberInt(ret), equalToInt(MAILSMTP_NO_ERROR));
}

#endif

#endif

@end
