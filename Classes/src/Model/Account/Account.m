//
//  Account.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Account.h"


@implementation Account

@synthesize address = address_;
@synthesize mailOperator = mailOperator_;

#pragma mark - Inherit Methods

- (void)dealloc {
	self.address = nil;
	self.mailOperator = nil;
	[super dealloc];
}

@end
