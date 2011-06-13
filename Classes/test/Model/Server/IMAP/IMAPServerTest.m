//
//  IMAPServerTest.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IMAPServerTest.h"
#import "Categories.h"
#import "PrimitiveToNumber.h"


@implementation IMAPServerTest

- (void)setUp {
	[super setUp];
	_imapSever = [[IMAPServer alloc] init];
}

- (void)tearDown {
	[_imapSever release];
	[super tearDown];
}

- (void)testInit {
	assertThat(_imapSever, notNilValue());
	NSString* addrStr = [NSString stringWithFormat:@"%p", _imapSever.imap];
	NSLog(@"addrstr: %@", addrStr);
	unsigned int addr = [NSString convertHexString:addrStr];
	assertThatInt(addr, greaterThan(numberInt(0)));
	NSLog(@"addr: %d", addr);
}

- (void)testInitWithResource {
	[_imapSever release];
	_imapSever = [[IMAPServer alloc] initWithResource:mailimap_new(0, NULL)];
	assertThat(_imapSever, notNilValue());
	NSString* addrStr = [NSString stringWithFormat:@"%p", _imapSever.imap];
	NSLog(@"addrstr: %@", addrStr);
	unsigned int addr = [NSString convertHexString:addrStr];
	assertThatInt(addr, greaterThan(numberInt(0)));
	NSLog(@"addr: %d", addr);
}

#ifdef IMAP_CONNECT

- (void)testConnect {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 143u;
	NSInteger ret = [_imapSever connect];
	assertThatInteger(ret, equalToInteger(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
}

- (void)testConnect_SSL {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThatInteger(ret, equalToInteger(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
}

- (void)testConnect_NoExist {
	_imapSever.address = @"xxxxx.yyyyy";
	_imapSever.portNo = 111111u;
	NSInteger ret = [_imapSever connect];
	assertThatInteger(ret, isNot(equalToInteger(MAILIMAP_NO_ERROR_NON_AUTHENTICATED)));
	assertThatInteger(ret, isNot(equalToInteger(MAILIMAP_NO_ERROR)));
	assertThatInteger(ret, isNot(equalToInteger(MAILIMAP_NO_ERROR_AUTHENTICATED)));
}

- (void)testDisconnect {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 143u;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever disconnect];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testDisconnect_Error {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 143u;
	@try {
		[_imapSever disconnect];
		STFail(nil);
	} @catch (NSError* e) {
		assertThat(e, notNilValue());
		assertThat([e domain], equalTo(@"IMAP ERROR"));
		assertThatInt([e code], equalTo(numberInt(999u)));
	}
}

- (void)testStartTLS {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 143u;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever startTLS];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testNoop {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever noop];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testCapability {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	NSArray* array = [_imapSever capability];
	assertThat(array, notNilValue());
	assertThatInteger(array.count, greaterThan(numberInt(0)));
	for (NSString* capa in array)
		NSLog(@"capa:\n%@", capa);
}

#ifdef USE_POP3_AUTH

- (void)testAuthServer {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 143u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = NO;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
}

- (void)testAllFolder {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 143u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = NO;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	NSArray* array = [_imapSever allFolders];
	assertThat(array, notNilValue());
	assertThatInteger(array.count, greaterThan(numberInt(0)));
	for (NSString* name in array)
		NSLog(@"name:\n%@", name);
}

- (void)testSubscribedFolders {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 143u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = NO;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	NSArray* array = [_imapSever subscribedFolders];
	assertThat(array, notNilValue());
	assertThatInteger(array.count, greaterThan(numberInt(0)));
	for (NSString* name in array)
		NSLog(@"name:\n%@", name);
}

- (void)testSelect {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testExamine {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever examine:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testCreaDele {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever create:@"TEMPORARY"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	ret = [_imapSever delete:@"TEMPORARY"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testScribeUnscribe {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever create:@"TEMPORARY"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	ret = [_imapSever subscribe:@"TEMPORARY"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	NSArray* array = [_imapSever subscribedFolders];
	assertThat(array, notNilValue());
	assertThatInteger(array.count, greaterThan(numberInt(0)));
	assertThat(array, hasItem(@"TEMPORARY"));
	for (NSString* name in array)
		NSLog(@"name:\n%@", name);
	ret = [_imapSever unsubscribe:@"TEMPORARY"];
	NSArray* modArray = [_imapSever subscribedFolders];
	assertThat(modArray, notNilValue());
	assertThatInteger(modArray.count, greaterThan(numberInt(0)));
	assertThat(modArray, isNot(equalTo(array)));
	assertThat(modArray, isNot(hasItem(@"TEMPORARY")));
	for (NSString* name in modArray)
		NSLog(@"name:\n%@", name);
	ret = [_imapSever delete:@"TEMPORARY"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testRename {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever create:@"TEMPORARY"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	ret = [_imapSever rename:@"TEMPORARY" newName:@"NEWNAME"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	NSArray* array = [_imapSever allFolders];
	assertThat(array, notNilValue());
	assertThatInteger(array.count, greaterThan(numberInt(0)));
	assertThat(array, hasItem(@"NEWNAME"));
	for (NSString* name in array)
		NSLog(@"renamed - name:\n%@", name);
	ret = [_imapSever delete:@"NEWNAME"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	array = [_imapSever allFolders];
	assertThat(array, notNilValue());
	assertThatInteger(array.count, greaterThan(numberInt(0)));
	assertThat(array, isNot(hasItem(@"NEWNAME")));
	for (NSString* name in array)
		NSLog(@"deleted - name:\n%@", name);
}

- (void)testStatus {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	NSArray* infos = [NSArray arrayWithObjects:@"MESSAGES", @"RECENT", @"UIDNEXT", @"UIDVALIDITY", @"UNSEEN", nil];
	NSDictionary* dictionary = [_imapSever status:@"INBOX" infos:infos];
	assertThat(dictionary, notNilValue());
	assertThatUnsignedInteger(dictionary.count, greaterThan(numberInt(0)));
	assertThat(dictionary, hasKey(@"MESSAGES"));
	assertThat(dictionary, hasKey(@"RECENT"));
	assertThat(dictionary, hasKey(@"UIDNEXT"));
	assertThat(dictionary, hasKey(@"UIDVALIDITY"));
	assertThat(dictionary, hasKey(@"UNSEEN"));
	for (NSString* key in dictionary.allKeys)
		NSLog(@"key: %@, value: %@", key, [dictionary objectForKey:key]);
}

- (void)testAllStatus {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	NSDictionary* dictionary = [_imapSever allStatus:@"INBOX"];
	assertThat(dictionary, notNilValue());
	assertThatUnsignedInteger(dictionary.count, greaterThan(numberInt(0)));
	assertThat(dictionary, hasKey(@"MESSAGES"));
	assertThat(dictionary, hasKey(@"RECENT"));
	assertThat(dictionary, hasKey(@"UIDNEXT"));
	assertThat(dictionary, hasKey(@"UIDVALIDITY"));
	assertThat(dictionary, hasKey(@"UNSEEN"));
	for (NSString* key in dictionary.allKeys)
		NSLog(@"key: %@, value: %@", key, [dictionary objectForKey:key]);
}

- (void)testCheck {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	ret = [_imapSever check];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testClose {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testIdle {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever startIdle];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	ret = [_imapSever endIdle];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testGetQuotaRoot {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	NSDictionary* dictinary = [_imapSever getQuotaRoot];
	assertThat(dictinary, notNilValue());
	assertThatUnsignedInteger(dictinary.count, greaterThan(numberInt(0)));
	NSLog(@"dictionary:\n%@", dictinary);
}

- (void)testGetQuotaRootWithName {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	NSDictionary* dictinary = [_imapSever getQuotaRoot:@"INBOX"];
	assertThat(dictinary, notNilValue());
	assertThatUnsignedInteger(dictinary.count, greaterThan(numberInt(0)));
	NSLog(@"dictionary:\n%@", dictinary);
}

- (void)testAppend {
	NSString* format = @"Date: %@\r\nFrom: me@mail.mail\r\nTo: anyone@mail.mail\r\nCc: name@mail.mail\r\nSubject: OCUnit Test\r\n\r\nSend to Test Mail.";
	NSString* message = [NSString stringWithFormat:format, [NSDate dateToRFC2822:[NSDate date]]];
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever append:[message dataUsingEncoding:NSUTF8StringEncoding] mailbox:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testFecthMessage {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSData* data = [_imapSever fetchMessage:1];
	assertThat(data, notNilValue());
	assertThatBool([NSData isEmpty:data], equalToBool(NO));
	NSLog(@"message:\n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testFecthHeader {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSData* data = [_imapSever fetchHeader:1];
	assertThat(data, notNilValue());
	assertThatBool([NSData isEmpty:data], equalToBool(NO));
	NSLog(@"header:\n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testFecthSize {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSNumber* size = [_imapSever fetchSize:1];
	assertThatUnsignedInteger([size unsignedIntegerValue], greaterThan(numberInt(1)));
	NSLog(@"size = %u", [size unsignedIntegerValue]);
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testFecthText {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSData* data = [_imapSever fetchText:1];
	assertThat(data, notNilValue());
	assertThatBool([NSData isEmpty:data], equalToBool(NO));
	NSLog(@"text:\n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testFecthFlags {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever fetchFlags:3];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSString* flag in array)
		NSLog(@"flag = %@", flag);
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testFecthUID {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSNumber* uid = [_imapSever fetchUID:2u];
	assertThatUnsignedInteger([uid unsignedIntegerValue], greaterThan(numberInt(0)));
	NSLog(@"uid = %u", [uid unsignedIntegerValue]);
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testFecthMessageWithUID {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSData* data = [_imapSever fetchMessageWithUID:5u];
	assertThat(data, notNilValue());
	assertThatBool([NSData isEmpty:data], equalToBool(NO));
	NSLog(@"message:\n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testFecthHeaderWithUID {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSData* data = [_imapSever fetchHeaderWithUID:5u];
	assertThat(data, notNilValue());
	assertThatBool([NSData isEmpty:data], equalToBool(NO));
	NSLog(@"header:\n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testFecthSizeWithUID {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSNumber* size = [_imapSever fetchSizeWithUID:5u];
	assertThatUnsignedInteger([size unsignedIntegerValue], greaterThan(numberInt(1)));
	NSLog(@"size = %u", [size unsignedIntegerValue]);
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testFecthTextWithUID {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSData* data = [_imapSever fetchTextWithUID:5u];
	assertThat(data, notNilValue());
	assertThatBool([NSData isEmpty:data], equalToBool(NO));
	NSLog(@"text:\n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testFecthFlagsWithUID {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever fetchFlagsWithUID:5u];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSString* flag in array)
		NSLog(@"flag = %@", flag);
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testFecthUIDWithUID {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSNumber* uid = [_imapSever fetchUIDWithUID:5u];
	assertThatUnsignedInteger([uid unsignedIntegerValue], greaterThan(numberInt(0)));
	NSLog(@"uid = %u", [uid unsignedIntegerValue]);
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testStore {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	ret = [_imapSever store:1 flag:SEEN enable:YES silent:YES];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	NSArray* array = [_imapSever fetchFlags:1];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	assertThat(array, hasItem(@"\\Seen"));
	for (NSString* flag in array)
		NSLog(@"Enable flag = %@", flag);
	ret = [_imapSever store:1 flag:SEEN enable:NO silent:YES];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	array = [_imapSever fetchFlags:1];
	assertThat(array, nilValue());
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testStoreWithRange {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSRange range = NSMakeRange(1, 83);
	ret = [_imapSever storeWithRange:range flag:SEEN enable:YES silent:YES];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	NSArray* array = [_imapSever fetchFlags:1];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	assertThat(array, hasItem(@"\\Seen"));
	for (NSString* flag in array)
		NSLog(@"Enable flag = %@ on 1", flag);
	array = [_imapSever fetchFlags:83];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	assertThat(array, hasItem(@"\\Seen"));
	for (NSString* flag in array)
		NSLog(@"Enable flag = %@ on 83", flag);
	ret = [_imapSever storeWithRange:range flag:SEEN enable:NO silent:YES];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	array = [_imapSever fetchFlags:1];
	assertThat(array, nilValue());
	array = [_imapSever fetchFlags:3];
	assertThat(array, nilValue());
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testStoreWithUID {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	ret = [_imapSever storeWithUID:1 flag:SEEN enable:YES silent:NO];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	NSArray* array = [_imapSever fetchFlagsWithUID:1];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	assertThat(array, hasItem(@"\\Seen"));
	for (NSString* flag in array)
		NSLog(@"Enable flag = %@", flag);
	ret = [_imapSever storeWithUID:1 flag:SEEN enable:NO silent:NO];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	array = [_imapSever fetchFlagsWithUID:1];
	assertThat(array, nilValue());
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testStoreWithUIDRange {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSRange range = NSMakeRange(1, 331);
	ret = [_imapSever storeWithUIDRange:range flag:SEEN enable:YES silent:NO];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	NSArray* array = [_imapSever fetchFlagsWithUID:1];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	assertThat(array, hasItem(@"\\Seen"));
	for (NSString* flag in array)
		NSLog(@"Enable flag = %@ on UID=1", flag);
	array = [_imapSever fetchFlagsWithUID:332];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	assertThat(array, hasItem(@"\\Seen"));
	for (NSString* flag in array)
		NSLog(@"Enable flag = %@ on UID=332", flag);
	ret = [_imapSever storeWithUIDRange:range flag:SEEN enable:NO silent:NO];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	array = [_imapSever fetchFlagsWithUID:1];
	assertThat(array, nilValue());
	array = [_imapSever fetchFlagsWithUID:332];
	assertThat(array, nilValue());
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testCopy {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	ret = [_imapSever copy:1 mailbox:@"Drafts"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testCopyWithUID {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	ret = [_imapSever copyWithUID:2u mailbox:@"Drafts"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testCopyWithRange {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	ret = [_imapSever copyWithRange:NSMakeRange(1, 15) mailbox:@"Drafts"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testCopyWithUIDRange {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	ret = [_imapSever copyWithUIDRange:NSMakeRange(1,50) mailbox:@"Drafts"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testExpunge {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	ret = [_imapSever copyWithRange:NSMakeRange(1, 10) mailbox:@"ANYNAME"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	ret = [_imapSever select:@"ANYNAME"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	ret = [_imapSever storeWithRange:NSMakeRange(1, 10) flag:DELETED enable:YES silent:YES];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	ret = [_imapSever expunge];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testExpungeWithUIDRange {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	ret = [_imapSever copyWithRange:NSMakeRange(1, 10) mailbox:@"ANYNAME"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	ret = [_imapSever select:@"ANYNAME"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	ret = [_imapSever storeWithRange:NSMakeRange(1, 10) flag:DELETED enable:YES silent:YES];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	ret = [_imapSever expungeWithUIDRange:NSMakeRange(1, 10)];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testSearchAll {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever searchAll];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"number = %u", [number unsignedIntValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}


- (void)testSearchFrom {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever searchFrom:@"leaf"];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"number = %u", [number unsignedIntValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testSearchTo {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever searchTo:@"ogino"];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"number = %u", [number unsignedIntValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testSearchCc {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever searchCc:@"@"];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"number = %u", [number unsignedIntValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testSearchHeader {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever searchHeader:@"X-Original-To" field:@"asia"];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"number = %u", [number unsignedIntValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testSearchUID {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever searchUID:10];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"number = %u", [number unsignedIntValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testSearchText {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever searchText:@"http"];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"number = %u", [number unsignedIntValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testSearchSubject {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever searchSubject:@"goo"];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"number = %u", [number unsignedIntValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testUidSearchAll {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever uidSearchAll];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"number = %u", [number unsignedIntValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}


- (void)testUidSearchFrom {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever uidSearchFrom:@"anyone from"];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"uid = %u", [number unsignedIntValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testUidSearchTo {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever uidSearchTo:@"someone who"];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"uid = %u", [number unsignedIntValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testUidSearchCc {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever uidSearchCc:@"@"];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"uid = %u", [number unsignedIntValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testUidSearchSubject {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever uidSearchSubject:@"goo"];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"number = %u", [number unsignedIntValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testUidSearchHeader {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever uidSearchHeader:@"X-Original-To" field:@"anydomain"];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"uid = %u", [number unsignedIntValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testUidSearchUID {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever uidSearchUID:10];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"uid = %u", [number unsignedIntValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testUidSearchText {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever uidSearchText:@"http"];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"uid = %u", [number unsignedIntValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testFetchMessageWithRange {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever fetchMessagesWithRange:NSMakeRange(1, 12)];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSData* data in array) {
		NSLog(@"message:\n%s", [data bytes]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testFetchHeadersWithRange {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever fetchHeadersWithRange:NSMakeRange(1, 12)];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSData* data in array) {
		NSLog(@"header:\n%s", [data bytes]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testFetchSizesWithRange {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever fetchSizesWithRange:NSMakeRange(1, 12)];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"size = %u", [number unsignedIntegerValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testFetchTextsWithRange {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever fetchTextsWithRange:NSMakeRange(1, 12)];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSData* data in array) {
		NSLog(@"text:\n%s", [data bytes]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testFetchFlagsWithRange {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever fetchFlagsWithRange:NSMakeRange(1, 12)];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	NSUInteger number = 1;
	for (NSArray* data in array) {
		NSLog(@"number = %d", number++);
		for (NSString* flag in data)
			NSLog(@"Enable flag = %@", flag);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testFetchUIDsWithRange {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever fetchUIDsWithRange:NSMakeRange(1, 12)];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"uid = %u", [number unsignedIntegerValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testFetchMessageWithUIDRange {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever fetchMessagesWithUIDRange:NSMakeRange(1, 29)];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSData* data in array) {
		NSLog(@"message:\n%s", [data bytes]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testFetchHeadersWithUIDRange {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever fetchHeadersWithUIDRange:NSMakeRange(1, 29)];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSData* data in array) {
		NSLog(@"message:\n%s", [data bytes]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testFetchSizesWithUIDRange {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever fetchSizesWithUIDRange:NSMakeRange(1, 29)];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"size = %u", [number unsignedIntegerValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testFetchTextsWithUIDRange {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever fetchTextsWithUIDRange:NSMakeRange(1, 29)];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSData* data in array) {
		NSLog(@"text:\n%s", [data bytes]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testFetchFlagsWithUIDRange {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever fetchFlagsWithUIDRange:NSMakeRange(1, 29)];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	NSUInteger number = 1;
	for (NSArray* data in array) {
		NSLog(@"number = %d", number++);
		for (NSString* flag in data)
			NSLog(@"Enable flag = %@", flag);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testFetchUIDsWithUIDRange {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever fetchUIDsWithUIDRange:NSMakeRange(1, 29)];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"uid = %u", [number unsignedIntegerValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testSearchSeen {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever searchSeen:YES];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"number = %u", [number unsignedIntegerValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testSearchAnswered {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever searchAnswered:YES];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"number = %u", [number unsignedIntegerValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testSearchDeleted {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever searchDeleted:NO];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"number = %u", [number unsignedIntegerValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testSearchFlagged {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever searchFlagged:YES];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"number = %u", [number unsignedIntegerValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testSearchKeyword {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever searchKeyword:YES keyword:@"$Forwarded"];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"number = %u", [number unsignedIntegerValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testSearchRecent {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever searchRecent];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, equalToInteger(0));
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testSearchDraft {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever searchDraft];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, equalToInteger(0));
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testUidSearchSeen {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever uidSearchSeen:YES];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"number = %u", [number unsignedIntegerValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testUidSearchAnswered {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever uidSearchAnswered:YES];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"uid = %u", [number unsignedIntegerValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testUidSearchDeleted {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever uidSearchDeleted:NO];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"uid = %u", [number unsignedIntegerValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testUidSearchFlagged {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever uidSearchFlagged:YES];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"uid = %u", [number unsignedIntegerValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testUidSearchKeyword {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever uidSearchKeyword:YES keyword:@"$Forwarded"];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, greaterThan(numberInt(0)));
	for (NSNumber* number in array) {
		NSLog(@"uid = %u", [number unsignedIntegerValue]);
	}
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testUidSearchRecent {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever uidSearchRecent];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, equalToInteger(0));
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

- (void)testUidSearchDraft {
	_imapSever.address = @"imap.imap.imap";
	_imapSever.portNo = 993u;
	_imapSever.userName = @"anyuser";
	_imapSever.password = @"password";
	_imapSever.ssl = YES;
	NSInteger ret = [_imapSever connect];
	assertThat(numberInt(ret), equalToInt(MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
	ret = [_imapSever authServer];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.authorized, equalToBool(YES));
	ret = [_imapSever select:@"INBOX"];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
	assertThatBool(_imapSever.selected, equalToBool(YES));
	NSArray* array = [_imapSever uidSearchDraft];
	assertThat(array, notNilValue());
	assertThatUnsignedInteger(array.count, equalToInteger(0));
	ret = [_imapSever close];
	assertThatInteger(ret, equalToInt(MAILIMAP_NO_ERROR));
}

#endif

#endif

@end
