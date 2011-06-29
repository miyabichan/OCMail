//
//  NSData+Util.h
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (Util)

+ (BOOL)isEmpty:(NSData*)data;

+ (NSData*)base64Encode:(NSString*)string encoding:(NSStringEncoding)encoding;

+ (NSData*)base64Decode:(NSString*)base64;

@end
