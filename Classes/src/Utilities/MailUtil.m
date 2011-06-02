//
//  MailUtil.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MailUtil.h"
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>


@implementation MailUtil

// This function from DINH Viet Hoa
// See http://article.gmane.org/gmane.mail.libetpan.user/377
static int fill_ip_port(mailstream* stream, char* ip_port, size_t local_ip_port_len) {
	mailstream_low* low = mailstream_get_low(stream);
	int fd = mailstream_low_get_fd(low);
	struct sockaddr_in name;
	socklen_t namelen = sizeof(name);
	char ip_port_buf[128];
	int r = getpeername(fd, (struct sockaddr*) &name, &namelen);
	if (r < 0)
		return -1;
	
	if (inet_ntop(AF_INET, &name.sin_addr, ip_port_buf, sizeof(ip_port_buf)))
		return -1;
	
	snprintf(ip_port, local_ip_port_len, "%s;%i", ip_port_buf, ntohs(name.sin_port));
	return 0;
}

+ (char*)createFillIpPort:(mailstream*)stream {
	char* ip_port = NULL;
	char ip_port_buf[128];
	int ret = fill_ip_port(stream, ip_port_buf, sizeof(ip_port_buf));
	if (ret >= 0 ) ip_port = ip_port_buf;
	return ip_port;
}

+ (char*)createCharStream:(NSString*)name {
	char* stream = (char*)[name cStringUsingEncoding:NSUTF8StringEncoding];
	if (stream == NULL) stream = "";
	return stream;
}

+ (char*)createMechanism:(AuthMechanism)mechanism {
	NSString* mechaStr = @"";
	switch (mechanism) {
		case PLAIN:
			mechaStr = @"PLAIN";
			break;
		case LOGIN:
			mechaStr = @"LOGIN";
			break;
		case APOP:
			mechaStr = @"APOP";
			break;
		case CRAM_MD5:
			mechaStr = @"CRAM-MD5";
			break;
		case DIGEST_MD5:
			mechaStr = @"DIGEST-MD5";
			break;
		default:
			break;
	}
	return (char*)[mechaStr cStringUsingEncoding:NSUTF8StringEncoding];
}

@end
