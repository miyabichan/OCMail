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
    NSString* contentType_;
	NSString* encoding_;
	NSString* description_;
	NSString* disposition_;
	NSString* boudary_;
	id content_;
}

@property (nonatomic, copy) NSString* contentType;
@property (nonatomic, copy) NSString* encoding;
@property (nonatomic, copy) NSString* description;
@property (nonatomic, copy) NSString* disposition;
@property (nonatomic, copy) NSString* boundary;
@property (nonatomic, retain) id content;

@end
