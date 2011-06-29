//
//  MimeMessage.h
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MimeBody.h"


@interface MimeMessage : NSObject {
@private
	NSString* messageId_;
	NSString* subject_;
	NSString* contentType_;
	NSString* encoding_;
	NSDate* date_;
	NSDictionary* from_;
	NSDictionary* sender_;
	NSDictionary* replyTo_;
	NSArray* receiveTo_; // NSArray<NSDictionary*>
	NSArray* receiveCc_; // NSArray<NSDictionary*>
	NSArray* receiveBcc_; // NSArray<NSDictionary*>
	NSArray* headers_; // NSArray<NSDictionary*>
	MimeBody* messageBody_;
}

@property (nonatomic, copy) NSString* messageId;
@property (nonatomic, copy) NSString* subject;
@property (nonatomic, copy) NSString* contentType;
@property (nonatomic, copy) NSString* encoding;
@property (nonatomic, retain) NSDate* date;
@property (nonatomic, retain) NSDictionary* from;
@property (nonatomic, retain) NSDictionary* sender;
@property (nonatomic, retain) NSDictionary* replyTo;
@property (nonatomic, retain) NSArray* receiveTo; // NSArray<NSDictionary*>
@property (nonatomic, retain) NSArray* receiveCc; // NSArray<NSDictionary*>
@property (nonatomic, retain) NSArray* receiveBcc; // NSArray<NSDictionary*>
@property (nonatomic, retain) NSArray* headers; // NSArray<NSDictionary*>
@property (nonatomic, retain) MimeBody* messageBody;

- (NSData*)createMessageData;

@end
