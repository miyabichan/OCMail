//
//  NSArray+Util.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSArray+Util.h"


@implementation NSArray (Util)

+ (BOOL)isEmpty:(NSArray*)array {
	if (array == nil) return YES;
	return (BOOL)(array.count == 0);
}

@end
