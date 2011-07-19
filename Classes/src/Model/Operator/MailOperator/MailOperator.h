//
//  MailOperator.h
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MailServer.h"
#import "MimeMessage.h"


@interface MailOperator : NSObject {
@private
	MailServer* sendServer_;
	MailServer* receiveServer_;
	NSArray* folders_;
	BOOL imapUse_;
}

@property (nonatomic, retain) MailServer* sendServer;
@property (nonatomic, retain) MailServer* receiveServer;
@property (nonatomic, retain) NSArray* folders;
@property (nonatomic, assign) BOOL imapUse;

- (void)createRecieveServer:(MailServer*)receiveServer;
- (id)initWithSendServer:(MailServer*)sendServer receiveServer:(MailServer*)receiveServer;
- (BOOL)sendMessage:(MimeMessage*)message;

@end
