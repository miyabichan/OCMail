//
//  MimeBody.h
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MimeBody : NSObject {
@private
	NSString* text_;
	NSString* boudary_;
	NSArray* parts_; // NSArray<BodyPart*>
}

@property (nonatomic, copy) NSString* text;
@property (nonatomic, copy) NSString* boundary;
@property (nonatomic, retain) NSArray* parts;

@end
