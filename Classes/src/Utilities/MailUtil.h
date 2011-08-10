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
+ (NSString*)createEncodeName:(NSStringEncoding)encoding;
+ (NSStringEncoding)createEncoding:(NSString*)encodeName;
+ (NSString*)encodeHeader:(NSString*)text encoding:(NSStringEncoding)encoding;
+ (NSString*)decodeHeader:(NSString*)encodedText;
+ (NSString*)createAddress:(NSString*)encodedAddress;
+ (NSString*)wrappedText:(NSString*)text;
+ (NSString*)lineText:(NSString*)wrappedText;
+ (NSArray*)createShortTexts:(NSString*)text;
+ (NSString*)createHeaderText:(NSString*)text;

@end
