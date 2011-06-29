//
//  MailUtilTest.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MailUtilTest.h"


@implementation MailUtilTest

- (void)setUp {
	[super setUp];
}

- (void)tearDown {
	[super tearDown];
}

- (void)testEncodePersonal {
	NSString* personal = @"寿限無寿限無五劫の擦り切れ海砂利水魚の水行末雲来末風来末食う寝る";
	NSString* encodePersonal = [MailUtil encodePersonal:personal encoding:NSISO2022JPStringEncoding];
	assertThat(encodePersonal, notNilValue());
	assertThatInteger([encodePersonal length], greaterThan([NSNumber numberWithInteger:1]));
	assertThat(encodePersonal, equalTo(@"=?ISO-2022-JP?B?GyRCPHc4Qkw1PHc4Qkw1OF45ZSROOyQkakBaJGwzJDo9TXg/ZTV7JE4/ZTlUS3YxQE1oS3ZJd01oS3Y/KSQmPzIkaxsoQg==?="));
	NSLog(@"encodePersonal: %@", encodePersonal);
}

- (void)testDecodePersonal {
	NSString* encodedPersonal = @"=?ISO-2022-JP?B?GyRCPHc4Qkw1PHc4Qkw1OF45ZSROOyQkakBaJGwzJDo9TXg/ZTV7JE4/ZTlUS3YxQE1oS3ZJd01oS3Y/KSQmPzIkaxsoQg==?=";
	NSString* personal = [MailUtil decodePersonal:encodedPersonal];
	assertThat(personal, notNilValue());
	assertThatInteger([personal length], greaterThan([NSNumber numberWithInteger:1]));
	assertThat(personal, equalTo(@"寿限無寿限無五劫の擦り切れ海砂利水魚の水行末雲来末風来末食う寝る"));
	NSLog(@"encodePersonal: %@", personal);
}

- (void)testCreateAddress {
	NSString* mixed = @"<cisco_jp@emessages.cisco.com>";
	NSString* address = [MailUtil createAddress:mixed];
	assertThat(address, notNilValue());
	assertThat(address, equalTo(@"cisco_jp@emessages.cisco.com"));
	NSLog(@"address: %@", address);
}

- (void)testCreateAddressSingle {
	NSString* mixed = @"cisco_jp@emessages.cisco.com";
	NSString* address = [MailUtil createAddress:mixed];
	assertThat(address, notNilValue());
	assertThat(address, equalTo(@"cisco_jp@emessages.cisco.com"));
	NSLog(@"address: %@", address);
}

- (void)testCreateAddressMulti {
	NSString* mixed = @"=?ISO-2022-JP?B?GyRCJTclOSUzJTclOSVGJWAlOjlnRjEycTxSGyhKIA==?=	<cisco_jp@emessages.cisco.com>";
	NSString* address = [MailUtil createAddress:mixed];
	assertThat(address, notNilValue());
	assertThat(address, equalTo(@"cisco_jp@emessages.cisco.com"));
	NSLog(@"address: %@", address);
}

@end
