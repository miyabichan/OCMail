//
//  MailServer.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MailServer.h"
#import "Categories.h"


@implementation MailServer

@synthesize userName = userName_;
@synthesize password = password_;
@synthesize address = address_;
@synthesize portNo = portNo_;
@synthesize ssl = ssl_;
@synthesize mechanism = mechanism_;
@synthesize connected = connected_;
@synthesize authorized = authorized_;


- (id)init {
	if ((self = [super init])) {
		self.connected = NO;
	}
	return self;
}

- (id)initWithAddress:(NSString*)address portNo:(NSUInteger)portNo ssl:(BOOL)ssl {
	if ((self = [self init])) {
		self.address = address;
		self.portNo = portNo;
		self.ssl = ssl;
	}
	return self;
}

- (id)initWithAddress:(NSString*)address portNo:(NSUInteger)portNo ssl:(BOOL)ssl userName:(NSString*)userName password:(NSString*)password {
	if ((self =[self initWithAddress:address portNo:portNo ssl:ssl])) {
		self.userName = userName;
		self.password = password;
	}
	return self;
}

- (void)dealloc {
	self.userName = nil;
	self.password = nil;
	self.address = nil;
	[super dealloc];
}

- (NSInteger)connect {
	@throw [NSException exceptionWithName:@"NOT IMPLEMENTATION." reason:@"The method is not implemented." userInfo:nil];
}

- (NSInteger)disconnect {
	@throw [NSException exceptionWithName:@"NOT IMPLEMENTATION." reason:@"The method is not implemented." userInfo:nil];
}

- (NSInteger)startTLS {
	@throw [NSException exceptionWithName:@"NOT IMPLEMENTATION." reason:@"The method is not implemented." userInfo:nil];
}

- (NSInteger)noop {
	@throw [NSException exceptionWithName:@"NOT IMPLEMENTATION." reason:@"The method is not implemented." userInfo:nil];
}

- (NSInteger)authServer {
	@throw [NSException exceptionWithName:@"NOT IMPLEMENTATION." reason:@"The method is not implemented." userInfo:nil];
}

@end
