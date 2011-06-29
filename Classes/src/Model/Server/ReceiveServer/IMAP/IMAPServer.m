//
//  IMAPServer.m
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IMAPServer.h"
#import "Categories.h"
#import "MailUtil.h"
#import <libetpan/quota.h>
#import <libetpan/imapdriver_tools.h>
#import <malloc/malloc.h>


@interface IMAPServer (PrivateDelegateHandling)
- (NSInteger)authWithUserName:(const char*)userName password:(const char*)password address:(const char*)address;
- (NSInteger)operate:(NSString*)mailbox operation:(ImapOperation)operation;
- (NSInteger)createAttribute:(NSString*)name;
- (NSDictionary*)createStatus:(struct mailimap_mailbox_data_status*)status;
- (NSDictionary*)createQuotaRoot:(NSString*)mailbox result:(struct mailimap_quota_complete_data*)result;
- (NSDictionary*)createQuota:(struct mailimap_quota_quota_data*)quota_data;
- (clist*)fetch:(struct mailimap_fetch_type*)fetch_type set:(struct mailimap_set*)set;
- (NSData*)createMessageData:(struct mailimap_msg_att_item*)att_item;
- (NSData*)createHeaderData:(struct mailimap_msg_att_item*)att_item;
- (NSUInteger)createSize:(struct mailimap_msg_att_item*)att_item;
- (NSData*)createTextData:(struct mailimap_msg_att_item*)att_item;
- (NSArray*)createFlags:(struct mailimap_msg_att_item*)att_item;
- (NSString*)createFlag:(struct mailimap_flag*)fl_flag;
- (NSUInteger)createUID:(struct mailimap_msg_att_item*)att_item;
- (NSData*)createMessageDataFromUID:(struct mailimap_msg_att*)msg_att;
- (NSData*)createHeaderDataFromUID:(struct mailimap_msg_att*)msg_att;
- (NSUInteger)createSizeFromUID:(struct mailimap_msg_att*)msg_att;
- (NSData*)createTextDataFromUID:(struct mailimap_msg_att*)msg_att;
- (NSArray*)createFlagsFromUID:(struct mailimap_msg_att*)msg_att;
- (NSUInteger)createUIDFromUID:(struct mailimap_msg_att*)msg_att;
- (uint32_t)createFLFlags:(ImapStoreFlag)flag;
- (struct mailimap_store_att_flags*)createMailFlags:(ImapStoreFlag)flag enable:(BOOL)enable silent:(BOOL)silent;
- (NSArray*)createSearchResults:(const char*)charset key:(struct mailimap_search_key*)key;
- (NSArray*)createUIDSearchResults:(const char*)charset key:(struct mailimap_search_key*)key;
- (NSArray*)createNumbers:(clist*)result;
- (NSArray*)createMessages:(int)retCode result:(clist*)result;
- (NSArray*)createHeaders:(int)retCode result:(clist*)result;
- (NSArray*)createSizes:(int)retCode result:(clist*)result;
- (NSArray*)createTexts:(int)retCode result:(clist*)result;
- (NSArray*)createFlagsArray:(int)retCode result:(clist*)result;
- (NSArray*)createUIDs:(int)retCode result:(clist*)result;
- (NSArray*)createMessagesFromUID:(int)retCode result:(clist*)result;
- (NSArray*)createHeadersFromUID:(int)retCode result:(clist*)result;
- (NSArray*)createSizesFromUID:(int)retCode result:(clist*)result;
- (NSArray*)createTextsFromUID:(int)retCode result:(clist*)result;
- (NSArray*)createFlagsArrayFromUID:(int)retCode result:(clist*)result;
- (NSArray*)createUIDsFromUID:(int)retCode result:(clist*)result;
- (struct mailimap_search_key*)createSeenSearchKey:(BOOL)checked;
- (struct mailimap_search_key*)createAnsweredSearchKey:(BOOL)checked;
- (struct mailimap_search_key*)createDeletedSearchKey:(BOOL)checked;
- (struct mailimap_search_key*)createFlaggedSearchKey:(BOOL)checked;
- (struct mailimap_search_key*)createKeywordSearchKey:(BOOL)checked keyword:(NSString*)keyword;
- (struct mailimap_search_key*)createRecentSearchKey;
- (struct mailimap_search_key*)createDraftSearchKey;
@end


@implementation IMAPServer

@synthesize imap = imap_;
@synthesize selected = selected_;
@synthesize idle = idle_;


#define ILLEGAL_OPERATION 999u
#define ILLEGAL_AUTHMECHANISM 9999u
#define WHOLEFOLDER_NOT_FOUND 888u
#define ILLEGAL_STATUS_FOUND 8888u

#pragma mark -
#pragma mark Inherit Methods

- (id)init {
	if ((self = [super init])) {
		self.imap = mailimap_new(0, NULL);
		self.idle = NO;
		self.selected = NO;
	}
	return self;
}

- (void)dealloc {
	mailimap_free(self.imap);
	[super dealloc];
}

- (NSInteger)connect {
	int retCode = MAILIMAP_NO_ERROR;
	if (self.ssl)
		retCode = mailimap_ssl_connect(self.imap, [self.address cStringUsingEncoding:NSUTF8StringEncoding], self.portNo);
	else
		retCode = mailimap_socket_connect(self.imap, [self.address cStringUsingEncoding:NSUTF8StringEncoding], self.portNo);
	if (retCode <= MAILIMAP_NO_ERROR_NON_AUTHENTICATED) self.connected = YES;
	return retCode;
}

- (NSInteger)disconnect {
	assert(self.imap != NULL);
	if (!self.connected) @throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	int retCode = mailimap_logout(self.imap);
	if (retCode == MAILIMAP_NO_ERROR) self.connected = NO;
	return retCode;
}

- (NSInteger)startTLS {
	assert(self.imap != NULL);
	if (!self.connected) @throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	int retCode = mailimap_starttls(self.imap);
	return retCode;
}

- (NSInteger)noop {
	assert(self.imap != NULL);
	if (!self.connected) @throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	int retCode = mailimap_noop(self.imap);
	return retCode;
}

- (NSInteger)authServer {
	assert(self.imap != NULL);
	if (!self.connected) @throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	char* userName = [MailUtil createCharStream:self.userName];
	char* password = [MailUtil createCharStream:self.password];
	return [self authWithUserName:userName password:password address:[self.address cStringUsingEncoding:NSUTF8StringEncoding]];
}


#pragma mark -
#pragma mark Public Methods

- (id)initWithResource:(mailimap*)imap {
	if ((self = [super init])) {
		self.imap = imap;
		self.idle = NO;
		self.selected = NO;
	}
	return self;
}

- (NSArray*)capability {
	assert(self.imap != NULL);
	if (!self.connected) @throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_capability_data* data = NULL;
	int retCode = mailimap_capability(self.imap, &data);
	NSMutableArray* array = [NSMutableArray array];
	if (retCode != MAILIMAP_NO_ERROR) return nil;
	clistiter* iter;
	for (iter = clist_begin(data->cap_list); iter != NULL; iter = clist_next(iter)) {
		struct mailimap_capability* capa = clist_content(iter);
		NSString* capable = [NSString stringWithCString:(char*)(capa->cap_data.cap_name) encoding:NSUTF8StringEncoding];
		[array addObject:capable];
	}
	if (data) mailimap_capability_data_free(data);
	return array;
}

- (NSArray*)allFolders {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	clist* folderList = NULL;
	int retCode = mailimap_list(self.imap, "", "*", &folderList);
	if (retCode != MAILIMAP_NO_ERROR) return nil;
	if (clist_isempty(folderList)) @throw [NSError errorWithDomain:@"IMAP ERROR" code:WHOLEFOLDER_NOT_FOUND userInfo:nil];
	NSMutableArray* allFolders = [NSMutableArray array];
	clistiter* iter;
	for (iter = clist_begin(folderList); iter != NULL; iter = clist_next(iter)) {
		char* name = ((struct mailimap_mailbox_list*)iter->data)->mb_name;
		[allFolders addObject:[NSString stringWithCString:name encoding:NSUTF8StringEncoding]];
	}
	if (folderList) clist_free(folderList);
	return allFolders;
}

- (NSArray*)subscribedFolders {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	clist* folderList = NULL;
	int retCode = mailimap_lsub(self.imap, "", "*", &folderList);
	if (retCode != MAILIMAP_NO_ERROR) return nil;
	if (clist_isempty(folderList)) @throw [NSError errorWithDomain:@"IMAP ERROR" code:WHOLEFOLDER_NOT_FOUND userInfo:nil];
	NSMutableArray* subscribeds = [NSMutableArray array];
	clistiter* iter;
	for (iter = clist_begin(folderList); iter != NULL; iter = clist_next(iter)) {
		char* name = ((struct mailimap_mailbox_list*)iter->data)->mb_name;
		[subscribeds addObject:[NSString stringWithCString:name encoding:NSUTF8StringEncoding]];
	}
	if (folderList) clist_free(folderList);
	return subscribeds;
}

- (NSInteger)select:(NSString*)mailbox {
	return [self operate:mailbox operation:SELECT];
}

- (NSInteger)examine:(NSString*)mailbox {
	return [self operate:mailbox operation:EXAMINE];
}

- (NSInteger)create:(NSString*)mailbox {
	return [self operate:mailbox operation:CREATE];
}

- (NSInteger)delete:(NSString*)mailbox {
	return [self operate:mailbox operation:DELETE];
}

- (NSInteger)subscribe:(NSString*)mailbox {
	return [self operate:mailbox operation:SUBSCRIBE];
}

- (NSInteger)unsubscribe:(NSString*)mailbox {
	return [self operate:mailbox operation:UNSUBSCRIBE];
}

- (NSInteger)rename:(NSString*)oldName newName:(NSString*)newName {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	char* old = [MailUtil createCharStream:oldName];
	char* new = [MailUtil createCharStream:newName];
	int retCode = mailimap_rename(self.imap, old, new);
	return retCode;
}

- (NSDictionary*)status:(NSString*)mailbox infos:(NSArray*)infos {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	char* name = [MailUtil createCharStream:mailbox];
	struct mailimap_status_att_list* att_list = mailimap_status_att_list_new_empty();
	for (NSString* info in infos) {
		mailimap_status_att_list_add(att_list, [self createAttribute:info]);
	}
	struct mailimap_mailbox_data_status* result = NULL;
	int retCode = mailimap_status(self.imap, name, att_list, &result);
	if (retCode != MAILIMAP_NO_ERROR) return nil;
	NSDictionary* dictionary =  [self createStatus:result];
	if (result) mailimap_mailbox_data_status_free(result);
	if (att_list) mailimap_status_att_list_free(att_list);
	return dictionary;
}

- (NSDictionary*)allStatus:(NSString*)mailbox {
	NSArray* infos = [NSArray arrayWithObjects:@"MESSAGES", @"RECENT", @"UIDNEXT", @"UIDVALIDITY", @"UNSEEN", nil];
	return [self status:mailbox infos:infos];
}

- (NSInteger)check {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	int retCode = mailimap_check(self.imap);
	return retCode;
}

- (NSInteger)close {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	int retCode = mailimap_close(self.imap);
	if (retCode == MAILIMAP_NO_ERROR) self.selected = YES;
	else self.selected = NO;
	return retCode;
}

- (NSInteger)startIdle {
	assert(self.imap != NULL);
	if (!self.connected) @throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	if (self.idle) return MAILIMAP_NO_ERROR;
	int retCode = mailimap_idle(self.imap);
	if (retCode == MAILIMAP_NO_ERROR) self.idle = YES;
	return retCode;
}

- (NSInteger)endIdle {
	assert(self.imap != NULL);
	if (!self.connected) @throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	if (!self.idle) return MAILIMAP_NO_ERROR;
	int retCode = mailimap_idle_done(self.imap);
	if (retCode == MAILIMAP_NO_ERROR) self.idle = NO;
	return retCode;
}

- (NSDictionary*)getQuotaRoot:(NSString*)mailbox {
	assert(self.imap != NULL);
	if (!self.connected) @throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_quota_complete_data* result = NULL;
	char* name = [MailUtil createCharStream:mailbox];
	int retCode = mailimap_quota_getquotaroot(self.imap, name, &result);
	if (retCode != MAILIMAP_NO_ERROR) return nil;
	NSDictionary* dicitionary = [self createQuotaRoot:mailbox result:result];
	if (result) mailimap_quota_complete_data_free(result);
	return dicitionary;
}

- (NSDictionary*)getQuotaRoot {
	return [self getQuotaRoot:@""];
}

- (NSInteger)append:(NSData*)message mailbox:(NSString*)mailbox {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	int retCode = mailimap_append_simple(self.imap, [MailUtil createCharStream:mailbox], (char*)[message bytes], [message length]);
	return retCode;
}

- (NSData*)fetchMessage:(NSUInteger)index {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	char* result = NULL;
	NSData* data = nil;
	int retCode = mailimap_fetch_rfc822(self.imap, index, &result);
	if (retCode == MAILIMAP_NO_ERROR && result) {
		data = [NSData dataWithBytes:result length:strlen(result)];
	}
	return data;
}

- (NSData*)fetchHeader:(NSUInteger)index {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	char* result = NULL;
	NSData* data = nil;
	int retCode = mailimap_fetch_rfc822_header(self.imap, index, &result);
	if (retCode == MAILIMAP_NO_ERROR && result) {
		data = [NSData dataWithBytes:result length:strlen(result)];
	}
	return data;
}

- (NSNumber*)fetchSize:(NSUInteger)index {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	NSNumber* size = nil;
	struct mailimap_fetch_att* fetch_att = mailimap_fetch_att_new_rfc822_size();
	struct mailimap_fetch_type* fetch_type = mailimap_fetch_type_new_fetch_att(fetch_att);
	struct mailimap_set* set = mailimap_set_new_single(index);
	clist* result = NULL;
	int retCode = mailimap_fetch(self.imap, set, fetch_type, &result);
	if (retCode == MAILIMAP_NO_ERROR && result && !clist_isempty(result)) {
		struct mailimap_msg_att* msg_att = clist_begin(result)->data;
		struct mailimap_msg_att_item* att_item = clist_begin(msg_att->att_list)->data;
		size = [NSNumber numberWithUnsignedInteger:[self createSize:att_item]];
	}
	if (result) mailimap_fetch_list_free(result);
	if (fetch_type) mailimap_fetch_type_free(fetch_type);
	if (set) mailimap_set_free(set);
	return size;	
}

- (NSData*)fetchText:(NSUInteger)index {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	NSData* data = nil;
	struct mailimap_fetch_att* fetch_att = mailimap_fetch_att_new_rfc822_text();
	struct mailimap_fetch_type* fetch_type = mailimap_fetch_type_new_fetch_att(fetch_att);
	struct mailimap_set* set = mailimap_set_new_single(index);
	clist* result = NULL;
	int retCode = mailimap_fetch(self.imap, set, fetch_type, &result);
	if (retCode == MAILIMAP_NO_ERROR && result && !clist_isempty(result)) {
		struct mailimap_msg_att* msg_att = clist_begin(result)->data;
		struct mailimap_msg_att_item* att_item = clist_begin(msg_att->att_list)->data;
		data = [self createTextData:att_item];
	}
	if (result) mailimap_fetch_list_free(result);
	if (fetch_type) mailimap_fetch_type_free(fetch_type);
	if (set) mailimap_set_free(set);
	return data;
}

- (NSArray*)fetchFlags:(NSUInteger)index {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	NSArray* flags = nil;
	struct mailimap_fetch_att* fetch_att = mailimap_fetch_att_new_flags();
	struct mailimap_fetch_type* fetch_type = mailimap_fetch_type_new_fetch_att(fetch_att);
	struct mailimap_set* set = mailimap_set_new_single(index);
	clist* result = NULL;
	int retCode = mailimap_fetch(self.imap, set, fetch_type, &result);
	if (retCode == MAILIMAP_NO_ERROR && result && !clist_isempty(result)) {
		struct mailimap_msg_att* msg_att = clist_begin(result)->data;
		struct mailimap_msg_att_item* att_item = clist_begin(msg_att->att_list)->data;
		flags = [self createFlags:att_item];
	}
	if (result) mailimap_fetch_list_free(result);
	if (fetch_type) mailimap_fetch_type_free(fetch_type);
	if (set) mailimap_set_free(set);
	return flags;
}

- (NSNumber*)fetchUID:(NSUInteger)index {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	NSNumber* uid = nil;
	struct mailimap_fetch_att* fetch_att = mailimap_fetch_att_new_uid();
	struct mailimap_fetch_type* fetch_type = mailimap_fetch_type_new_fetch_att(fetch_att);
	struct mailimap_set* set = mailimap_set_new_single(index);
	clist* result = NULL;
	int retCode = mailimap_fetch(self.imap, set, fetch_type, &result);
	if (retCode == MAILIMAP_NO_ERROR && result && !clist_isempty(result)) {
		struct mailimap_msg_att* msg_att = clist_begin(result)->data;
		struct mailimap_msg_att_item* att_item = clist_begin(msg_att->att_list)->data;
		uid = [NSNumber numberWithUnsignedInteger:[self createUID:att_item]];
	}
	if (result) mailimap_fetch_list_free(result);
	if (fetch_type) mailimap_fetch_type_free(fetch_type);
	if (set) mailimap_set_free(set);
	return uid;
}

- (NSData*)fetchMessageWithUID:(NSUInteger)uid {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	NSData* data = nil;
	struct mailimap_fetch_att* fetch_att = mailimap_fetch_att_new_rfc822();
	struct mailimap_fetch_type* fetch_type = mailimap_fetch_type_new_fetch_att(fetch_att);
	struct mailimap_set* set = mailimap_set_new_single(uid);
	clist* result = NULL;
	int retCode = mailimap_uid_fetch(self.imap, set, fetch_type, &result);
	if (retCode == MAILIMAP_NO_ERROR && result && !clist_isempty(result)) {
		struct mailimap_msg_att* msg_att = clist_begin(result)->data;
		data = [self createMessageDataFromUID:msg_att];
	}
	if (result) mailimap_fetch_list_free(result);
	if (fetch_type) mailimap_fetch_type_free(fetch_type);
	if (set) mailimap_set_free(set);
	return data;
}

- (NSData*)fetchHeaderWithUID:(NSUInteger)uid {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	NSData* data = nil;
	struct mailimap_fetch_att* fetch_att = mailimap_fetch_att_new_rfc822_header();
	struct mailimap_fetch_type* fetch_type = mailimap_fetch_type_new_fetch_att(fetch_att);
	struct mailimap_set* set = mailimap_set_new_single(uid);
	clist* result = NULL;
	int retCode = mailimap_uid_fetch(self.imap, set, fetch_type, &result);
	if (retCode == MAILIMAP_NO_ERROR && result && !clist_isempty(result)) {
		struct mailimap_msg_att* msg_att = clist_begin(result)->data;
		data = [self createHeaderDataFromUID:msg_att];
	}
	if (result) mailimap_fetch_list_free(result);
	if (fetch_type) mailimap_fetch_type_free(fetch_type);
	if (set) mailimap_set_free(set);
	return data;
}

- (NSNumber*)fetchSizeWithUID:(NSUInteger)uid {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	NSNumber* size = nil;
	struct mailimap_fetch_att* fetch_att = mailimap_fetch_att_new_rfc822_size();
	struct mailimap_fetch_type* fetch_type = mailimap_fetch_type_new_fetch_att(fetch_att);
	struct mailimap_set* set = mailimap_set_new_single(uid);
	clist* result = NULL;
	int retCode = mailimap_uid_fetch(self.imap, set, fetch_type, &result);
	if (retCode == MAILIMAP_NO_ERROR && result && !clist_isempty(result)) {
		struct mailimap_msg_att* msg_att = clist_begin(result)->data;
		size = [NSNumber numberWithUnsignedInteger:[self createSizeFromUID:msg_att]];
	}
	if (result) mailimap_fetch_list_free(result);
	if (fetch_type) mailimap_fetch_type_free(fetch_type);
	if (set) mailimap_set_free(set);
	return size;	
}

- (NSData*)fetchTextWithUID:(NSUInteger)uid {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	NSData* data = nil;
	struct mailimap_fetch_att* fetch_att = mailimap_fetch_att_new_rfc822_text();
	struct mailimap_fetch_type* fetch_type = mailimap_fetch_type_new_fetch_att(fetch_att);
	struct mailimap_set* set = mailimap_set_new_single(uid);
	clist* result = NULL;
	int retCode = mailimap_uid_fetch(self.imap, set, fetch_type, &result);
	if (retCode == MAILIMAP_NO_ERROR && result && !clist_isempty(result)) {
		struct mailimap_msg_att* msg_att = clist_begin(result)->data;
		data = [self createTextDataFromUID:msg_att];
	}
	if (result) mailimap_fetch_list_free(result);
	if (fetch_type) mailimap_fetch_type_free(fetch_type);
	if (set) mailimap_set_free(set);
	return data;
}

- (NSArray*)fetchFlagsWithUID:(NSUInteger)uid {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	NSArray* flags = nil;
	struct mailimap_set* set = mailimap_set_new_single(uid);
	struct mailimap_fetch_att* fetch_att = mailimap_fetch_att_new_flags();
	struct mailimap_fetch_type* fetch_type = mailimap_fetch_type_new_fetch_att(fetch_att);
	clist* result = NULL;
	int retCode = mailimap_uid_fetch(self.imap, set, fetch_type, &result);
	if (retCode == MAILIMAP_NO_ERROR && result && !clist_isempty(result)) {
		struct mailimap_msg_att* msg_att = clist_begin(result)->data;
		flags = [self createFlagsFromUID:msg_att];
	}
	if (result) mailimap_fetch_list_free(result);
	if (fetch_type) mailimap_fetch_type_free(fetch_type);
	if (set) mailimap_set_free(set);
	return flags;
}

- (NSNumber*)fetchUIDWithUID:(NSUInteger)uid {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	NSNumber* myUid = 0;
	struct mailimap_set* set = mailimap_set_new_single(uid);
	struct mailimap_fetch_att* fetch_att = mailimap_fetch_att_new_uid();
	struct mailimap_fetch_type* fetch_type = mailimap_fetch_type_new_fetch_att(fetch_att);
	clist* result = NULL;
	int retCode = mailimap_uid_fetch(self.imap, set, fetch_type, &result);
	if (retCode == MAILIMAP_NO_ERROR && result && !clist_isempty(result)) {
		struct mailimap_msg_att* msg_att = clist_begin(result)->data;
		myUid = [NSNumber numberWithUnsignedInteger:[self createUIDFromUID:msg_att]];
	}
	if (result) mailimap_fetch_list_free(result);
	if (fetch_type) mailimap_fetch_type_free(fetch_type);
	if (set) mailimap_set_free(set);
	return myUid;
}

- (NSArray*)fetchMessagesWithRange:(NSRange)range {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_set* set = mailimap_set_new_interval(range.location, range.location + range.length);
	struct mailimap_fetch_att* fetch_att = mailimap_fetch_att_new_rfc822();
	struct mailimap_fetch_type* fetch_type = mailimap_fetch_type_new_fetch_att(fetch_att);
	clist* result = NULL;
	int retCode = mailimap_fetch(self.imap, set, fetch_type, &result);
	NSArray* array = [self createMessages:retCode result:result];
	if (result) mailimap_fetch_list_free(result);
	if (fetch_type) mailimap_fetch_type_free(fetch_type);
	if (set) mailimap_set_free(set);
	return array;
}

- (NSArray*)fetchHeadersWithRange:(NSRange)range {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_set* set = mailimap_set_new_interval(range.location, range.location + range.length);
	struct mailimap_fetch_att* fetch_att = mailimap_fetch_att_new_rfc822_header();
	struct mailimap_fetch_type* fetch_type = mailimap_fetch_type_new_fetch_att(fetch_att);
	clist* result = NULL;
	int retCode = mailimap_fetch(self.imap, set, fetch_type, &result);
	NSArray* array = [self createHeaders:retCode result:result];
	if (result) mailimap_fetch_list_free(result);
	if (fetch_type) mailimap_fetch_type_free(fetch_type);
	if (set) mailimap_set_free(set);
	return array;
}

- (NSArray*)fetchSizesWithRange:(NSRange)range {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_set* set = mailimap_set_new_interval(range.location, range.location + range.length);
	struct mailimap_fetch_att* fetch_att = mailimap_fetch_att_new_rfc822_size();
	struct mailimap_fetch_type* fetch_type = mailimap_fetch_type_new_fetch_att(fetch_att);
	clist* result = NULL;
	int retCode = mailimap_fetch(self.imap, set, fetch_type, &result);
	NSArray* array = [self createSizes:retCode result:result];
	if (result) mailimap_fetch_list_free(result);
	if (fetch_type) mailimap_fetch_type_free(fetch_type);
	if (set) mailimap_set_free(set);
	return array;
}

- (NSArray*)fetchTextsWithRange:(NSRange)range {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_set* set = mailimap_set_new_interval(range.location, range.location + range.length);
	struct mailimap_fetch_att* fetch_att = mailimap_fetch_att_new_rfc822_text();
	struct mailimap_fetch_type* fetch_type = mailimap_fetch_type_new_fetch_att(fetch_att);
	clist* result = NULL;
	int retCode = mailimap_fetch(self.imap, set, fetch_type, &result);
	NSArray* array = [self createTexts:retCode result:result];
	if (result) mailimap_fetch_list_free(result);
	if (fetch_type) mailimap_fetch_type_free(fetch_type);
	if (set) mailimap_set_free(set);
	return array;
}

- (NSArray*)fetchFlagsWithRange:(NSRange)range {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_set* set = mailimap_set_new_interval(range.location, range.location + range.length);
	struct mailimap_fetch_att* fetch_att = mailimap_fetch_att_new_flags();
	struct mailimap_fetch_type* fetch_type = mailimap_fetch_type_new_fetch_att(fetch_att);
	clist* result = NULL;
	int retCode = mailimap_fetch(self.imap, set, fetch_type, &result);
	NSArray* array = [self createFlagsArray:retCode result:result];
	if (result) mailimap_fetch_list_free(result);
	if (fetch_type) mailimap_fetch_type_free(fetch_type);
	if (set) mailimap_set_free(set);
	return array;
}

- (NSArray*)fetchUIDsWithRange:(NSRange)range {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_set* set = mailimap_set_new_interval(range.location, range.location + range.length);
	struct mailimap_fetch_att* fetch_att = mailimap_fetch_att_new_uid();
	struct mailimap_fetch_type* fetch_type = mailimap_fetch_type_new_fetch_att(fetch_att);
	clist* result = NULL;
	int retCode = mailimap_fetch(self.imap, set, fetch_type, &result);
	NSArray* array = [self createUIDs:retCode result:result];
	if (result) mailimap_fetch_list_free(result);
	if (fetch_type) mailimap_fetch_type_free(fetch_type);
	if (set) mailimap_set_free(set);
	return array;
}

- (NSArray*)fetchMessagesWithUIDRange:(NSRange)range {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_set* set = mailimap_set_new_interval(range.location, range.location + range.length);
	struct mailimap_fetch_att* fetch_att = mailimap_fetch_att_new_rfc822();
	struct mailimap_fetch_type* fetch_type = mailimap_fetch_type_new_fetch_att(fetch_att);
	clist* result = NULL;
	int retCode = mailimap_uid_fetch(self.imap, set, fetch_type, &result);
	NSArray* array = [self createMessagesFromUID:retCode result:result];
	if (result) mailimap_fetch_list_free(result);
	if (fetch_type) mailimap_fetch_type_free(fetch_type);
	if (set) mailimap_set_free(set);
	return array;
}

- (NSArray*)fetchHeadersWithUIDRange:(NSRange)range {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_set* set = mailimap_set_new_interval(range.location, range.location + range.length);
	struct mailimap_fetch_att* fetch_att = mailimap_fetch_att_new_rfc822_header();
	struct mailimap_fetch_type* fetch_type = mailimap_fetch_type_new_fetch_att(fetch_att);
	clist* result = NULL;
	int retCode = mailimap_uid_fetch(self.imap, set, fetch_type, &result);
	NSArray* array = [self createHeadersFromUID:retCode result:result];
	if (result) mailimap_fetch_list_free(result);
	if (fetch_type) mailimap_fetch_type_free(fetch_type);
	if (set) mailimap_set_free(set);
	return array;
}

- (NSArray*)fetchSizesWithUIDRange:(NSRange)range {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_set* set = mailimap_set_new_interval(range.location, range.location + range.length);
	struct mailimap_fetch_att* fetch_att = mailimap_fetch_att_new_rfc822_size();
	struct mailimap_fetch_type* fetch_type = mailimap_fetch_type_new_fetch_att(fetch_att);
	clist* result = NULL;
	int retCode = mailimap_uid_fetch(self.imap, set, fetch_type, &result);
	NSArray* array = [self createSizesFromUID:retCode result:result];
	if (result) mailimap_fetch_list_free(result);
	if (fetch_type) mailimap_fetch_type_free(fetch_type);
	if (set) mailimap_set_free(set);
	return array;
}

- (NSArray*)fetchTextsWithUIDRange:(NSRange)range {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_set* set = mailimap_set_new_interval(range.location, range.location + range.length);
	struct mailimap_fetch_att* fetch_att = mailimap_fetch_att_new_rfc822_text();
	struct mailimap_fetch_type* fetch_type = mailimap_fetch_type_new_fetch_att(fetch_att);
	clist* result = NULL;
	int retCode = mailimap_uid_fetch(self.imap, set, fetch_type, &result);
	NSArray* array = [self createTextsFromUID:retCode result:result];
	if (result) mailimap_fetch_list_free(result);
	if (fetch_type) mailimap_fetch_type_free(fetch_type);
	if (set) mailimap_set_free(set);
	return array;
}

- (NSArray*)fetchFlagsWithUIDRange:(NSRange)range {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_set* set = mailimap_set_new_interval(range.location, range.location + range.length);
	struct mailimap_fetch_att* fetch_att = mailimap_fetch_att_new_flags();
	struct mailimap_fetch_type* fetch_type = mailimap_fetch_type_new_fetch_att(fetch_att);
	clist* result = NULL;
	int retCode = mailimap_uid_fetch(self.imap, set, fetch_type, &result);
	NSArray* array = [self createFlagsArrayFromUID:retCode result:result];
	if (result) mailimap_fetch_list_free(result);
	if (fetch_type) mailimap_fetch_type_free(fetch_type);
	if (set) mailimap_set_free(set);
	return array;
}

- (NSArray*)fetchUIDsWithUIDRange:(NSRange)range {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_set* set = mailimap_set_new_interval(range.location, range.location + range.length);
	struct mailimap_fetch_att* fetch_att = mailimap_fetch_att_new_uid();
	struct mailimap_fetch_type* fetch_type = mailimap_fetch_type_new_fetch_att(fetch_att);
	clist* result = NULL;
	int retCode = mailimap_uid_fetch(self.imap, set, fetch_type, &result);
	NSArray* array = [self createUIDsFromUID:retCode result:result];
	if (result) mailimap_fetch_list_free(result);
	if (fetch_type) mailimap_fetch_type_free(fetch_type);
	if (set) mailimap_set_free(set);
	return array;

}

- (NSInteger)store:(NSUInteger)index flag:(ImapStoreFlag)flag enable:(BOOL)enable silent:(BOOL)silent {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_store_att_flags *att_flags = [self createMailFlags:flag enable:enable silent:silent];
	struct mailimap_set* set = mailimap_set_new_single(index);
	int retCode = mailimap_store(self.imap, set, att_flags);
	if (att_flags) mailimap_store_att_flags_free(att_flags);
	if (set) mailimap_set_free(set);
	return retCode;
}

- (NSInteger)storeWithRange:(NSRange)range flag:(ImapStoreFlag)flag enable:(BOOL)enable silent:(BOOL)silent {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_store_att_flags *att_flags = [self createMailFlags:flag enable:enable silent:silent];
	struct mailimap_set* set = mailimap_set_new_interval(range.location, range.location + range.length);
	int retCode = mailimap_store(self.imap, set, att_flags);
	if (att_flags) mailimap_store_att_flags_free(att_flags);
	if (set) mailimap_set_free(set);
	return retCode;
}

- (NSInteger)storeWithUID:(NSUInteger)uid flag:(ImapStoreFlag)flag enable:(BOOL)enable silent:(BOOL)silent {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_store_att_flags *att_flags = [self createMailFlags:flag enable:enable silent:silent];
	struct mailimap_set* set = mailimap_set_new_single(uid);
	int retCode = mailimap_uid_store(self.imap, set, att_flags);
	if (att_flags) mailimap_store_att_flags_free(att_flags);
	if (set) mailimap_set_free(set);
	return retCode;
}

- (NSInteger)storeWithUIDRange:(NSRange)range flag:(ImapStoreFlag)flag enable:(BOOL)enable silent:(BOOL)silent {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_store_att_flags *att_flags = [self createMailFlags:flag enable:enable silent:silent];
	struct mailimap_set* set = mailimap_set_new_interval(range.location, range.location + range.length);
	int retCode = mailimap_uid_store(self.imap, set, att_flags);
	if (att_flags) mailimap_store_att_flags_free(att_flags);
	if (set) mailimap_set_free(set);
	return retCode;
}

- (NSInteger)copy:(NSUInteger)index mailbox:(NSString*)mailbox {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_set* set = mailimap_set_new_single(index);
	char* name = [MailUtil createCharStream:mailbox];
	int retCode = mailimap_copy(self.imap, set, name);
	if (set) mailimap_set_free(set);
	return retCode;
}

- (NSInteger)copyWithRange:(NSRange)range mailbox:(NSString*)mailbox {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_set* set = mailimap_set_new_interval(range.location, range.location + range.length);
	char* name = [MailUtil createCharStream:mailbox];
	int retCode = mailimap_copy(self.imap, set, name);
	if (set) mailimap_set_free(set);
	return retCode;
}

- (NSInteger)copyWithUID:(NSUInteger)uid mailbox:(NSString*)mailbox {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_set* set = mailimap_set_new_single(uid);
	char* name = [MailUtil createCharStream:mailbox];
	int retCode = mailimap_uid_copy(self.imap, set, name);
	if (set) mailimap_set_free(set);
	return retCode;
}

- (NSInteger)copyWithUIDRange:(NSRange)range mailbox:(NSString*)mailbox {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_set* set = mailimap_set_new_interval(range.location, range.location + range.length);
	char* name = [MailUtil createCharStream:mailbox];
	int retCode = mailimap_uid_copy(self.imap, set, name);
	if (set) mailimap_set_free(set);
	return retCode;
}

- (NSInteger)expunge {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	int retCode = mailimap_expunge(self.imap);
	return retCode;
}

- (NSInteger)expungeWithUIDRange:(NSRange)range {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_set* set = mailimap_set_new_interval(range.location, range.location + range.length);
	int retCode = mailimap_uid_expunge(self.imap, set);
	if (set) mailimap_set_free(set);
	return retCode;
}

- (NSArray*)searchAll {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = mailimap_search_key_new_all();
	char* charset = NULL;
	NSArray* array = [self createSearchResults:charset key:key];
	if (key) mailimap_search_key_free(key);
	return array;
}

- (NSArray*)searchSeen:(BOOL)checked {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = [self createSeenSearchKey:checked];
	char* charset = NULL;
	NSArray* array = [self createSearchResults:charset key:key];
	if (key) mailimap_search_key_free(key);
	return array;
}

- (NSArray*)searchAnswered:(BOOL)checked {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = [self createAnsweredSearchKey:checked];
	char* charset = NULL;
	NSArray* array = [self createSearchResults:charset key:key];
	if (key) mailimap_search_key_free(key);
	return array;
}

- (NSArray*)searchDeleted:(BOOL)checked {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = [self createDeletedSearchKey:checked];
	char* charset = NULL;
	NSArray* array = [self createSearchResults:charset key:key];
	if (key) mailimap_search_key_free(key);
	return array;
}

- (NSArray*)searchFlagged:(BOOL)checked {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = [self createFlaggedSearchKey:YES];
	char* charset = NULL;
	NSArray* array = [self createSearchResults:charset key:key];
	if (key) mailimap_search_key_free(key);
	return array;
}

- (NSArray*)searchKeyword:(BOOL)checked keyword:(NSString*)keyword {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = [self createKeywordSearchKey:YES keyword:keyword];
	char* charset = NULL;
	NSArray* array = [self createSearchResults:charset key:key];
	if (key) mailimap_search_key_free(key);
	return array;
}

- (NSArray*)searchRecent {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = [self createRecentSearchKey];
	char* charset = NULL;
	NSArray* array = [self createSearchResults:charset key:key];
	if (key) mailimap_search_key_free(key);
	return array;
}

- (NSArray*)searchDraft {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = [self createDraftSearchKey];
	char* charset = NULL;
	NSArray* array = [self createSearchResults:charset key:key];
	if (key) mailimap_search_key_free(key);
	return array;
}

- (NSArray*)searchFrom:(NSString*)field {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = mailimap_search_key_new_from([MailUtil createCharStream:field]);
	char* charset = NULL;
	NSArray* array = [self createSearchResults:charset key:key];
	if (key) free(key);
	return array;
}

- (NSArray*)searchTo:(NSString*)field {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = mailimap_search_key_new_to([MailUtil createCharStream:field]);
	char* charset = NULL;
	NSArray* array = [self createSearchResults:charset key:key];
	if (key) free(key);
	return array;
}

- (NSArray*)searchCc:(NSString*)field {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = mailimap_search_key_new_cc([MailUtil createCharStream:field]);
	char* charset = NULL;
	NSArray* array = [self createSearchResults:charset key:key];
	if (key) free(key);
	return array;
}

- (NSArray*)searchSubject:(NSString*)field {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = mailimap_search_key_new_subject([MailUtil createCharStream:field]);
	char* charset = NULL;
	NSArray* array = [self createSearchResults:charset key:key];
	if (key) free(key);
	return array;
}

- (NSArray*)searchHeader:(NSString*)header field:(NSString*)field {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = mailimap_search_key_new_header([MailUtil createCharStream:header], [MailUtil createCharStream:field]);
	char* charset = NULL;
	NSArray* array = [self createSearchResults:charset key:key];
	if (key) free(key);
	return array;
}

- (NSArray*)searchUID:(NSUInteger)uid {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_set* set = mailimap_set_new_single(uid);
	struct mailimap_search_key* key = mailimap_search_key_new_uid(set);
	char* charset = NULL;
	NSArray* array = [self createSearchResults:charset key:key];
	if (key) mailimap_search_key_free(key);
	return array;
}

- (NSArray*)searchText:(NSString*)field {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = mailimap_search_key_new_text([MailUtil createCharStream:field]);
	char* charset = NULL;
	NSArray* array = [self createSearchResults:charset key:key];
	if (key) free(key);
	return array;
}

- (NSArray*)uidSearchAll {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = mailimap_search_key_new_all();
	char* charset = NULL;
	NSArray* array = [self createUIDSearchResults:charset key:key];
	if (key) mailimap_search_key_free(key);
	return array;
}

- (NSArray*)uidSearchSeen:(BOOL)checked {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = [self createSeenSearchKey:checked];
	char* charset = NULL;
	NSArray* array = [self createUIDSearchResults:charset key:key];
	if (key) mailimap_search_key_free(key);
	return array;
}

- (NSArray*)uidSearchAnswered:(BOOL)checked {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = [self createAnsweredSearchKey:checked];
	char* charset = NULL;
	NSArray* array = [self createUIDSearchResults:charset key:key];
	if (key) mailimap_search_key_free(key);
	return array;
}

- (NSArray*)uidSearchDeleted:(BOOL)checked {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = [self createDeletedSearchKey:checked];
	char* charset = NULL;
	NSArray* array = [self createUIDSearchResults:charset key:key];
	if (key) mailimap_search_key_free(key);
	return array;
}

- (NSArray*)uidSearchFlagged:(BOOL)checked {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = [self createFlaggedSearchKey:checked];
	char* charset = NULL;
	NSArray* array = [self createUIDSearchResults:charset key:key];
	if (key) mailimap_search_key_free(key);
	return array;
}

- (NSArray*)uidSearchKeyword:(BOOL)checked keyword:(NSString *)keyword {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = [self createKeywordSearchKey:checked keyword:keyword];
	char* charset = NULL;
	NSArray* array = [self createUIDSearchResults:charset key:key];
	if (key) mailimap_search_key_free(key);
	return array;
}

- (NSArray*)uidSearchRecent {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = [self createRecentSearchKey];
	char* charset = NULL;
	NSArray* array = [self createUIDSearchResults:charset key:key];
	if (key) mailimap_search_key_free(key);
	return array;
}

- (NSArray*)uidSearchDraft {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = [self createDraftSearchKey];
	char* charset = NULL;
	NSArray* array = [self createUIDSearchResults:charset key:key];
	if (key) mailimap_search_key_free(key);
	return array;
}

- (NSArray*)uidSearchFrom:(NSString*)field {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = mailimap_search_key_new_from([MailUtil createCharStream:field]);
	char* charset = NULL;
	NSArray* array = [self createUIDSearchResults:charset key:key];
	if (key) free(key);
	return array;
}

- (NSArray*)uidSearchTo:(NSString*)field {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = mailimap_search_key_new_to([MailUtil createCharStream:field]);
	char* charset = NULL;
	NSArray* array = [self createUIDSearchResults:charset key:key];
	if (key) free(key);
	return array;
}

- (NSArray*)uidSearchCc:(NSString*)field {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = mailimap_search_key_new_cc([MailUtil createCharStream:field]);
	char* charset = NULL;
	NSArray* array = [self createUIDSearchResults:charset key:key];
	if (key) free(key);
	return array;
}

- (NSArray*)uidSearchSubject:(NSString*)field {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = mailimap_search_key_new_subject([MailUtil createCharStream:field]);
	char* charset = NULL;
	NSArray* array = [self createUIDSearchResults:charset key:key];
	if (key) free(key);
	return array;
}

- (NSArray*)uidSearchHeader:(NSString*)header field:(NSString*)field {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = mailimap_search_key_new_header([MailUtil createCharStream:header], [MailUtil createCharStream:field]);
	char* charset = NULL;
	NSArray* array = [self createUIDSearchResults:charset key:key];
	if (key) free(key);
	return array;
}

- (NSArray*)uidSearchUID:(NSUInteger)uid {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_set* set = mailimap_set_new_single(uid);
	struct mailimap_search_key* key = mailimap_search_key_new_uid(set);
	char* charset = NULL;
	NSArray* array = [self createUIDSearchResults:charset key:key];
	if (key) mailimap_search_key_free(key);
	return array;
}

- (NSArray*)uidSearchText:(NSString*)field {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	struct mailimap_search_key* key = mailimap_search_key_new_text([MailUtil createCharStream:field]);
	char* charset = NULL;
	NSArray* array = [self createUIDSearchResults:charset key:key];
	if (key) free(key);
	return array;
}


#pragma mark -
#pragma mark Private Methods

- (NSInteger)authWithUserName:(const char*)userName password:(const char*)password address:(const char*)address {
	NSInteger retCode = MAILIMAP_NO_ERROR;
	switch (self.mechanism) {
		case NONE:
			retCode = mailimap_login_simple(self.imap, userName, password);
			break;
		case CRAM_MD5:
		case DIGEST_MD5: {
			char* local_ip_port = [MailUtil createFillIpPort:self.imap->imap_stream];
			char* remote_ip_port = [MailUtil createFillIpPort:self.imap->imap_stream];
			char* mechamism = [MailUtil createMechanism:self.mechanism];
			retCode = mailimap_authenticate(self.imap, mechamism, address, local_ip_port, remote_ip_port, userName, userName, password, address);
		}
			break;
		default:
			@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
			break;
	}
	if (retCode == MAILIMAP_NO_ERROR) self.authorized = YES;
	return retCode;
}

- (NSInteger)operate:(NSString*)mailbox operation:(ImapOperation)operation {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	int retCode = MAILIMAP_NO_ERROR;
	switch (operation) {
		case SELECT:
			retCode = mailimap_select(self.imap, [MailUtil createCharStream:mailbox]);
			if (retCode == MAILIMAP_NO_ERROR) self.selected = YES;
			else self.selected = NO;
			break;
		case EXAMINE:
			retCode = mailimap_examine(self.imap, [MailUtil createCharStream:mailbox]);
			break;
		case CREATE:
			retCode = mailimap_create(self.imap, [MailUtil createCharStream:mailbox]);
			break;
		case DELETE:
			retCode = mailimap_delete(self.imap, [MailUtil createCharStream:mailbox]);
			break;
		case SUBSCRIBE:
			retCode = mailimap_subscribe(self.imap, [MailUtil createCharStream:mailbox]);
			break;
		case UNSUBSCRIBE:
			retCode = mailimap_unsubscribe(self.imap, [MailUtil createCharStream:mailbox]);
			break;
		default:
			break;
	}
	return retCode;
}

- (NSInteger)createAttribute:(NSString*)name {
	if ([name isEqualToString:@"MESSAGES"]) return MAILIMAP_STATUS_ATT_MESSAGES;
	if ([name isEqualToString:@"RECENT"]) return MAILIMAP_STATUS_ATT_RECENT;
	if ([name isEqualToString:@"UIDNEXT"]) return MAILIMAP_STATUS_ATT_UIDNEXT;
	if ([name isEqualToString:@"UIDVALIDITY"]) return MAILIMAP_STATUS_ATT_UIDVALIDITY;
	if ([name isEqualToString:@"UNSEEN"]) return MAILIMAP_STATUS_ATT_UNSEEN;
	@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_STATUS_FOUND userInfo:nil];
}

- (NSDictionary*)createStatus:(struct mailimap_mailbox_data_status*)status {
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
	clistiter* iter;
	for (iter = clist_begin(status->st_info_list); iter != NULL; iter = clist_next(iter)) {
		struct mailimap_status_info* info = clist_content(iter);
		NSString* key = nil;
		switch (info->st_att) {
			case MAILIMAP_STATUS_ATT_MESSAGES:
				key = @"MESSAGES";
				break;
			case MAILIMAP_STATUS_ATT_RECENT:
				key = @"RECENT";
				break;
			case MAILIMAP_STATUS_ATT_UIDNEXT:
				key = @"UIDNEXT";
				break;
			case MAILIMAP_STATUS_ATT_UIDVALIDITY:
				key = @"UIDVALIDITY";
				break;
			case MAILIMAP_STATUS_ATT_UNSEEN:
				key = @"UNSEEN";
				break;
			default:
				@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_STATUS_FOUND userInfo:nil];
				break;
		}
		[dictionary setValue:[NSNumber numberWithUnsignedInt:info->st_value] forKey:key];
	}
	return dictionary;
}

- (NSDictionary*)createQuotaRoot:(NSString*)mailbox result:(struct mailimap_quota_complete_data*)result {
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
	clistiter* iter;
	for (iter = clist_begin(result->quota_list); iter != NULL; iter = clist_next(iter)) {
		struct mailimap_quota_quota_data* quota = clist_content(iter);
		NSString* name = mailbox;
		if ([NSString isEmpty:mailbox]) name = @"ALL";
		[dictionary setValue:[self createQuota:quota] forKey:name];
	}
	return dictionary;
}

- (NSDictionary*)createQuota:(struct mailimap_quota_quota_data*)quota_data {
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
	clistiter* quotaIter;
	for (quotaIter = clist_begin(quota_data->quota_list); quotaIter != NULL; quotaIter = clist_next(quotaIter)) {
		struct mailimap_quota_quota_resource* resource = clist_content(quotaIter);
		NSMutableDictionary* capacity = [NSMutableDictionary dictionary];
		[capacity setValue:[NSNumber numberWithUnsignedInt:resource->usage] forKey:@"USAGE"];
		[capacity setValue:[NSNumber numberWithUnsignedInt:resource->limit] forKey:@"LIMIT"];
		NSString* name = [NSString stringWithCString:resource->resource_name encoding:NSUTF8StringEncoding];
		[dictionary setValue:capacity forKey:name];
	}
	return dictionary;
}

- (clist*)fetch:(struct mailimap_fetch_type*)fetch_type set:(struct mailimap_set*)set {
	assert(self.imap != NULL);
	if (!self.connected || !self.authorized || !self.selected)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_OPERATION userInfo:nil];
	clist* result = NULL;
	int retCode = mailimap_uid_fetch(self.imap, set, fetch_type, &result);
	if (retCode == MAILIMAP_NO_ERROR && result && !clist_isempty(result)) return result;
	return NULL;
}

- (NSData*)createMessageData:(struct mailimap_msg_att_item*)att_item {
	NSData *data= nil;
	if (att_item->att_type == MAILIMAP_MSG_ATT_ITEM_STATIC && att_item->att_data.att_static->att_type == MAILIMAP_MSG_ATT_RFC822) {
		char* text = att_item->att_data.att_static->att_data.att_rfc822.att_content;
		data = [NSData dataWithBytes:text length:strlen(text)];
	}
	return data;
}

- (NSData*)createHeaderData:(struct mailimap_msg_att_item*)att_item {
	NSData *data= nil;
	if (att_item->att_type == MAILIMAP_MSG_ATT_ITEM_STATIC && att_item->att_data.att_static->att_type == MAILIMAP_MSG_ATT_RFC822_HEADER) {
		char* text = att_item->att_data.att_static->att_data.att_rfc822_header.att_content;
		data = [NSData dataWithBytes:text length:strlen(text)];
	}
	return data;
}

- (NSUInteger)createSize:(struct mailimap_msg_att_item*)att_item {
	NSUInteger size = 0;
	if (att_item->att_type == MAILIMAP_MSG_ATT_ITEM_STATIC && att_item->att_data.att_static->att_type == MAILIMAP_MSG_ATT_RFC822_SIZE) {
		size = att_item->att_data.att_static->att_data.att_rfc822_size;
	}
	return size;
}

- (NSData*)createTextData:(struct mailimap_msg_att_item*)att_item {
	NSData *data= nil;
	if (att_item->att_type == MAILIMAP_MSG_ATT_ITEM_STATIC && att_item->att_data.att_static->att_type == MAILIMAP_MSG_ATT_RFC822_TEXT) {
		char* text = att_item->att_data.att_static->att_data.att_rfc822_text.att_content;
		data = [NSData dataWithBytes:text length:strlen(text)];
	}
	return data;
}

- (NSArray*)createFlags:(struct mailimap_msg_att_item*)att_item {
	if (att_item->att_type != MAILIMAP_MSG_ATT_ITEM_DYNAMIC) return nil;
	struct mailimap_msg_att_dynamic* att_dynamic = att_item->att_data.att_dyn;
	if (!att_dynamic->att_list) return nil;
	NSMutableArray*  flags = [NSMutableArray array];
	clistiter* iter;
	for (iter = clist_begin(att_dynamic->att_list); iter != NULL; iter = clist_next(iter)) {
		struct mailimap_flag_fetch* flag_fetch = iter->data;
		NSString* flag = [self createFlag:flag_fetch->fl_flag];
		[flags addObject:flag];
	}
	return flags;
}

- (NSString*)createFlag:(struct mailimap_flag*)fl_flag {
	switch (fl_flag->fl_type) {
		case MAILIMAP_FLAG_ANSWERED:
			return @"\\Answered";
		case MAILIMAP_FLAG_FLAGGED:
			return @"\\Flagged";
		case MAILIMAP_FLAG_DELETED:
			return @"\\Deleted";
		case MAILIMAP_FLAG_SEEN:
			return @"\\Seen";
		case MAILIMAP_FLAG_DRAFT:
			return @"\\Draft";
		case MAILIMAP_FLAG_KEYWORD:
			return [NSString stringWithFormat:@"\\Keyword - %s", fl_flag->fl_data.fl_keyword];
		case MAILIMAP_FLAG_EXTENSION:
			return [NSString stringWithFormat:@"\\Extension - %s", fl_flag->fl_data.fl_extension];
	}
	@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_STATUS_FOUND userInfo:nil];
}

- (NSUInteger)createUID:(struct mailimap_msg_att_item*)att_item {
	NSUInteger uid = 0u;
	if (att_item->att_type == MAILIMAP_MSG_ATT_ITEM_STATIC && att_item->att_data.att_static->att_type == MAILIMAP_MSG_ATT_UID) {
		uid = att_item->att_data.att_static->att_data.att_uid;
	}
	return uid;
}

- (NSData*)createMessageDataFromUID:(struct mailimap_msg_att*)msg_att {
	NSData *data = nil;
	clistiter* iter;
	for (iter = clist_begin(msg_att->att_list); iter != NULL; iter = clist_next(iter)) {
		struct mailimap_msg_att_item* att_item = iter->data;
		if (att_item->att_type == MAILIMAP_MSG_ATT_ITEM_STATIC && att_item->att_data.att_static->att_type == MAILIMAP_MSG_ATT_RFC822)
			data = [self createMessageData:att_item];
	}
	return data;
}

- (NSData*)createHeaderDataFromUID:(struct mailimap_msg_att*)msg_att {
	NSData *data= nil;
	clistiter* iter;
	for (iter = clist_begin(msg_att->att_list); iter != NULL; iter = clist_next(iter)) {
		struct mailimap_msg_att_item* att_item = iter->data;
		if (att_item->att_type == MAILIMAP_MSG_ATT_ITEM_STATIC && att_item->att_data.att_static->att_type == MAILIMAP_MSG_ATT_RFC822_HEADER)
			data = [self createHeaderData:att_item];
	}
	return data;
}

- (NSUInteger)createSizeFromUID:(struct mailimap_msg_att*)msg_att {
	NSUInteger size = 0;
	clistiter* iter;
	for (iter = clist_begin(msg_att->att_list); iter != NULL; iter = clist_next(iter)) {
		struct mailimap_msg_att_item* att_item = iter->data;
		if (att_item->att_type == MAILIMAP_MSG_ATT_ITEM_STATIC && att_item->att_data.att_static->att_type == MAILIMAP_MSG_ATT_RFC822_SIZE)
			size = [self createSize:att_item]; 
	}
	return size;
}

- (NSData*)createTextDataFromUID:(struct mailimap_msg_att*)msg_att {
	NSData *data = nil;
	clistiter* iter;
	for (iter = clist_begin(msg_att->att_list); iter != NULL; iter = clist_next(iter)) {
		struct mailimap_msg_att_item* att_item = iter->data;
		if (att_item->att_type == MAILIMAP_MSG_ATT_ITEM_STATIC && att_item->att_data.att_static->att_type == MAILIMAP_MSG_ATT_RFC822_TEXT)
			data = [self createTextData:att_item];
	}
	return data;
}

- (NSArray*)createFlagsFromUID:(struct mailimap_msg_att*)msg_att {
	NSArray* flags = nil;
	clistiter* iter;
	for (iter = clist_begin(msg_att->att_list); iter != NULL; iter = clist_next(iter)) {
		struct mailimap_msg_att_item* att_item = iter->data;
		if (att_item->att_type == MAILIMAP_MSG_ATT_ITEM_DYNAMIC)
			flags = [self createFlags:att_item];
	}
	return flags;
}

- (NSUInteger)createUIDFromUID:(struct mailimap_msg_att*)msg_att {
	NSUInteger uid = 0u;
	clistiter* iter;
	for (iter = clist_begin(msg_att->att_list); iter != NULL; iter = clist_next(iter)) {
		struct mailimap_msg_att_item* att_item = iter->data;
		if (att_item->att_type == MAILIMAP_MSG_ATT_ITEM_STATIC && att_item->att_data.att_static->att_type == MAILIMAP_MSG_ATT_UID)
			uid = [self createUID:att_item];
	}
	return uid;
}

- (uint32_t)createFLFlags:(ImapStoreFlag)flag {
	switch (flag) {
		case NEW:
			return MAIL_FLAG_NEW;
		case SEEN:
			return MAIL_FLAG_SEEN;
		case FLAGGED:
			return MAIL_FLAG_FLAGGED;
		case DELETED:
			return MAIL_FLAG_DELETED;
		case ANSWERED:
			return MAIL_FLAG_ANSWERED;
		case FORWARDED:
			return MAIL_FLAG_FORWARDED;
		case CANCELED:
			return MAIL_FLAG_CANCELLED;
	}
	@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_STATUS_FOUND userInfo:nil];
}

- (struct mailimap_store_att_flags*)createMailFlags:(ImapStoreFlag)flag enable:(BOOL)enable silent:(BOOL)silent {
	struct mailimap_flag_list* flag_list = mailimap_flag_list_new_empty();
	struct mail_flags* flags = mail_flags_new_empty();
	flags->fl_flags = [self createFLFlags:flag];
	if ((imap_flags_to_imap_flags(flags, &flag_list)) != MAILIMAP_NO_ERROR)
		@throw [NSError errorWithDomain:@"IMAP ERROR" code:ILLEGAL_STATUS_FOUND userInfo:nil];;
	struct mailimap_store_att_flags* att_flags = mailimap_store_att_flags_new_set_flags(flag_list);
	att_flags->fl_sign = (enable) ? 1 : -1;
	att_flags->fl_silent = silent;
	return att_flags;
}

- (NSArray*)createSearchResults:(const char*)charset key:(struct mailimap_search_key*)key {
	clist* result = NULL;
	int retCode = mailimap_search(self.imap, charset, key, &result);
	if (retCode != MAILIMAP_NO_ERROR) return nil;
	return [self createNumbers:result];
}
	
- (NSArray*)createUIDSearchResults:(const char*)charset key:(struct mailimap_search_key*)key {
	clist* result = NULL;
	int retCode = mailimap_uid_search(self.imap, charset, key, &result);
	if (retCode != MAILIMAP_NO_ERROR) return nil;
	return [self createNumbers: result];
}

- (NSArray*)createNumbers:(clist*)result {
	NSMutableArray* array = [NSMutableArray array];
	clistiter* iter;
	for (iter = clist_begin(result); iter != NULL; iter = clist_next(iter)) {
		uint32_t* index = iter->data;
		if (index) [array addObject:[NSNumber numberWithUnsignedInt:*index]];
	}
	return array;
}

- (NSArray*)createMessages:(int)retCode result:(clist*)result {
	if (retCode != MAILIMAP_NO_ERROR || !result && clist_isempty(result)) return nil;
	
	NSMutableArray* array = [NSMutableArray array];
	clistiter* iter;
	for (iter = clist_begin(result); iter != NULL; iter = clist_next(iter)) {
		struct mailimap_msg_att* msg_att = iter->data;
		struct mailimap_msg_att_item* att_item = clist_begin(msg_att->att_list)->data;
		NSData* data = [self createMessageData:att_item];
		if (data) [array addObject:data];
	}
	return array;
}

- (NSArray*)createHeaders:(int)retCode result:(clist*)result {
	if (retCode != MAILIMAP_NO_ERROR || !result && clist_isempty(result)) return nil;
	
	NSMutableArray* array = [NSMutableArray array];
	clistiter* iter;
	for (iter = clist_begin(result); iter != NULL; iter = clist_next(iter)) {
		struct mailimap_msg_att* msg_att = iter->data;
		struct mailimap_msg_att_item* att_item = clist_begin(msg_att->att_list)->data;
		NSData* data = [self createHeaderData:att_item];
		if (data) [array addObject:data];
	}
	return array;
}

- (NSArray*)createSizes:(int)retCode result:(clist*)result {
	if (retCode != MAILIMAP_NO_ERROR || !result && clist_isempty(result)) return nil;
	
	NSMutableArray* array = [NSMutableArray array];
	clistiter* iter;
	for (iter = clist_begin(result); iter != NULL; iter = clist_next(iter)) {
		struct mailimap_msg_att* msg_att = iter->data;
		struct mailimap_msg_att_item* att_item = clist_begin(msg_att->att_list)->data;
		NSUInteger size = [self createSize:att_item];
		if (size > 0) {
			NSNumber* number = [NSNumber numberWithUnsignedInteger:size];
			[array addObject:number];
		}
	}
	return array;
}

- (NSArray*)createTexts:(int)retCode result:(clist*)result {
	if (retCode != MAILIMAP_NO_ERROR || !result && clist_isempty(result)) return nil;
	
	NSMutableArray* array = [NSMutableArray array];
	clistiter* iter;
	for (iter = clist_begin(result); iter != NULL; iter = clist_next(iter)) {
		struct mailimap_msg_att* msg_att = iter->data;
		struct mailimap_msg_att_item* att_item = clist_begin(msg_att->att_list)->data;
		NSData* data = [self createTextData:att_item];
		if (data) [array addObject:data];
	}
	return array;
}

- (NSArray*)createFlagsArray:(int)retCode result:(clist*)result {
	if (retCode != MAILIMAP_NO_ERROR || !result && clist_isempty(result)) return nil;
	
	NSMutableArray* array = [NSMutableArray array];
	clistiter* iter;
	for (iter = clist_begin(result); iter != NULL; iter = clist_next(iter)) {
		struct mailimap_msg_att* msg_att = iter->data;
		struct mailimap_msg_att_item* att_item = clist_begin(msg_att->att_list)->data;
		NSArray* flags = [self createFlags:att_item];
		if (flags) [array addObject:flags];
	}
	return array;
}

- (NSArray*)createUIDs:(int)retCode result:(clist*)result {
	if (retCode != MAILIMAP_NO_ERROR || !result && clist_isempty(result)) return nil;
	
	NSMutableArray* array = [NSMutableArray array];
	clistiter* iter;
	for (iter = clist_begin(result); iter != NULL; iter = clist_next(iter)) {
		struct mailimap_msg_att* msg_att = iter->data;
		struct mailimap_msg_att_item* att_item = clist_begin(msg_att->att_list)->data;
		NSUInteger uid = [self createUID:att_item];
		if (uid > 0) {
			NSNumber* number = [NSNumber numberWithUnsignedInteger:uid];
			[array addObject:number];
		}
	}
	return array;
}

- (NSArray*)createMessagesFromUID:(int)retCode result:(clist*)result {
	if (retCode != MAILIMAP_NO_ERROR || !result && clist_isempty(result)) return nil;
	
	NSMutableArray* array = [NSMutableArray array];
	clistiter* iter;
	for (iter = clist_begin(result); iter != NULL; iter = clist_next(iter)) {
		struct mailimap_msg_att* msg_att = iter->data;
		NSData* data = [self createMessageDataFromUID:msg_att];
		if (data) [array addObject:data];
	}
	return array;
}

- (NSArray*)createHeadersFromUID:(int)retCode result:(clist*)result {
	if (retCode != MAILIMAP_NO_ERROR || !result && clist_isempty(result)) return nil;
	
	NSMutableArray* array = [NSMutableArray array];
	clistiter* iter;
	for (iter = clist_begin(result); iter != NULL; iter = clist_next(iter)) {
		struct mailimap_msg_att* msg_att = iter->data;
		NSData* data = [self createHeaderDataFromUID:msg_att];
		if (data) [array addObject:data];
	}
	return array;
}

- (NSArray*)createSizesFromUID:(int)retCode result:(clist*)result {
	if (retCode != MAILIMAP_NO_ERROR || !result && clist_isempty(result)) return nil;
	
	NSMutableArray* array = [NSMutableArray array];
	clistiter* iter;
	for (iter = clist_begin(result); iter != NULL; iter = clist_next(iter)) {
		struct mailimap_msg_att* msg_att = iter->data;
		NSUInteger uid = [self createSizeFromUID:msg_att];
		if (uid> 0) {
			NSNumber* number = [NSNumber numberWithUnsignedInteger:uid];
			[array addObject:number];
		}
	}
	return array;
}

- (NSArray*)createTextsFromUID:(int)retCode result:(clist*)result {
	if (retCode != MAILIMAP_NO_ERROR || !result && clist_isempty(result)) return nil;
	
	NSMutableArray* array = [NSMutableArray array];
	clistiter* iter;
	for (iter = clist_begin(result); iter != NULL; iter = clist_next(iter)) {
		struct mailimap_msg_att* msg_att = iter->data;
		NSData* data = [self createTextDataFromUID:msg_att];
		if (data) [array addObject:data];
	}
	return array;
}

- (NSArray*)createFlagsArrayFromUID:(int)retCode result:(clist*)result {
	if (retCode != MAILIMAP_NO_ERROR || !result && clist_isempty(result)) return nil;
	
	NSMutableArray* array = [NSMutableArray array];
	clistiter* iter;
	for (iter = clist_begin(result); iter != NULL; iter = clist_next(iter)) {
		struct mailimap_msg_att* msg_att = iter->data;
		NSArray* flags = [self createFlagsFromUID:msg_att];
		if (flags) [array addObject:flags];
	}
	return array;
}

- (NSArray*)createUIDsFromUID:(int)retCode result:(clist*)result {
	if (retCode != MAILIMAP_NO_ERROR || !result && clist_isempty(result)) return nil;
	
	NSMutableArray* array = [NSMutableArray array];
	clistiter* iter;
	for (iter = clist_begin(result); iter != NULL; iter = clist_next(iter)) {
		struct mailimap_msg_att* msg_att = iter->data;
		NSUInteger uid = [self createUIDFromUID:msg_att];
		if (uid > 0) {
			NSNumber* number = [NSNumber numberWithUnsignedInteger:uid];
			[array addObject:number];
		}
	}
	return array;
}

- (struct mailimap_search_key*)createSeenSearchKey:(BOOL)checked {
	if (checked) return mailimap_search_key_new(MAILIMAP_SEARCH_KEY_SEEN, NULL, NULL, NULL, NULL, NULL,
												NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0,
												NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL);
	return mailimap_search_key_new(MAILIMAP_SEARCH_KEY_UNSEEN, NULL, NULL, NULL, NULL, NULL,
								   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0,
								   NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL);
}

- (struct mailimap_search_key*)createAnsweredSearchKey:(BOOL)checked {
	if (checked) return mailimap_search_key_new(MAILIMAP_SEARCH_KEY_ANSWERED, NULL, NULL, NULL, NULL, NULL,
												NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0,
												NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL);
	return mailimap_search_key_new(MAILIMAP_SEARCH_KEY_UNANSWERED, NULL, NULL, NULL, NULL, NULL,
								   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0,
								   NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL);
}

- (struct mailimap_search_key*)createDeletedSearchKey:(BOOL)checked {
	if (checked) return mailimap_search_key_new(MAILIMAP_SEARCH_KEY_DELETED, NULL, NULL, NULL, NULL, NULL,
												NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0,
												NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL);
	return mailimap_search_key_new(MAILIMAP_SEARCH_KEY_UNDELETED, NULL, NULL, NULL, NULL, NULL,
								   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0,
								   NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL);
}

- (struct mailimap_search_key*)createFlaggedSearchKey:(BOOL)checked {
	if (checked) return mailimap_search_key_new(MAILIMAP_SEARCH_KEY_FLAGGED, NULL, NULL, NULL, NULL, NULL,
												NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0,
												NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL);
	return mailimap_search_key_new(MAILIMAP_SEARCH_KEY_UNFLAGGED, NULL, NULL, NULL, NULL, NULL,
								   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0,
								   NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL);
}

- (struct mailimap_search_key*)createKeywordSearchKey:(BOOL)checked keyword:(NSString*)keyword {
	if (checked) return mailimap_search_key_new_keyword([MailUtil createCharStream:keyword]);
	return mailimap_search_key_new_unkeyword([MailUtil createCharStream:keyword]);
}

- (struct mailimap_search_key*)createRecentSearchKey {
	return mailimap_search_key_new(MAILIMAP_SEARCH_KEY_RECENT, NULL, NULL, NULL, NULL, NULL,
								   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0,
								   NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL);
}

- (struct mailimap_search_key*)createDraftSearchKey {
	return mailimap_search_key_new(MAILIMAP_SEARCH_KEY_DRAFT, NULL, NULL, NULL, NULL, NULL,
								   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0,
								   NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL);
}

@end
