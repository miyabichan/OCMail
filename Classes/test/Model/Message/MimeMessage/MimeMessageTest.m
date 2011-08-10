//
//  MimeMessageTest.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/08/03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MimeMessageTest.h"
#import "Categories.h"


@implementation MimeMessageTest

- (void)setUp {
	[super setUp];
	_mimeMessage = [[MimeMessage alloc] init];
}

- (void)tearDown {
	[_mimeMessage release];
	[super tearDown];
}

- (void)testCreateMessageData_Nil {
	NSData* data = [_mimeMessage createMessageData];
	assertThat(data, notNilValue());
	NSString* message = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	assertThat(message, notNilValue());
	NSLog(@"message: \n%@", message);
}

- (void)testCreateMessageData_From {
	_mimeMessage.date = [NSDate date];
	_mimeMessage.from = [[[InternetAddress alloc] initWithAddress:@"test@test.test" personal:@"HOGE FOO"] autorelease];
	NSData* data = [_mimeMessage createMessageData];
	assertThat(data, notNilValue());
	NSString* message = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	assertThat(message, containsString([NSDate dateToRFC2822:[NSDate date]]));
	assertThat(message, containsString(@"test@test.test"));
	assertThat(message, containsString(@"HOGE FOO"));
	NSLog(@"message: \n%@", message);
}

- (void)testCreateMessageData_To {
	_mimeMessage.date = [NSDate date];
	InternetAddress* address = [[[InternetAddress alloc] initWithAddress:@"test@test.test" personal:@"HOGE FOO"] autorelease];
	InternetAddress* internetAddress = [[[InternetAddress alloc] initWithAddress:@"var@var.var" personal:@"Micheal Gren"] autorelease];
	_mimeMessage.toRecipients = [NSArray arrayWithObjects:address, internetAddress, nil];
	NSData* data = [_mimeMessage createMessageData];
	assertThat(data, notNilValue());
	NSString* message = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	assertThat(message, containsString([NSDate dateToRFC2822:[NSDate date]]));
	assertThat(message, containsString(@"To:"));
	assertThat(message, containsString(@"test@test.test"));
	assertThat(message, containsString(@"HOGE FOO"));
	assertThat(message, containsString(@"var@var.var"));
	assertThat(message, containsString(@"Micheal Gren"));
	NSLog(@"message: \n%@", message);
}

- (void)testCreateMessageData_Cc {
	_mimeMessage.date = [NSDate date];
	InternetAddress* address = [[[InternetAddress alloc] initWithAddress:@"test@test.test" personal:@"HOGE FOO"] autorelease];
	InternetAddress* internetAddress = [[[InternetAddress alloc] initWithAddress:@"var@var.var" personal:@"Micheal Gren"] autorelease];
	_mimeMessage.ccRecipients = [NSArray arrayWithObjects:address, internetAddress, nil];
	NSData* data = [_mimeMessage createMessageData];
	assertThat(data, notNilValue());
	NSString* message = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	assertThat(message, containsString([NSDate dateToRFC2822:[NSDate date]]));
	assertThat(message, containsString(@"Cc:"));
	assertThat(message, containsString(@"test@test.test"));
	assertThat(message, containsString(@"HOGE FOO"));
	assertThat(message, containsString(@"var@var.var"));
	assertThat(message, containsString(@"Micheal Gren"));
	NSLog(@"message: \n%@", message);
}

- (void)testCreateMessageData_Bcc {
	_mimeMessage.date = [NSDate date];
	InternetAddress* address = [[[InternetAddress alloc] initWithAddress:@"test@test.test" personal:@"HOGE FOO"] autorelease];
	InternetAddress* internetAddress = [[[InternetAddress alloc] initWithAddress:@"var@var.var" personal:@"Micheal Gren"] autorelease];
	_mimeMessage.bccRecipients = [NSArray arrayWithObjects:address, internetAddress, nil];
	NSData* data = [_mimeMessage createMessageData];
	assertThat(data, notNilValue());
	NSString* message = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	assertThat(message, containsString([NSDate dateToRFC2822:[NSDate date]]));
	assertThat(message, containsString(@"Bcc:"));
	assertThat(message, containsString(@"test@test.test"));
	assertThat(message, containsString(@"HOGE FOO"));
	assertThat(message, containsString(@"var@var.var"));
	assertThat(message, containsString(@"Micheal Gren"));
	NSLog(@"message: \n%@", message);
}

- (void)testCreateMessageData_ReplyTo {
	_mimeMessage.date = [NSDate date];
	_mimeMessage.replyTo = [[[InternetAddress alloc] init] autorelease];
	_mimeMessage.replyTo.address = @"test@test.test";
	NSData* data = [_mimeMessage createMessageData];
	assertThat(data, notNilValue());
	NSString* message = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	assertThat(message, containsString([NSDate dateToRFC2822:[NSDate date]]));
	assertThat(message, containsString(@"test@test.test"));
	NSLog(@"message: \n%@", message);
}

- (void)testCreateMessageData_Subject {
	_mimeMessage.stringEncoding = NSISO2022JPStringEncoding;
	_mimeMessage.subject = @"あいうえおかきくけこさいすせそたちつてとなにぬねの";
	NSData* data = [_mimeMessage createMessageData];
	assertThat(data, notNilValue());
	NSString* message = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	assertThat(message, containsString([NSDate dateToRFC2822:[NSDate date]]));
	assertThat(message, containsString(@"Subject:"));
	NSLog(@"message: \n%@", message);
}

- (void)testCreateMessageData_ContentType_Encoding {
	_mimeMessage.stringEncoding = NSISO2022JPStringEncoding;
	_mimeMessage.contentType = @"text/plain";
	NSData* data = [_mimeMessage createMessageData];
	assertThat(data, notNilValue());
	NSString* message = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	assertThat(message, containsString([NSDate dateToRFC2822:[NSDate date]]));
	assertThat(message, containsString(@"Content-Type:"));
	assertThat(message, containsString(@"text/plain"));
	assertThat(message, containsString(@"ISO-2022-JP"));
	NSLog(@"message: \n%@", message);
}

- (void)testCreateMessageData_ContentType_noEncoding {
	_mimeMessage.contentType = @"text/plain";
	NSData* data = [_mimeMessage createMessageData];
	assertThat(data, notNilValue());
	NSString* message = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	assertThat(message, containsString([NSDate dateToRFC2822:[NSDate date]]));
	assertThat(message, containsString(@"Content-Type:"));
	assertThat(message, containsString(@"text/plain"));
	assertThat(message, isNot(containsString(@"ISO-2022-JP")));
	NSLog(@"message: \n%@", message);
}

- (void)testCreateMessageData_ContentType_boundary {
	_mimeMessage.contentType = @"multipart/mixed";
	_mimeMessage.boundary = @"----=_NextPart_000_1D69_01CC56DD.BBF3CCE0";
	NSData* data = [_mimeMessage createMessageData];
	assertThat(data, notNilValue());
	NSString* message = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	assertThat(message, containsString([NSDate dateToRFC2822:[NSDate date]]));
	assertThat(message, containsString(@"Content-Type:"));
	assertThat(message, containsString(@"multipart/mixed"));
	assertThat(message, containsString(@"----=_NextPart_000_1D69_01CC56DD.BBF3CCE0"));
	NSLog(@"message: \n%@", message);
}

@end
