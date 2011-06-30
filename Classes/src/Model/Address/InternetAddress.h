//
//  InternetAddress.h
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface InternetAddress : NSObject {
@private
	NSString* address_;
	NSString* personal_;
	NSString* encodedPersonal_;
}

@property (nonatomic, copy) NSString* address;
@property (nonatomic, copy) NSString* personal;
@property (nonatomic, copy) NSString* encodedPersonal;

- (id)initWithAddress:(NSString*)address personal:(NSString*)personal;
- (void)createEncodedPersonal:(NSString*)personal encoding:(NSStringEncoding)encoding;
- (void)createEncodedPersonal:(NSStringEncoding)encoding;
- (void)createDecodedPersonal;
- (void)createDecodedPersonal:(NSString*)encodedPersonal;

@end
