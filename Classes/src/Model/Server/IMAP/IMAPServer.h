//
//  IMAPServer.h
//  OCMail
//
//  Created by Miyabi Kazamatsuri on 11/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MailServer.h"

typedef enum {
	SELECT = 0,
	EXAMINE,
	CREATE,
	DELETE,
	SUBSCRIBE,
	UNSUBSCRIBE,
} ImapOperation;

typedef enum {
	NEW = 0,
	SEEN,
	FLAGGED,
	DELETED,
	ANSWERED,
	FORWARDED,
	CANCELED,
} ImapStoreFlag;

@interface IMAPServer : MailServer {
@private
	mailimap* imap_;
	BOOL selected_;
	BOOL idle_;
}

@property (nonatomic, assign) mailimap* imap;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL idle;

- (id)initWithResource:(mailimap*)imap;

- (NSArray*)capability;

- (NSArray*)allFolders;
- (NSArray*)subscribedFolders;

- (NSInteger)select:(NSString*)mailbox;
- (NSInteger)examine:(NSString*)mailbox;

- (NSInteger)create:(NSString*)mailbox;
- (NSInteger)delete:(NSString*)mailbox;

- (NSInteger)subscribe:(NSString*)mailbox;
- (NSInteger)unsubscribe:(NSString*)mailbox;

- (NSInteger)rename:(NSString*)oldName newName:(NSString*)newName;

- (NSDictionary*)status:(NSString*)mailbox infos:(NSArray*)infos;
- (NSDictionary*)allStatus:(NSString*)mailbox;

- (NSInteger)check;

- (NSInteger)close;

- (NSInteger)startIdle;
- (NSInteger)endIdle;

- (NSDictionary*)getQuotaRoot:(NSString*)mailbox;
- (NSDictionary*)getQuotaRoot;

- (NSInteger)append:(NSData*)message mailbox:(NSString*)mailbox;

- (NSData*)fetchMessage:(NSUInteger)index;
- (NSData*)fetchHeader:(NSUInteger)index;
- (NSNumber*)fetchSize:(NSUInteger)index;
- (NSData*)fetchText:(NSUInteger)index;
- (NSArray*)fetchFlags:(NSUInteger)index;
- (NSNumber*)fetchUID:(NSUInteger)index;

- (NSData*)fetchMessageWithUID:(NSUInteger)uid;
- (NSData*)fetchHeaderWithUID:(NSUInteger)uid;
- (NSNumber*)fetchSizeWithUID:(NSUInteger)uid;
- (NSData*)fetchTextWithUID:(NSUInteger)uid;
- (NSArray*)fetchFlagsWithUID:(NSUInteger)uid;
- (NSNumber*)fetchUIDWithUID:(NSUInteger)uid;

- (NSArray*)fetchMessagesWithRange:(NSRange)range;
- (NSArray*)fetchHeadersWithRange:(NSRange)range;
- (NSArray*)fetchSizesWithRange:(NSRange)range;
- (NSArray*)fetchTextsWithRange:(NSRange)range;
- (NSArray*)fetchFlagsWithRange:(NSRange)range;
- (NSArray*)fetchUIDsWithRange:(NSRange)range;

- (NSArray*)fetchMessagesWithUIDRange:(NSRange)range;
- (NSArray*)fetchHeadersWithUIDRange:(NSRange)range;
- (NSArray*)fetchSizesWithUIDRange:(NSRange)range;
- (NSArray*)fetchTextsWithUIDRange:(NSRange)range;
- (NSArray*)fetchFlagsWithUIDRange:(NSRange)range;
- (NSArray*)fetchUIDsWithUIDRange:(NSRange)range;

- (NSInteger)store:(NSUInteger)index flag:(ImapStoreFlag)flag enable:(BOOL)enable silent:(BOOL)silent;
- (NSInteger)storeWithRange:(NSRange)range flag:(ImapStoreFlag)flag enable:(BOOL)enable silent:(BOOL)silent;
- (NSInteger)storeWithUID:(NSUInteger)uid flag:(ImapStoreFlag)flag enable:(BOOL)enable silent:(BOOL)silent;
- (NSInteger)storeWithUIDRange:(NSRange)range flag:(ImapStoreFlag)flag enable:(BOOL)enable silent:(BOOL)silent;

- (NSInteger)copy:(NSUInteger)index mailbox:(NSString*)mailbox;
- (NSInteger)copyWithRange:(NSRange)range mailbox:(NSString*)mailbox;
- (NSInteger)copyWithUID:(NSUInteger)uid mailbox:(NSString*)mailbox;
- (NSInteger)copyWithUIDRange:(NSRange)range mailbox:(NSString*)mailbox;

- (NSInteger)expunge;
- (NSInteger)expungeWithUIDRange:(NSRange)range;

- (NSArray*)searchAll;
- (NSArray*)searchSeen:(BOOL)checked;
- (NSArray*)searchAnswered:(BOOL)checked;
- (NSArray*)searchDeleted:(BOOL)checked;
- (NSArray*)searchFlagged:(BOOL)checked;
- (NSArray*)searchKeyword:(BOOL)checked keyword:(NSString*)keyword;
- (NSArray*)searchRecent;
- (NSArray*)searchDraft;
- (NSArray*)searchFrom:(NSString*)field;
- (NSArray*)searchTo:(NSString*)field;
- (NSArray*)searchCc:(NSString*)field;
- (NSArray*)searchSubject:(NSString*)field;
- (NSArray*)searchHeader:(NSString*)header field:(NSString*)field;
- (NSArray*)searchUID:(NSUInteger)uid;
- (NSArray*)searchText:(NSString*)field;

- (NSArray*)uidSearchAll;
- (NSArray*)uidSearchSeen:(BOOL)checked;
- (NSArray*)uidSearchAnswered:(BOOL)checked;
- (NSArray*)uidSearchDeleted:(BOOL)checked;
- (NSArray*)uidSearchFlagged:(BOOL)checked;
- (NSArray*)uidSearchKeyword:(BOOL)checked keyword:(NSString*)keyword;
- (NSArray*)uidSearchRecent;
- (NSArray*)uidSearchDraft;

- (NSArray*)uidSearchFrom:(NSString*)field;
- (NSArray*)uidSearchTo:(NSString*)field;
- (NSArray*)uidSearchCc:(NSString*)field;
- (NSArray*)uidSearchSubject:(NSString*)field;
- (NSArray*)uidSearchHeader:(NSString*)header field:(NSString*)field;
- (NSArray*)uidSearchUID:(NSUInteger)uid;
- (NSArray*)uidSearchText:(NSString*)field;


@end
