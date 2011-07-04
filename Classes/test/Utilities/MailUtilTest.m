//
//  MailUtilTest.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MailUtilTest.h"
#import "Categories.h"


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

- (void)testWrappedText {
	NSString* lineText = @"GyRCPHc4Qkw1PHc4Qkw1OF45ZSROOyQkakBaJGwzJDo9TXg/ZTV7JE4/ZTlUS3YxQE1oS3ZJd01oS3Y/KSQmPzIkaxsoQg==?=";
	NSString* wrapped = [MailUtil wrappedText:lineText];
	assertThat(wrapped, isNot(lineText));
	NSLog(@"wrapped:\n%@", wrapped);
}

- (void)testWrappedText_ShortText {
	NSString* lineText = @"GyRCJCIkJCQmJCgkKhsoQg==";
	NSString* wrapped = [MailUtil wrappedText:lineText];
	assertThat(wrapped, equalTo(lineText));
	NSLog(@"wrapped:\n%@", wrapped);
}

- (void)testEncDecWrap {
	NSString* path = [[NSBundle bundleForClass:[self class]] pathForResource:@"salzburg" ofType:@"png"];
	NSData* data = [NSData dataWithContentsOfFile:path];
	NSString* encText = [NSString base64Encode:data];
	assertThat(encText, notNilValue());
	assertThatInteger(encText.length, greaterThan([NSNumber numberWithInteger:0]));
	NSString* wrapText = [MailUtil wrappedText:encText];
	assertThat(wrapText, notNilValue());
	assertThatInteger(wrapText.length, greaterThan([NSNumber numberWithInteger:0]));
	assertThat(wrapText, isNot(encText));
		NSLog(@"wrapText:\n%@", wrapText);
}

- (void)testLineText {
	NSString* encoded = @"GyRCPHc4Qkw1PHc4Qkw1OF45ZSROOyQkakBaJGwzJDo9TXg/ZTV7JE4/ZTlUS3YxQE1oS3ZJd01oS3Y/KSQmPzIkaxsoQg==?=";
	NSString* wrapped = [MailUtil wrappedText:encoded];
	NSString* decWrap = [NSString base64Decode:wrapped encoding:NSISO2022JPStringEncoding];
	NSString* lineText = [MailUtil lineText:wrapped];
	assertThat(lineText, isNot(equalTo(wrapped)));
	assertThat(lineText, equalTo(encoded));
	NSString* decLine = [NSString base64Decode:lineText encoding:NSISO2022JPStringEncoding];
	assertThat(decLine, equalTo(decWrap));
	NSLog(@"decLine:\n%@", decLine);
}

- (void)testCreateShortTexts {
	NSString* text = @"ABCDEFGHIJKLMNOPあいうえおかきく0123456789012345";
	NSArray* texts = [MailUtil createShortTexts:text];
	assertThat(texts, notNilValue());
	assertThatInteger(texts.count, greaterThan([NSNumber numberWithInteger:1]));
	assertThat(texts, hasItem(@"ABCDEFGHIJKLMNOP"));
	assertThat(texts, hasItem(@"あいうえおかきく"));
	assertThat(texts, hasItem(@"0123456789012345"));
	assertThat(texts, isNot(hasItem(@"ABCDEFGHIJKLMNOPあいうえ")));
	for (NSString* string in texts) {
		NSLog(@"string = %@", string);
	}
}

- (void)testCreateShortTexts_Short {
	NSString* text = @"ABCDEFG";
	NSArray* texts = [MailUtil createShortTexts:text];
	assertThat(texts, notNilValue());
	assertThatInteger(texts.count, equalTo([NSNumber numberWithInteger:1]));
	assertThat(texts, hasItem(text));
	assertThat(texts, isNot(hasItem(@"ABCDEFGHIJKLMNOP")));
}

- (void)testCreateHeaderText {
	NSString* text = @"ABCDEFGHIJKLMNOPあいうえおかきく0123456789012345";
	NSString* header = [MailUtil createHeaderText:text];
	assertThat(header, notNilValue());
	assertThatInteger([header length], greaterThan([NSNumber numberWithInteger:1]));
	assertThat(header, containsString(@"\n "));
	assertThat(header, equalTo(@"ABCDEFGHIJKLMNOP\n あいうえおかきく\n 0123456789012345"));
	NSLog(@"header:\n%@", header);
}

@end
