//
//  MailOperator.h
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MailServer.h"


@interface MailOperator : NSObject {
@private
	MailServer* sendServer_;
	MailServer* receiveServer_;
	BOOL imapUse_;
}

@property (nonatomic, retain) MailServer* sendServer;
@property (nonatomic, retain, setter=createRecieveServer:) MailServer* receiveServer;
@property (nonatomic, assign) BOOL imapUse;

- (id)initWithElements:(MailServer*)sendServer receiveServer:(MailServer*)receiveServer;

@end
