//
//  InternetAddressTest.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InternetAddressTest.h"


@implementation InternetAddressTest

- (void)setUp {
	[super setUp];
	_address = nil;
}

- (void)tearDown {
	[super tearDown];
	if (_address) [_address release];
}

- (void)testCreateEncodedPersonal {
	_address = [[InternetAddress alloc] initWithAddress:@"aaaaa@bbb.ccc" personal:@"名無しの権兵衛"];
	assertThat(_address.address, notNilValue());
	assertThat(_address.personal, notNilValue());
	assertThat(_address.encodedPersonal, nilValue());
	[_address createEncodedPersonal:NSUTF8StringEncoding];
	assertThat(_address.encodedPersonal, notNilValue());
	NSString* description = [_address description];
	assertThat(description, notNilValue());
	assertThatUnsignedInteger([description length], greaterThan([NSNumber numberWithInt:1]));
	assertThat(description, isNot(equalTo(@"aaaaa@bbb.ccc")));
	assertThat(description, isNot(equalTo(@"名無しの権兵衛")));
	assertThat(description, containsString(@"<aaaaa@bbb.ccc>"));
	NSLog(@"description: %@", description);
}

- (void)testCreateEncodedPersonalWithPersonal {
	_address = [[InternetAddress alloc] init];
	assertThat(_address.address, nilValue());
	assertThat(_address.personal, nilValue());
	assertThat(_address.encodedPersonal, nilValue());
	_address.address = @"test@test.test";
	assertThat(_address.address, notNilValue());
	[_address createEncodedPersonal:@"寿限無寿限無" encoding:NSISO2022JPStringEncoding];
	assertThat(_address.personal, notNilValue());
	assertThat(_address.encodedPersonal, notNilValue());
	NSString* description = [_address description];
	assertThat(description, notNilValue());
	assertThatUnsignedInteger([description length], greaterThan([NSNumber numberWithInt:1]));
	assertThat(description, isNot(equalTo(@"test@test.test")));
	assertThat(description, isNot(equalTo(@"寿限無寿限無")));
	assertThat(description, containsString(@"<test@test.test>"));
	NSLog(@"description: %@", description);

}

@end
