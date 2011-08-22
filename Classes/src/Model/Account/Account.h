//
//  Account.h
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InternetAddress.h"
#import "MailOperator.h"


@interface Account : NSObject {
@private
	InternetAddress* address_;
	MailOperator* mailOperator_;
}

@property (nonatomic, retain) InternetAddress* address;
@property (nonatomic, retain) MailOperator* mailOperator;

@end
