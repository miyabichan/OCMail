//
//  BodyPart.h
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BodyPart : NSObject {
@private
	NSString* fileName_;
    NSString* contentType_;
	NSString* description_;
	NSString* disposition_;
	NSData* content_;
	NSStringEncoding encoding_;
}

@property (nonatomic, copy) NSString* fileName;
@property (nonatomic, copy) NSString* contentType;
@property (nonatomic, copy) NSString* description;
@property (nonatomic, copy) NSString* disposition;
@property (nonatomic, retain) NSData* content;
@property (nonatomic, assign) NSStringEncoding encoding;

@end
