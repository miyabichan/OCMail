//
//  MailServer.h
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Server.h"


@interface MailServer : NSObject {
@private
	NSString* userName_;
	NSString* password_;
	NSString* address_;
	NSUInteger portNo_;
	BOOL ssl_;
	AuthMechanism mechanism_;
	BOOL connected_;
	BOOL authorized_;
}

@property (nonatomic, copy) NSString* userName;
@property (nonatomic, copy) NSString* password;
@property (nonatomic, copy) NSString* address;
@property (nonatomic, assign) NSUInteger portNo;
@property (nonatomic, assign) BOOL ssl;
@property (nonatomic, assign) AuthMechanism mechanism;
@property (nonatomic, assign) BOOL connected;
@property (nonatomic, assign) BOOL authorized;

- (NSInteger)connect;
- (NSInteger)disconnect;
- (NSInteger)startTLS;
- (NSInteger)noop;
- (NSInteger)authServer;

@end
