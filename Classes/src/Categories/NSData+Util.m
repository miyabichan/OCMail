//
//  NSData+Util.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSData+Util.h"
#import "NSString+Util.h"


@implementation NSData (Util)


+ (BOOL)isEmpty:(NSData*)data {
	if (data == nil) return YES;
	NSString* string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	return [NSString isEmpty:string];
}

@end
