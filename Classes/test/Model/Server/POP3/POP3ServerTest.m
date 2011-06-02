//
//  POP3ServerTest.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "POP3ServerTest.h"
#import "Categories.h"
#import "PrimitiveToNumber.h"


@implementation POP3ServerTest

- (void)setUp {
	[super setUp];
	_pop3Server = [[POP3Server alloc] init];
}

- (void)tearDown {
	[_pop3Server release];
	[super tearDown];
}

- (void)testInit {
	assertThat(_pop3Server, notNilValue());
	NSString* addrStr = [NSString stringWithFormat:@"%p", _pop3Server.pop3];
	NSLog(@"addrstr: %@", addrStr);
	unsigned int addr = [NSString convertHexString:addrStr];
	assertThatInt(addr, greaterThan(numberInt(0)));
	NSLog(@"addr: %d", addr);
}

- (void)testInitWihResouce {
	[_pop3Server release];
	_pop3Server = [[POP3Server alloc] initWithResource:mailpop3_new(0, NULL)];
	assertThat(_pop3Server, notNilValue());
	NSString* addrStr = [NSString stringWithFormat:@"%p", _pop3Server.pop3];
	NSLog(@"addrstr: %@", addrStr);
	unsigned int addr = [NSString convertHexString:addrStr];
	assertThatInt(addr, greaterThan(numberInt(0)));
	NSLog(@"addr: %d", addr);
}

#ifdef POP3_CONNECT

- (void)testConnect {
	_pop3Server.address = @"mail.mail.mail";
	_pop3Server.portNo = 110u;
	NSInteger ret = [_pop3Server connect];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
}

- (void)testConnect_SSL {
	_pop3Server.address = @"mail.mail.mail";
	_pop3Server.portNo = 995u;
	_pop3Server.ssl = YES;
	NSInteger ret = [_pop3Server connect];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
}

- (void)testConnect_NoExist {
	_pop3Server.address = @"xxxxxx.aaaa";
	_pop3Server.portNo = 9990u;
	NSInteger ret = [_pop3Server connect];
	assertThatInt(ret, isNot(equalToInteger(MAILPOP3_NO_ERROR)));
}

- (void)testDisconnect {
	_pop3Server.address = @"mail.mail.mail";
	_pop3Server.portNo = 110u;
	NSInteger ret = [_pop3Server connect];
	assertThat(numberInt(ret), equalToInt(MAILPOP3_NO_ERROR));
	ret = [_pop3Server disconnect];
	assertThatInteger(ret, equalToInt(MAILPOP3_NO_ERROR));
}

- (void)testDisconnect_Error {
	_pop3Server.address = @"mail.mail.mail";
	_pop3Server.portNo = 110u;
	@try {
		[_pop3Server disconnect];
		STFail(nil);
	} @catch (NSError* e) {
		assertThat(e, notNilValue());
		assertThat([e domain], equalTo(@"POP ERROR"));
		assertThatInt([e code], equalTo(numberInt(999u)));
	}
}

- (void)testStartTLS {
	_pop3Server.address = @"mail.mail.mail";
	_pop3Server.portNo = 110u;
	NSInteger ret = [_pop3Server connect];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
	ret = [_pop3Server startTLS];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
}


- (void)testNoop {
	_pop3Server.address = @"mail.mail.mail";
	_pop3Server.portNo = 110u;
	_pop3Server.userName = @"anyuser";
	_pop3Server.password = @"password";
	_pop3Server.mechanism = NONE;
	NSInteger ret = [_pop3Server connect];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
	ret = [_pop3Server authServer];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
	ret = [_pop3Server noop];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
}

#ifdef USE_POP3_AUTH

- (void)testAuthServer {
	_pop3Server.address = @"mail.mail.mail";
	_pop3Server.portNo = 110u;
	_pop3Server.userName = @"anyuser";
	_pop3Server.password = @"password";
	_pop3Server.mechanism = NONE;
	NSInteger ret = [_pop3Server connect];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
	ret = [_pop3Server authServer];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
}

- (void)testAuthServer_SSL {
	_pop3Server.address = @"mail.mail.mail";
	_pop3Server.portNo = 995u;
	_pop3Server.userName = @"anyuser";
	_pop3Server.password = @"password";
	_pop3Server.mechanism = NONE;
	_pop3Server.ssl = YES;
	NSInteger ret = [_pop3Server connect];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
	ret = [_pop3Server authServer];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
}

- (void)testAuthServer_PLAIN {
	_pop3Server.address = @"mail.mail.mail";
	_pop3Server.portNo = 110u;
	_pop3Server.userName = @"anyuser";
	_pop3Server.password = @"password";
	_pop3Server.mechanism = PLAIN;
	NSInteger ret = [_pop3Server connect];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
	ret = [_pop3Server authServer];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
}

- (void)testAuthServer_CRAMMD5 {
	_pop3Server.address = @"mail.mail.mail";
	_pop3Server.portNo = 995u;
	_pop3Server.userName = @"anyuser";
	_pop3Server.password = @"password";
	_pop3Server.mechanism = CRAM_MD5;
	_pop3Server.ssl = YES;
	NSInteger ret = [_pop3Server connect];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
	ret = [_pop3Server authServer];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
}

- (void)testAuthServer_DIGESTMD5 {
	_pop3Server.address = @"mail.mail.mail";
	_pop3Server.portNo = 995u;
	_pop3Server.userName = @"anyuser";
	_pop3Server.password = @"password";
	_pop3Server.mechanism = DIGEST_MD5;
	_pop3Server.ssl = YES;
	NSInteger ret = [_pop3Server connect];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
	ret = [_pop3Server authServer];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
}

- (void)testAuthServer_APOP {
	_pop3Server.address = @"mail.mail.mail";
	_pop3Server.portNo = 110u;
	_pop3Server.userName = @"anyuser";
	_pop3Server.password = @"password";
	_pop3Server.mechanism = APOP;
	NSInteger ret = [_pop3Server connect];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
	ret = [_pop3Server authServer];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
}

- (void)testMailList {
	_pop3Server.address = @"mail.mail.mail";
	_pop3Server.portNo = 995u;
	_pop3Server.userName = @"anyuser";
	_pop3Server.password = @"password";
	_pop3Server.ssl = YES;
	_pop3Server.mechanism = CRAM_MD5;
	NSInteger ret = [_pop3Server connect];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
	ret = [_pop3Server authServer];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
	NSArray* array = [_pop3Server mailList];
	assertThatInteger(array.count, greaterThan(numberInt(0)));
	for (NSString* mail in array)
		NSLog(@"mail:\n%@", mail);
}

- (void)testUIDLList {
	_pop3Server.address = @"mail.mail.mail";
	_pop3Server.portNo = 995u;
	_pop3Server.userName = @"anyuser";
	_pop3Server.password = @"password";
	_pop3Server.ssl = YES;
	_pop3Server.mechanism = CRAM_MD5;
	NSInteger ret = [_pop3Server connect];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
	ret = [_pop3Server authServer];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
	NSArray* array = [_pop3Server uidlList];
	assertThatInteger(array.count, greaterThan(numberInt(0)));
	for (NSString* uidl in array)
		NSLog(@"uidl:\n%@", uidl);
}

- (void)testTopList {
	_pop3Server.address = @"mail.mail.mail";
	_pop3Server.portNo = 995u;
	_pop3Server.userName = @"anyuser";
	_pop3Server.password = @"password";
	_pop3Server.ssl = YES;
	_pop3Server.mechanism = CRAM_MD5;
	NSInteger ret = [_pop3Server connect];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
	ret = [_pop3Server authServer];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
	NSArray* array = [_pop3Server topList];
	assertThatInteger(array.count, greaterThan(numberInt(0)));
	for (NSString* top in array)
		NSLog(@"top:\n%@", top);
}

- (void)testDeleRset {
	_pop3Server.address = @"mail.mail.mail";
	_pop3Server.portNo = 995u;
	_pop3Server.userName = @"anyuser";
	_pop3Server.password = @"password";
	_pop3Server.ssl = YES;
	_pop3Server.mechanism = CRAM_MD5;
	NSInteger ret = [_pop3Server connect];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
	ret = [_pop3Server authServer];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
	ret = [_pop3Server deleMail:1];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
	ret = [_pop3Server rset];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
}

- (void)testCapability {
	_pop3Server.address = @"mail.mail.mail";
	_pop3Server.portNo = 995u;
	_pop3Server.userName = @"anyuser";
	_pop3Server.password = @"password";
	_pop3Server.ssl = YES;
	_pop3Server.mechanism = CRAM_MD5;
	NSInteger ret = [_pop3Server connect];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
	ret = [_pop3Server authServer];
	assertThatInteger(ret, equalToInteger(MAILPOP3_NO_ERROR));
	NSArray* array = [_pop3Server capa];
	assertThat(array, notNilValue());
	assertThatInteger(array.count, greaterThan(numberInt(0)));
	for (NSString* capa in array)
		NSLog(@"capa:\n%@", capa);
}

#endif

#endif

@end
