//
//  MailServerTest.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MailServerTest.h"
#import "PrimitiveToNumber.h"


@implementation MailServerTest

- (void)setUp {
	[super setUp];
	_mailServer = [[MailServer alloc] init];
}

- (void)tearDown {
	[_mailServer release];
	[super tearDown];
}

- (void)testConnect {
	@try {
		[_mailServer connect];
		STFail(nil);
	} @catch (NSException* e) {
		assertThat(e, notNilValue());
		assertThat(e.name, notNilValue());
		assertThat(e.reason, notNilValue());
	}
}

- (void)testDisConnect {
	@try {
		[_mailServer disconnect];
		STFail(nil);
	} @catch (NSException* e) {
		assertThat(e, notNilValue());
		assertThat(e.name, notNilValue());
		assertThat(e.reason, notNilValue());
	}
}

- (void)testStartTLS {
	@try {
		[_mailServer startTLS];
		STFail(nil);
	} @catch (NSException* e) {
		assertThat(e, notNilValue());
		assertThat(e.name, notNilValue());
		assertThat(e.reason, notNilValue());
	}
}

- (void)testNoop {
	@try {
		[_mailServer noop];
		STFail(nil);
	} @catch (NSException* e) {
		assertThat(e, notNilValue());
		assertThat(e.name, notNilValue());
		assertThat(e.reason, notNilValue());
	}
}

- (void)testAuthServer {
	@try {
		[_mailServer authServer];
		STFail(nil);
	} @catch (NSException* e) {
		assertThat(e, notNilValue());
		assertThat(e.name, notNilValue());
		assertThat(e.reason, notNilValue());
	}
}

@end
