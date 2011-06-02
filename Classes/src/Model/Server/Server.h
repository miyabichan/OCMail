//
//  Server.h
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <libetpan/libetpan.h>

typedef enum {
	NONE = 0,
	PLAIN,
	LOGIN,
	APOP,
	CRAM_MD5,
	DIGEST_MD5,
} AuthMechanism;
