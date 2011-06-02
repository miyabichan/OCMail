//
//  SMTPServer.h
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MailServer.h"


@interface SMTPServer : MailServer {
@private
	mailsmtp* smtp_;
	BOOL esmtp_;
}

@property (nonatomic, assign) mailsmtp* smtp;
@property (nonatomic, assign) BOOL esmtp;

- (id)initWithResource:(mailsmtp*)smtp;
- (BOOL)elho;
- (NSInteger)sendFromAddress:(NSString*)email;
- (NSInteger)sendRecipients:(NSArray*)recipients;
- (NSInteger)sendMessage:(NSData*)message;

@end
