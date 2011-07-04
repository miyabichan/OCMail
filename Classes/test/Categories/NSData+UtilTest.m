//
//  NSData+UtilTest.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSData+UtilTest.h"


@implementation NSData_UtilTest

- (void)setUp {
	[super setUp];
}

- (void)tearDown {
	[super tearDown];
}

- (void)testIsEmpty {
	NSString* text = @"あいうえおかきくけこ";
	NSData* data = [text dataUsingEncoding:NSUTF8StringEncoding];
	assertThatBool([NSData isEmpty:data], equalToBool(NO));
	NSLog(@"data: %s", [data bytes]);
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

- (void)testBase64WithImage {
	NSString* path = [[NSBundle bundleForClass:[self class]] pathForResource:@"salzburg" ofType:@"png"];
	assertThat(path, notNilValue());
	NSLog(@"path: %@", path);
	assertThatInteger([path length], greaterThan([NSNumber numberWithInteger:0]));

	NSData* data = [NSData dataWithContentsOfFile:path];
	NSLog(@"[data length] = %d", [data length]);

	assertThat(data, notNilValue());
	assertThatInteger([data length], greaterThan([NSNumber numberWithInteger:0]));
	NSLog(@"data:\n%s\n", [data bytes]);
	NSData* base64 = [NSData base64Encode:data];
	assertThat(base64, notNilValue());
	assertThatInteger([base64 length], greaterThan([NSNumber numberWithInteger:0]));
	assertThat(base64, isNot(equalTo(data)));
	NSLog(@"base64:\n%s\n", [base64 bytes]);
}

@end
