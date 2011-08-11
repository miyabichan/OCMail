//
//  MimeMessage.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MimeMessage.h"
#import "Categories.h"
#import "MailUtil.h"

@interface MimeMessage (PrivateDelegateHandling)
- (NSString*)createHeaderString:(NSString*)value format:(NSString*)format;
- (NSString*)createMessageHeader:(enum AddressType)addressType value:(NSString*)value;
- (NSData*)createHeaderData:(NSString*)string encoding:(NSStringEncoding)encoding;
- (NSString*)createRecipientsString:(NSArray*)recipients;
- (NSString*)createSubjectHeader;
- (NSString*)createContentTypeHeader;
@end

enum AddressType {
	DATE,
	FROM,
	TO,
	CC,
	BCC,
	REPLYTO,
	CONTENTTYPE,
	ENCODING,
	SUBJECT,
};

@implementation MimeMessage

@synthesize messageId = messageId_;
@synthesize subject = subject_;
@synthesize contentType = contentType_;
@synthesize transferEncoding = transferEncoding_;
@synthesize boundary = boudary_;
@synthesize date = date_;
@synthesize from = from_;
@synthesize sender = sender_;
@synthesize replyTo = replyTo_;
@synthesize toRecipients = toRecipients_;
@synthesize ccRecipients = ccRecipients_;
@synthesize bccRecipients = bccRecipients_;
@synthesize headers = headers_;
@synthesize messageBody = messageBody_;
@synthesize stringEncoding = stringEncoding_;

#pragma mark - Inherit Methods

- (id)init {
	if ((self = [super init])) {
		self.stringEncoding = NSASCIIStringEncoding;
	}
	return self;
}

- (void)dealloc {
	self.messageId = nil;
	self.subject = nil;
	self.contentType = nil;
	self.transferEncoding = nil;
	self.boundary = nil;
	self.date = nil;
	self.from = nil;
	self.sender = nil;
	self.replyTo = nil;
	self.toRecipients = nil;
	self.ccRecipients = nil;
	self.bccRecipients = nil;
	self.headers = nil;
	self.messageBody = nil;
	[super dealloc];
}

#pragma mark - Private Methods

- (NSString*)createHeaderString:(NSString*)value format:(NSString*)format {
	return [NSString stringWithFormat:format, value];
}

- (NSString*)createMessageHeader:(enum AddressType)addressType value:(NSString*)value {
	NSString* format = nil;
	switch (addressType) {
		case DATE:
			format = @"Date: %@\n";
			break;
		case FROM:
			format = @"From: %@\n";
			break;
		case TO:
			format = @"To: %@\n";
			break;
		case CC:
			format = @"Cc: %@\n";
			break;
		case BCC:
			format = @"Bcc: %@\n";
			break;
		case REPLYTO:
			format = @"Reply-To: %@\n";
			break;
		case CONTENTTYPE:
			format = @"Content-Type: %@\n";
			break;
		case ENCODING:
			format = @"Content-Transfer-Encoding: %@\n";
			break;
		case SUBJECT:
			format = @"Subject: %@\n";
			break;
		default:
			break;
	}
	if ([NSString isEmpty:format]) return nil;
	return [self createHeaderString:value format:format];
}

- (NSData*)createHeaderData:(NSString*)string encoding:(NSStringEncoding)encoding {
	if ([NSString isEmpty:string]) return nil;
	return [string dataUsingEncoding:encoding];
}

#define RECIPIENT_TRIM 3

- (NSString*)createRecipientsString:(NSArray*)recipients {
	NSMutableString* recipientString = [NSMutableString string];
	for (InternetAddress* address in recipients)
		[recipientString appendFormat:@"%@,\n ", [address description]];
	return [recipientString substringWithRange:NSMakeRange(0, [recipientString length] - RECIPIENT_TRIM)];
}

#define SUBJECT_TRIM 2

- (NSString*)createSubjectHeader {
	NSArray* texts = [MailUtil createShortTexts:self.subject];
	NSMutableString* encoded = [NSMutableString string];
	for (NSString* text in texts) {
		[encoded appendFormat:@"%@\n ", [MailUtil encodeHeader:text encoding:self.stringEncoding]];
	}
	return [encoded substringWithRange:NSMakeRange(0, encoded.length - SUBJECT_TRIM)];
}

- (NSString*)createContentTypeHeader {
	NSMutableString* value = [NSMutableString stringWithString:self.contentType];
	NSString* charset = [MailUtil createEncodeName:self.stringEncoding];
	if (self.stringEncoding > 0 && ![NSString isEmpty:charset])
		[value appendFormat:@"; charset=\"%@\"", charset];
	if (![NSString isEmpty:self.boundary])
		[value appendFormat:@";\n\tboundary=\"%@\"", self.boundary];
	return value;
}

#pragma mark - Public Methods

- (NSData*)createMessageData {
	NSMutableData* data = [NSMutableData data];
	if (!self.date) self.date = [NSDate date];
	[data appendData:[self createHeaderData:[self createMessageHeader:DATE value:[NSDate dateToRFC2822:self.date]] encoding:NSASCIIStringEncoding]];
	if (self.from)
		[data appendData:[self createHeaderData:[self createMessageHeader:FROM value:[self.from description]] encoding:NSASCIIStringEncoding]];
	if (![NSArray isEmpty:self.toRecipients])
		[data appendData:[self createHeaderData:[self createMessageHeader:TO value:[self createRecipientsString:self.toRecipients]] encoding:NSASCIIStringEncoding]];
	if (![NSArray isEmpty:self.ccRecipients])
		[data appendData:[self createHeaderData:[self createMessageHeader:CC value:[self createRecipientsString:self.ccRecipients]] encoding:NSASCIIStringEncoding]];
	if (![NSArray isEmpty:self.bccRecipients])
		[data appendData:[self createHeaderData:[self createMessageHeader:BCC value:[self createRecipientsString:self.bccRecipients]] encoding:NSASCIIStringEncoding]];
	if (self.replyTo)
		[data appendData:[self createHeaderData:[self createMessageHeader:REPLYTO value:[self.replyTo description]] encoding:NSASCIIStringEncoding]];
	if (self.subject)
		[data appendData:[self createHeaderData:[self createMessageHeader:SUBJECT value:[self createSubjectHeader]] encoding:NSASCIIStringEncoding]];
	if (![NSString isEmpty:self.contentType])
		[data appendData:[self createHeaderData:[self createMessageHeader:CONTENTTYPE value:[self createContentTypeHeader]] encoding:NSASCIIStringEncoding]];
	if (![NSString isEmpty:self.transferEncoding])
		[data appendData:[self createHeaderData:[self createMessageHeader:ENCODING value:self.transferEncoding] encoding:NSASCIIStringEncoding]];
	[data appendData:[@"MIME-Version: 1.0\n" dataUsingEncoding:NSUTF8StringEncoding]];
	return data;
}


@end
