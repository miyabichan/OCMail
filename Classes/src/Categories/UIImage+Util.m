//
//  UIImage+Util.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Util.h"


@implementation UIImage (UIImage_Util)

- (UIImage*)shrinkImage:(CGRect)rect {
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
	
	[self drawInRect:rect];
	
	UIImage* shrinkedImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return shrinkedImage;
}

@end
