//
//  HeyloData.h
//  notify
//
//  Created by Scott Parris on 3/30/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SQLITE_OK           0   /* Successful result */
/* beginning-of-error-codes */
#define SQLITE_ERROR        1   /* SQL error or missing database */
#define SQLITE_INTERNAL     2   /* Internal logic error in SQLite */
#define SQLITE_PERM         3   /* Access permission denied */
#define SQLITE_ABORT        4   /* Callback routine requested an abort */
#define SQLITE_BUSY         5   /* The database file is locked */
#define SQLITE_LOCKED       6   /* A table in the database is locked */
#define SQLITE_NOMEM        7   /* A malloc() failed */
#define SQLITE_READONLY     8   /* Attempt to write a readonly database */
#define SQLITE_INTERRUPT    9   /* Operation terminated by sqlite3_interrupt()*/
#define SQLITE_IOERR       10   /* Some kind of disk I/O error occurred */
#define SQLITE_CORRUPT     11   /* The database disk image is malformed */
#define SQLITE_NOTFOUND    12   /* Unknown opcode in sqlite3_file_control() */
#define SQLITE_FULL        13   /* Insertion failed because database is full */
#define SQLITE_CANTOPEN    14   /* Unable to open the database file */
#define SQLITE_PROTOCOL    15   /* Database lock protocol error */
#define SQLITE_EMPTY       16   /* Database is empty */
#define SQLITE_SCHEMA      17   /* The database schema changed */
#define SQLITE_TOOBIG      18   /* String or BLOB exceeds size limit */
#define SQLITE_CONSTRAINT  19   /* Abort due to constraint violation */
#define SQLITE_MISMATCH    20   /* Data type mismatch */
#define SQLITE_MISUSE      21   /* Library used incorrectly */
#define SQLITE_NOLFS       22   /* Uses OS features not supported on host */
#define SQLITE_AUTH        23   /* Authorization denied */
#define SQLITE_FORMAT      24   /* Auxiliary database format error */
#define SQLITE_RANGE       25   /* 2nd parameter to sqlite3_bind out of range */
#define SQLITE_NOTADB      26   /* File opened that is not a database file */
#define SQLITE_NOTICE      27   /* Notifications from sqlite3_log() */
#define SQLITE_WARNING     28   /* Warnings from sqlite3_log() */
#define SQLITE_ROW         100  /* sqlite3_step() has another row ready */
#define SQLITE_DONE        101  /* sqlite3_step() has finished executing */
/* end-of-error-codes */

@class AppDelegate;
@class Contact;
@class Conversation;
@class Message;
@class User;

@interface HeyloData : NSObject {
    AppDelegate *appDelegate;
}

@property (strong, nonatomic) NSString *dbFilePath;
@property (strong, nonatomic) NSNumber *maxConverstionId;
@property (strong, nonatomic) NSNumber *maxContactId;
@property (strong, nonatomic) NSNumber *maxMessageId;

// Retrieve objects
+ (NSArray *)getContacts;
+ (NSArray *)getConversations;
+ (NSArray *)getMessagesForConversation:(Conversation *)_conversation;
+ (NSDictionary *)getUser;
+ (Contact *)getContactByHeyloId:(NSString *)_hid;
+ (Contact *)getContactByPhone:(NSString *)_phone;
+ (NSDictionary *)lastMessageFromConversation:(Conversation *)_conversation;
+ (NSNumber *)getLastMessageTime;
+ (Conversation *)getConversationFromThread:(NSString *)thread;
+ (NSNumber *)unreadMessageCount;

// Create objects
+ (BOOL)createContact:(Contact *)_contact;
+ (BOOL)createConversation:(Conversation *)_conversation;
+ (BOOL)createMessage:(Message *)_message;
+ (BOOL)createUser:(User *)user;

// Update objects
+ (BOOL)updateConversation:(Conversation *)_conversation;
+ (BOOL)updateContact:(Contact *)_contact;
+ (BOOL)updateUser:(User *)user;

// Destroy objects
+ (BOOL)destroyConversationWithId:(NSNumber *)_id;
+ (BOOL)destroyMessagesWithConversationId:(NSNumber *)_id;
+ (BOOL)destroyContactWithId:(NSNumber *)_id;
+ (BOOL)destroyMessageWithId:(NSNumber *)_id;

// Supporting methods
+ (NSArray *)getContactsFromThread:(NSString *)_thread;
+ (NSString *)getThreadFromContacts:(NSArray *)_contacts;
+ (NSNumber *)getTimestamp;
+ (NSString *)escapeString:(NSString *)aString;

// Values retained in appDelegate.heyloData
- (id)initializeData;
- (NSNumber *)setMaxContactId;
- (NSNumber *)setMaxConversationId;
- (NSNumber *)setMaxMessageId;

// To reset for demo
+ (BOOL)clearContacts;
+ (BOOL)clearConversations;
+ (BOOL)clearMessages;

@end
