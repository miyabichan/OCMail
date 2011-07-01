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
	NSString* encoding_;
	NSDate* date_;
	InternetAddress* from_;
	InternetAddress* sender_;
	InternetAddress* replyTo_;
	NSArray* receiveTo_;	// NSArray<InternetAddress*>
	NSArray* receiveCc_;	// NSArray<InternetAddress*>
	NSArray* receiveBcc_;	// NSArray<InternetAddress*>
	NSArray* headers_;		// NSArray<NSDictionary*>
	MimeBody* messageBody_;
}

@property (nonatomic, copy) NSString* messageId;
@property (nonatomic, copy) NSString* subject;
@property (nonatomic, copy) NSString* contentType;
@property (nonatomic, copy) NSString* encoding;
@property (nonatomic, retain) NSDate* date;
@property (nonatomic, retain) InternetAddress* from;
@property (nonatomic, retain) InternetAddress* sender;
@property (nonatomic, retain) InternetAddress* replyTo;
@property (nonatomic, retain) NSArray* receiveTo;	// NSArray<InternetAddress*>
@property (nonatomic, retain) NSArray* receiveCc;	// NSArray<InternetAddress*>
@property (nonatomic, retain) NSArray* receiveBcc;	// NSArray<InternetAddress*>
@property (nonatomic, retain) NSArray* headers;		// NSArray<NSDictionary*>
@property (nonatomic, retain) MimeBody* messageBody;

- (NSData*)createMessageData;

@end
