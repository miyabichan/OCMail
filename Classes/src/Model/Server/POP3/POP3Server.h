//
//  POP3Server.h
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MailServer.h"


@interface POP3Server : MailServer {
@private
	mailpop3* pop3_;
}

@property (nonatomic, assign) mailpop3* pop3;

- (id)initWithResource:(mailpop3*)pop3;

- (NSArray*)mailList;
- (NSArray*)uidlList;
- (NSArray*)topList;
- (NSInteger)delete:(NSUInteger)index;
- (NSInteger)reset;
- (NSArray*)capability;

@end
