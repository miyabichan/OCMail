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

+ (NSData*)base64Encode:(NSData*)data;

+ (NSData*)base64Decode:(id)base64;

@end
