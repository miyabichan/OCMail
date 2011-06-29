//
//  MailUtil.h
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libetpan/libetpan.h>
#import "Server.h"


@interface MailUtil : NSObject {
    
}

+ (char*)createFillIpPort:(mailstream*)stream;
+ (char*)createCharStream:(NSString*)name;
+ (char*)createMechanism:(AuthMechanism)mechanism;
+ (NSString*)encodePersonal:(NSString*)personal encoding:(NSStringEncoding)encoding;
+ (NSString*)decodePersonal:(NSString*)encodedPersonal;
+ (NSString*)createAddress:(NSString*)encodedPersonal;

@end
