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
@synthesize authorized = authorized_;


- (id)init {
	if ((self = [super init])) {
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
