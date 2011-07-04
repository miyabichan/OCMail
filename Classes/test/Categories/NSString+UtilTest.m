//
//  NSString+UtilTest.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+UtilTest.h"


@implementation NSString_UtilTest

- (void)setUp {
	[super setUp];
}

- (void)tearDown {
	[super tearDown];
}

- (void)testBase64Encode {
	NSString* string = @"あいうえおかきくけこさしすせそたちつてとなにぬねの";
	NSString* base64 = [NSString base64Encode:string encoding:NSUTF8StringEncoding];
	assertThat(base64, notNilValue());
	assertThatInteger([base64 length], greaterThan([NSNumber numberWithInteger:1]));
	assertThat(base64, equalTo(@"44GC44GE44GG44GI44GK44GL44GN44GP44GR44GT44GV44GX44GZ44Gb44Gd44Gf44Gh44Gk44Gm44Go44Gq44Gr44Gs44Gt44Gu"));
	NSLog(@"base64: %@", base64);
}

- (void)testBase64Decode {
	NSString* base64 = @"44GC44GE44GG44GI44GK44GL44GN44GP44GR44GT44GV44GX44GZ44Gb44Gd44Gf44Gh44Gk44Gm44Go44Gq44Gr44Gs44Gt44Gu";
	NSString* text = [NSString base64Decode:base64 encoding:NSUTF8StringEncoding];
	assertThat(text, notNilValue());
	assertThatInteger([text length], greaterThan([NSNumber numberWithInteger:1]));
	assertThat(text, equalTo(@"あいうえおかきくけこさしすせそたちつてとなにぬねの"));
	NSLog(@"text: %@", text);
}

- (void)testLength {
	NSString* text = @"あいうえおAIUEO";
	NSUInteger length = [NSString length:text];
	assertThatInteger(length, greaterThan([NSNumber numberWithInteger:[text length]]));
	assertThatInteger(length, equalToInteger(15));
}

- (void)testLength_With8bitKana {
	NSString* text = @"ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿ";
	NSUInteger length = [NSString length:text];
	assertThatInteger(length, greaterThan([NSNumber numberWithInteger:[text length]]));
	assertThatInteger(length, equalToInteger(30));
}

- (void)testLength_WithAccent {
	NSString* text = @"ƒ∂ßçé®†øπœ∑óê†ç";
	NSUInteger length = [NSString length:text];
	assertThatInteger(length, greaterThan([NSNumber numberWithInteger:[text length]]));
	assertThatInteger(length, equalToInteger(30));
}

- (void)testIsAsciiOnly {
	NSString* text = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ $?";
	BOOL asciiOnly = [NSString isAsciiOnly:text];
	assertThatBool(asciiOnly, equalToBool(YES));
}

- (void)testIsAsciiOnly_MultBytes {
	NSString* text = @"あいうえおかきくけこ";
	BOOL asciiOnly = [NSString isAsciiOnly:text];
	assertThatBool(asciiOnly, equalToBool(NO));
}

- (void)testIsAsciiOnly_8bitKanas {
	NSString* text = @"ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿ";
	BOOL asciiOnly = [NSString isAsciiOnly:text];
	assertThatBool(asciiOnly, equalToBool(NO));
}

- (void)testIsAsciiOnly_Mixed {
	NSString* text = @"abçdêfghîjklmnopqrßtüvwxyz";
	BOOL asciiOnly = [NSString isAsciiOnly:text];
	assertThatBool(asciiOnly, equalToBool(NO));
}

@end
