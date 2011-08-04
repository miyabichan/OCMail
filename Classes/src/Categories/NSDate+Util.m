//
//  NSDate+Util.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSDate+Util.h"

@interface NSDate (PrivateDelegateHandling)
+ (NSDateFormatter*)rfc2822Formatter;
@end


@implementation NSDate (Util)

+ (NSDateFormatter*)rfc2822Formatter {
	static NSDateFormatter *formatter = nil;
	if (formatter == nil)  {
		formatter = [[[NSDateFormatter alloc] init] autorelease];
		NSLocale *enUS = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
		[formatter setLocale:enUS];
		[formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZ"];
	}
	return [formatter retain];
}

+ (NSDate*)dateFromRFC2822:(NSString *)rfc2822 {
	NSDateFormatter *formatter = [self rfc2822Formatter];
	return [formatter dateFromString:rfc2822];
}

+ (NSString*)dateToRFC2822:(NSDate*)date {
	NSDateFormatter *formatter = [self rfc2822Formatter];
	return [formatter stringFromDate:date];
}

@end
