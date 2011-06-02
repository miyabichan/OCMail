//
//  NSDate+Util.h
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//  Originated by Alberto García Hierro(on dateFromRFC2822). 
//  See http://fi.am/entry/parsing-rfc2822-dates-with-nsdate/
//

#import <Foundation/Foundation.h>


@interface NSDate (Util)
+ (NSDate*)dateFromRFC2822:(NSString *)rfc2822;
+ (NSString*)dateToRFC2822:(NSDate*)date;
@end
