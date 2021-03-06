//
//  MimeMessage.h
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InternetAddress.h"
#import "MimeBody.h"


@interface MimeMessage : NSObject {
@private
	NSString* messageId_;
	NSString* subject_;
	NSString* contentType_;
	NSString* transferEncoding_;
	NSString* boudary_;
	NSDate* date_;
	InternetAddress* from_;
	InternetAddress* sender_;
	InternetAddress* replyTo_;
	NSArray* toRecipients_;  // NSArray<InternetAddress*>
	NSArray* ccRecipients_;  // NSArray<InternetAddress*>
	NSArray* bccRecipients_; // NSArray<InternetAddress*>
	NSArray* headers_;       // NSArray<NSDictionary*>
	MimeBody* messageBody_;
	NSStringEncoding stringEncoding_;
}

@property (nonatomic, copy) NSString* messageId;
@property (nonatomic, copy) NSString* subject;
@property (nonatomic, copy) NSString* contentType;
@property (nonatomic, copy) NSString* transferEncoding;
@property (nonatomic, copy) NSString* boundary;
@property (nonatomic, retain) NSDate* date;
@property (nonatomic, retain) InternetAddress* from;
@property (nonatomic, retain) InternetAddress* sender;
@property (nonatomic, retain) InternetAddress* replyTo;
@property (nonatomic, retain) NSArray* toRecipients;  // NSArray<InternetAddress*>
@property (nonatomic, retain) NSArray* ccRecipients;  // NSArray<InternetAddress*>
@property (nonatomic, retain) NSArray* bccRecipients; // NSArray<InternetAddress*>
@property (nonatomic, retain) NSArray* headers;		  // NSArray<NSDictionary*>
@property (nonatomic, retain) MimeBody* messageBody;
@property (nonatomic, assign) NSStringEncoding stringEncoding;

- (NSData*)createMessageData;

@end
