//
//  MailOperatorTest.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/07/19.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MailOperatorTest.h"
#import "SMTPServer.h"


@implementation MailOperatorTest

- (void)setUp {
	[super setUp];
	_mailOperator = [[MailOperator alloc] init];
}

- (void)tearDown {
	[_mailOperator release];
	[super tearDown];
}

- (void)testSendMessage {
	_mailOperator.sendServer = [[[SMTPServer alloc] initWithAddress:@"localhost" portNo:25u ssl:NO] autorelease];
	BOOL success = [_mailOperator sendMessage:nil];
	assertThatBool(success, equalToBool(YES));
}

- (void)testSendMessage_Failure {
	_mailOperator.sendServer = [[[SMTPServer alloc] initWithAddress:@"xxxx.xxxx.xxx" portNo:25u ssl:NO] autorelease];
	BOOL success = [_mailOperator sendMessage:nil];
	assertThatBool(success, equalToBool(NO));
}

@end
