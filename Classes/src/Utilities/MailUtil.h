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

// This function from DINH Viet Hoa
// See http://article.gmane.org/gmane.mail.libetpan.user/377
static int fill_ip_port(mailstream* stream, char* ip_port, size_t local_ip_port_len);
+ (char*)createFillIpPort:(mailstream*)stream;
+ (char*)createCharStream:(NSString*)name;
+ (char*)createMechanism:(AuthMechanism)mechanism;


@end
