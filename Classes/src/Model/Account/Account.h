//
//  Account.h
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMTPServer.h"


@interface Account : NSObject {
@private
	NSString* name_;
	SMTPServer* smtpServer_;
}

@end
