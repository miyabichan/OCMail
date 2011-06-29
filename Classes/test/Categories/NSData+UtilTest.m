//
//  NSData+UtilTest.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSData+UtilTest.h"


@implementation NSDataTest

- (void)setUp {
	[super setUp];
}

- (void)tearDown {
	[super tearDown];
}

- (void)testBase64Encode {
	NSString* string = @"あいうえおかきくけこさしすせそたちつてとなにぬねの";
	NSData* data = [NSData base64Encode:string encoding:NSUTF8StringEncoding];
	assertThat(data, notNilValue());
	assertThatInteger([data length], greaterThan([NSNumber numberWithInteger:1]));
	NSString* base64 = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
	assertThat(base64, equalTo(@"44GC44GE44GG44GI44GK44GL44GN44GP44GR44GT44GV44GX44GZ44Gb44Gd44Gf44Gh44Gk44Gm44Go44Gq44Gr44Gs44Gt44Gu"));
	NSLog(@"base64Data: %s", [data bytes]);
}

- (void)testBase64Decode {
	NSString* base64 = @"44GC44GE44GG44GI44GK44GL44GN44GP44GR44GT44GV44GX44GZ44Gb44Gd44Gf44Gh44Gk44Gm44Go44Gq44Gr44Gs44Gt44Gu";
	NSData* data = [NSData base64Decode:base64];
	assertThat(data, notNilValue());
	assertThatInteger([data length], greaterThan([NSNumber numberWithInteger:1]));
	NSString* text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	assertThat(text, equalTo(@"あいうえおかきくけこさしすせそたちつてとなにぬねの"));
	NSLog(@"text: %@", text);
}

@end
