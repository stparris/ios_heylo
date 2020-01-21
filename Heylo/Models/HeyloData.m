//
//  HeyloData.m
//  notify
//
//  Created by Scott Parris on 3/30/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import "HeyloData.h"
#import "AppDelegate.h"
#import "Contact.h"
#import "Country.h"
#import "Conversation.h"
#import "Message.h"
#import "User.h"
#include <sqlite3.h>

@implementation HeyloData

- (id)initializeData {
    BOOL success;
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolderPath = [searchPaths objectAtIndex: 0];
    self.dbFilePath = [documentFolderPath stringByAppendingPathComponent:DATABASE_FILE_NAME];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath: self.dbFilePath]) {
        NSString *backupDbPath = [[NSBundle mainBundle]
                                  pathForResource:DATABASE_RESOURCE_NAME
                                  ofType:DATABASE_RESOURCE_TYPE];
        if (backupDbPath == nil) {
            // couldn't find backup db to copy, bail
            success = NO;
        } else {
            BOOL copiedBackupDb = [[NSFileManager defaultManager]
                                   copyItemAtPath:backupDbPath
                                   toPath:self.dbFilePath
                                   error:nil];
            if (copiedBackupDb) {
                success = YES;
            } else {
                success = NO;
            }
        }
    } else {
        success = YES;
    }
    if (success == YES) {
        self.maxConverstionId = [[NSNumber alloc] initWithInt:[self maxIdFor:@"conversations"]];
        self.maxMessageId = [[NSNumber alloc] initWithInt:[self maxIdFor:@"messages"]];
        int maxid = [self maxIdFor:@"contacts"] ? [self maxIdFor:@"contacts"] : 1;
        self.maxContactId = [[NSNumber alloc] initWithInt:maxid];
    }
    return self;
}

- (BOOL)execSQLwith:(NSString *)_sql_stmt
{
    BOOL success = NO;
    sqlite3 *db;

    int dbrc; // database return code
    const char* dbFilePathUTF8 = [self.dbFilePath UTF8String];
    dbrc = sqlite3_open (dbFilePathUTF8, &db);
    if (dbrc) {
        NSLog(@"Cannot connect to you device's database.");
    }
    
    sqlite3_stmt *dbps;
    const char *sqlStatement = [_sql_stmt UTF8String];
    dbrc = sqlite3_prepare_v2 (db, sqlStatement, -1, &dbps, NULL);
    if (dbrc != SQLITE_OK) {
        NSLog(@"Failed sql prepare with code %i stmt was %@ error: %s", dbrc, _sql_stmt, sqlite3_errmsg(db));
    }
    dbrc = sqlite3_step (dbps);
    sqlite3_finalize (dbps);
    sqlite3_close(db);
    
    if (dbrc != SQLITE_DONE) {
        NSLog(@"Failed with code %i stmt was %@ error: %s", dbrc, _sql_stmt, sqlite3_errmsg(db));
    } else {
        success = YES;
    }
    return success;
}

- (int)maxIdFor:(NSString *)_table
{
    int maxId = 1;
    sqlite3 *db;
    int dbrc; // database return code
    const char* dbFilePathUTF8 = [self.dbFilePath UTF8String];
    dbrc = sqlite3_open (dbFilePathUTF8, &db);
    sqlite3_stmt *dbps;
    NSString *queryStatementNS = [NSString stringWithFormat:@"select max(id) from \"%@\"", _table];
    const char *sqlStatement = [queryStatementNS UTF8String];
    dbrc = sqlite3_prepare_v2 (db, sqlStatement, -1, &dbps, NULL);
    while ((dbrc = sqlite3_step (dbps)) == SQLITE_ROW) {
        maxId = sqlite3_column_int(dbps, 0);
    }
    sqlite3_finalize (dbps);
    sqlite3_close(db);
    
    return maxId;
}

- (NSNumber *)setMaxContactId
{
    int value = [self.maxContactId intValue];
    self.maxContactId = [NSNumber numberWithInt:value + 1];
    return self.maxContactId;
}

- (NSNumber *)setMaxConversationId
{
    int value = [self.maxConverstionId intValue];
    self.maxConverstionId = [NSNumber numberWithInt:value + 1];
    return self.maxConverstionId;
}

- (NSNumber *)setMaxMessageId
{
    int value = [self.maxMessageId intValue];
    self.maxMessageId = [NSNumber numberWithInt:value + 1];
    return self.maxMessageId;
}

+ (NSNumber *)getTimestamp
{
    return [NSNumber numberWithInt:(int)[[NSDate date]timeIntervalSince1970]];
}

// Convesations
+ (NSArray *)getConversations
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray *conversations = [[NSMutableArray alloc] init];
    NSString *sqlstr = [NSString stringWithFormat:@"select * from conversations order by modified_date DESC"];
    sqlite3 *db;
    int dbrc; // database return code
    const char* dbFilePathUTF8 = [appDelegate.heyloData.dbFilePath UTF8String];
    dbrc = sqlite3_open (dbFilePathUTF8, &db);
    sqlite3_stmt *dbps;
    const char *sqlStatement = [sqlstr UTF8String];
    if (dbrc != SQLITE_OK) {
        NSLog(@"Failed sql prepare with code %i error: %s", dbrc, sqlite3_errmsg(db));
    }
    dbrc = sqlite3_prepare_v2 (db, sqlStatement, -1, &dbps, NULL);
    while ((dbrc = sqlite3_step (dbps)) == SQLITE_ROW) {
        int i = sqlite3_column_int(dbps, 0);
        NSNumber *cid = [[NSNumber alloc] initWithInt:i];
        NSString *thread = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 1)];
        NSString *contactStr = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 2)];
        i = sqlite3_column_int(dbps, 3);
        NSNumber *read = [[NSNumber alloc] initWithInt:i];
        NSString *url = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 4)];
        int m = sqlite3_column_int(dbps, 5);
        NSNumber *mdate = [NSNumber numberWithInt:m];
        int c = sqlite3_column_int(dbps, 6);
        NSNumber *cdate = [[NSNumber alloc] initWithInt:c];
        Conversation *conv = [[Conversation alloc] initWithId:cid andThread:thread andContactString:contactStr
                andReadFlag:read andImageUrl:url modifiedDate:mdate createdDate:cdate];
        [conversations addObject:conv];
    }
    sqlite3_finalize (dbps);
    sqlite3_close(db);

    
    return conversations;
}

+ (BOOL)createConversation:(Conversation *)conversation
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *sqlstr = [NSString stringWithFormat:
                        @"insert into conversations (id,thread,contact_string,read,image_url,modified_date,created_date) values (%@,\"%@\",\"%@\",%@,\"%@\",%@,%@)",
                        conversation.conversationId,conversation.thread,conversation.contactString,conversation.readFlag,conversation.imageUrl,conversation.modifiedDate,conversation.createdDate];
    // NSLog(@"sql %@", sqlstr);
    return [appDelegate.heyloData execSQLwith:sqlstr];
}

+ (BOOL)updateConversation:(Conversation *)_conversation
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Conversation *conversation = _conversation;
    NSString *sqlstr = [NSString stringWithFormat:
                        @"update conversations set read=%@, image_url=\"%@\", modified_date=%@ where id=%@",
                        conversation.readFlag, conversation.imageUrl,conversation.modifiedDate,conversation.conversationId];
    return [appDelegate.heyloData execSQLwith:sqlstr];
}

+ (BOOL)destroyConversationWithId:(NSNumber *)_id
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *sqlstr = [NSString stringWithFormat:@"delete from conversations where id = %@", _id];
    return [appDelegate.heyloData execSQLwith:sqlstr];
}

+ (BOOL)destroyMessagesWithConversationId:(NSNumber *)_id
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *sqlstr = [NSString stringWithFormat:@"delete from messages where conversation_id = %@", _id];
    return [appDelegate.heyloData execSQLwith:sqlstr];
}


// Messages
+ (NSArray *)getMessagesForConversation:(Conversation *)conversation
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    NSString *sqlstr = [NSString stringWithFormat:@"select * from messages where conversation_id = %@ order by created_date ASC", conversation.conversationId];
    sqlite3 *db;
    int dbrc; // database return code
    const char* dbFilePathUTF8 = [appDelegate.heyloData.dbFilePath UTF8String];
    dbrc = sqlite3_open (dbFilePathUTF8, &db);
    sqlite3_stmt *dbps;
    const char *sqlStatement = [sqlstr UTF8String];
    dbrc = sqlite3_prepare_v2 (db, sqlStatement, -1, &dbps, NULL);
    while ((dbrc = sqlite3_step (dbps)) == SQLITE_ROW) {
        int i = sqlite3_column_int(dbps, 0);
        NSNumber *mid = [[NSNumber alloc] initWithInt:i];
        NSString *contactId = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 2)];
        Contact *contact = [HeyloData getContactByHeyloId:contactId];
        if (!contact) {
            NSArray *hids = [conversation.thread componentsSeparatedByString:@","];
            NSArray *names = [conversation.contactString componentsSeparatedByString:@","];
            int i = 0;
            for (NSString *hid in hids) {
                if ([hid isEqualToString:contactId]) {
                    contact = [[Contact alloc] initWithId:[NSNumber numberWithInt:99999]
                                                 abRecord:[NSNumber numberWithInt:99999]
                                                  heyloId:hid
                                              phoneNumber:@""
                                                firstName:[names objectAtIndex:i]
                                                 lastName:@""
                                                   avatar:@"default_avatar"
                                             activityDate:[NSNumber numberWithInt:99999]
                                              createdDate:[NSNumber numberWithInt:99999]];
                }
                i++;
            }
        }
        NSString *imageUrl = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 3)];
        NSString *message = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 4)];
        int d = sqlite3_column_int(dbps, 5);
        NSNumber *cdate = [[NSNumber alloc] initWithInt:d];
        // NSLog(@"msg %@ date retrieved as %@", message, cdate);
        Message *msg = [[Message alloc] initWithId:mid andConversation:conversation andContact:contact andImageUrl:imageUrl andMessage:message andDate:cdate];
        // NSLog(@"c %@ m %@", contact.firstName, message);
        [messages addObject:msg];
    }
    sqlite3_finalize (dbps);
    sqlite3_close(db);
    return messages;
}

+ (NSDictionary *)lastMessageFromConversation:(Conversation *)_conversation
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *sqlstr = [NSString stringWithFormat:@"select message from messages where conversation_id = %@ order by created_date ASC", _conversation.conversationId];
    sqlite3 *db;
    int dbrc; // database return code
    const char* dbFilePathUTF8 = [appDelegate.heyloData.dbFilePath UTF8String];
    dbrc = sqlite3_open (dbFilePathUTF8, &db);
    sqlite3_stmt *dbps;
    const char *sqlStatement = [sqlstr UTF8String];
    dbrc = sqlite3_prepare_v2 (db, sqlStatement, -1, &dbps, NULL);
    int i = 0;
    NSString *message = @"";
    while ((dbrc = sqlite3_step (dbps)) == SQLITE_ROW) {
        i++;
        message = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 0)];

    }
    sqlite3_finalize (dbps);
    sqlite3_close(db);
    NSDictionary *messageDic = [[NSDictionary alloc] initWithObjects:@[[NSNumber numberWithInt:i],message] forKeys:@[@"count",@"message"]];
    return messageDic;
}

+ (NSNumber *)getLastMessageTime
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    int maxId = 1;
    sqlite3 *db;
    int dbrc; // database return code
    const char* dbFilePathUTF8 = [appDelegate.heyloData.dbFilePath UTF8String];
    dbrc = sqlite3_open (dbFilePathUTF8, &db);
    sqlite3_stmt *dbps;
    NSString *queryStatementNS = @"select max(created_date) from messages";
    const char *sqlStatement = [queryStatementNS UTF8String];
    dbrc = sqlite3_prepare_v2 (db, sqlStatement, -1, &dbps, NULL);
    while ((dbrc = sqlite3_step (dbps)) == SQLITE_ROW) {
        maxId = sqlite3_column_int(dbps, 0);
    }
    sqlite3_finalize (dbps);
    sqlite3_close(db);
    
    return [NSNumber numberWithInt:maxId];
}

+ (NSNumber *)unreadMessageCount
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    sqlite3 *db;
    int dbrc; // database return code
    const char* dbFilePathUTF8 = [appDelegate.heyloData.dbFilePath UTF8String];
    dbrc = sqlite3_open (dbFilePathUTF8, &db);
    sqlite3_stmt *dbps;
    NSString *queryStatementNS = @"select readFlag from conversations";
    const char *sqlStatement = [queryStatementNS UTF8String];
    dbrc = sqlite3_prepare_v2 (db, sqlStatement, -1, &dbps, NULL);
    int count = 0;
    while ((dbrc = sqlite3_step (dbps)) == SQLITE_ROW) {
        int i = sqlite3_column_int(dbps, 0);
        count += i;
    }
    sqlite3_finalize (dbps);
    sqlite3_close(db);
    return [NSNumber numberWithInt:count];
}

+ (BOOL)createMessage:(Message *)_message
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Message *message = _message;
    NSString *text = [message.message stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *sqlstr = [NSString stringWithFormat:
                        @"insert into messages (id,conversation_id,from_id,image_url,message,created_date) values (%@,%@,'%@','%@','%@' ,%@)",
                        message.messageId, message.conversation.conversationId, message.contact.heyloId, message.imageUrl, text, message.createdDate];
    // NSLog(@"============================\n%@",sqlstr);
    return [appDelegate.heyloData execSQLwith:sqlstr];
}

+ (NSString *)escapeString:(NSString *)aString
{
    NSMutableString *returnString = [[NSMutableString alloc] init];
    
    for(int i = 0; i < [aString length]; i++) {
        
        unichar c = [aString characterAtIndex:i];
        
        // if char needs to be escaped
        if((('\\' == c) || ('\'' == c)) || ('"' == c)) {
            [returnString appendFormat:@"\\%c", c];
        } else {
            [returnString appendFormat:@"%c", c];
        }
    }
    
    return returnString;
}


+ (BOOL)destroyMessageWithId:(NSNumber *)_id
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *sqlstr = [NSString stringWithFormat:@"delete from messages where id = %@", _id];
    return [appDelegate.heyloData execSQLwith:sqlstr];
}

// Contacts

+ (NSArray *)getContacts
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    NSString *sqlstr = [NSString stringWithFormat:@"select * from contacts order by last_name, first_name DESC"];
    sqlite3 *db;
    int dbrc; // database return code
    const char* dbFilePathUTF8 = [appDelegate.heyloData.dbFilePath UTF8String];
    dbrc = sqlite3_open (dbFilePathUTF8, &db);
    sqlite3_stmt *dbps;
    const char *sqlStatement = [sqlstr UTF8String];
    dbrc = sqlite3_prepare_v2 (db, sqlStatement, -1, &dbps, NULL);
    while ((dbrc = sqlite3_step (dbps)) == SQLITE_ROW) {
        int i = sqlite3_column_int(dbps, 0);
        NSNumber *cid = [[NSNumber alloc] initWithInt:i];
        i = sqlite3_column_int(dbps, 1);
        NSNumber *ab_rec = [[NSNumber alloc] initWithInt:i];
        
        NSString *hid = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 2)];
        NSString *fname = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 3)];
        NSString *lname = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 4)];
        NSString *phone = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 5)];
        NSString *avatar = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 6)];
        i = sqlite3_column_int(dbps, 7);
        NSNumber *adate = [[NSNumber alloc] initWithInt:i];
        i = sqlite3_column_int(dbps, 8);
        NSNumber *cdate = [[NSNumber alloc] initWithInt:i];
        Contact *contact = [[Contact alloc] initWithId:cid abRecord:ab_rec heyloId:hid phoneNumber:phone firstName:fname lastName:lname avatar:avatar activityDate:adate createdDate:cdate];
        [contacts addObject:contact];
    }
    sqlite3_finalize (dbps);
    sqlite3_close(db);
    
    return contacts;
}

+ (Contact *)getContactByPhone:(NSString *)_phone
{
    Contact *contact;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *sqlstr = [NSString stringWithFormat:@"select * from contacts where phone_number = \"%@\" limit 1", _phone];
    sqlite3 *db;
    int dbrc; // database return code
    const char* dbFilePathUTF8 = [appDelegate.heyloData.dbFilePath UTF8String];
    dbrc = sqlite3_open (dbFilePathUTF8, &db);
    sqlite3_stmt *dbps;
    const char *sqlStatement = [sqlstr UTF8String];
    dbrc = sqlite3_prepare_v2 (db, sqlStatement, -1, &dbps, NULL);
    while ((dbrc = sqlite3_step (dbps)) == SQLITE_ROW) {
        int i = sqlite3_column_int(dbps, 0);
        NSNumber *cid = [[NSNumber alloc] initWithInt:i];
        i = sqlite3_column_int(dbps, 1);
        NSNumber *ab_rec = [[NSNumber alloc] initWithInt:i];
        NSString *hid = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 2)];
        NSString *fname = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 3)];
        NSString *lname = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 4)];
        NSString *phone = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 5)];
        NSString *avatar = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 6)];
        i = sqlite3_column_int(dbps, 7);
        NSNumber *adate = [[NSNumber alloc] initWithInt:i];
        i = sqlite3_column_int(dbps, 8);
        NSNumber *cdate = [[NSNumber alloc] initWithInt:i];
        contact = [[Contact alloc] initWithId:cid abRecord:ab_rec heyloId:hid phoneNumber:phone firstName:fname lastName:lname avatar:avatar activityDate:adate createdDate:cdate];
    }
    return contact;
}

+ (Contact *)getContactByHeyloId:(NSString *)_hid
{
    Contact *contact;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *sqlstr = [NSString stringWithFormat:@"select * from contacts where heylo_id = '%@' limit 1", _hid];
    sqlite3 *db;
    int dbrc; // database return code
    const char* dbFilePathUTF8 = [appDelegate.heyloData.dbFilePath UTF8String];
    dbrc = sqlite3_open (dbFilePathUTF8, &db);
    sqlite3_stmt *dbps;
    const char *sqlStatement = [sqlstr UTF8String];
    dbrc = sqlite3_prepare_v2 (db, sqlStatement, -1, &dbps, NULL);
    while ((dbrc = sqlite3_step (dbps)) == SQLITE_ROW) {
        int i = sqlite3_column_int(dbps, 0);
        NSNumber *cid = [[NSNumber alloc] initWithInt:i];
        i = sqlite3_column_int(dbps, 1);
        NSNumber *ab_rec = [[NSNumber alloc] initWithInt:i];
        NSString *hid = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 2)];
        NSString *fname = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 3)];
        NSString *lname = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 4)];
        NSString *phone = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 5)];
        NSString *avatar = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 6)];
        i = sqlite3_column_int(dbps, 7);
        NSNumber *adate = [[NSNumber alloc] initWithInt:i];
        i = sqlite3_column_int(dbps, 8);
        NSNumber *cdate = [[NSNumber alloc] initWithInt:i];
        contact = [[Contact alloc] initWithId:cid abRecord:ab_rec heyloId:hid phoneNumber:phone firstName:fname lastName:lname avatar:avatar activityDate:adate createdDate:cdate];
    }
    return contact;
}

+ (Contact *)getContactById:(NSNumber *)_cid
{
    Contact *contact;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *sqlstr = [NSString stringWithFormat:@"select * from contacts where id = %@ limit 1", _cid];
    sqlite3 *db;
    int dbrc; // database return code
    const char* dbFilePathUTF8 = [appDelegate.heyloData.dbFilePath UTF8String];
    dbrc = sqlite3_open (dbFilePathUTF8, &db);
    sqlite3_stmt *dbps;
    const char *sqlStatement = [sqlstr UTF8String];
    dbrc = sqlite3_prepare_v2 (db, sqlStatement, -1, &dbps, NULL);
    while ((dbrc = sqlite3_step (dbps)) == SQLITE_ROW) {
        int i = sqlite3_column_int(dbps, 0);
        NSNumber *cid = [[NSNumber alloc] initWithInt:i];
        i = sqlite3_column_int(dbps, 1);
        NSNumber *ab_rec = [[NSNumber alloc] initWithInt:i];
        NSString *hid = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 2)];
        NSString *fname = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 3)];
        NSString *lname = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 4)];
        NSString *phone = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 5)];
        NSString *avatar = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 6)];
        i = sqlite3_column_int(dbps, 7);
        NSNumber *adate = [[NSNumber alloc] initWithInt:i];
        i = sqlite3_column_int(dbps, 8);
        NSNumber *cdate = [[NSNumber alloc] initWithInt:i];
        contact = [[Contact alloc] initWithId:cid abRecord:ab_rec heyloId:hid phoneNumber:phone firstName:fname lastName:lname avatar:avatar activityDate:adate createdDate:cdate];
    }
    return contact;
}

+ (NSArray *)getContactsFromThread:(NSString *)_thread
{
    NSArray *hids = [_thread componentsSeparatedByString:@","];
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    for (Contact *contact in [Contact allContacts]) {
        for (NSString *heylo_Id in hids) {
            // NSLog(@"hids %@ %@", heylo_Id, contact.heyloId);
            if ([heylo_Id isEqualToString:contact.heyloId]) {
                [contacts addObject:contact];
            }
        }
    }
    return contacts;
}

+ (Conversation *)getConversationFromThread:(NSString *)thread
{
    Conversation *conversation;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *sqlstr = [NSString stringWithFormat:@"select * from conversations where thread=\"%@\" limit 1", thread];
    // NSLog(@"sql: %@", sqlstr);
    sqlite3 *db;
    int dbrc; // database return code
    const char* dbFilePathUTF8 = [appDelegate.heyloData.dbFilePath UTF8String];
    dbrc = sqlite3_open (dbFilePathUTF8, &db);
    sqlite3_stmt *dbps;
    const char *sqlStatement = [sqlstr UTF8String];
    dbrc = sqlite3_prepare_v2 (db, sqlStatement, -1, &dbps, NULL);
    while ((dbrc = sqlite3_step (dbps)) == SQLITE_ROW) {
        int i = sqlite3_column_int(dbps, 0);
        NSNumber *cid = [[NSNumber alloc] initWithInt:i];
        NSString *contact_str = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 2)];
        i = sqlite3_column_int(dbps, 3);
        NSNumber *read = [[NSNumber alloc] initWithInt:i];
        NSString *image_url = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 4)];
        i = sqlite3_column_int(dbps, 5);
        NSNumber *mdate = [[NSNumber alloc] initWithInt:i];
        i = sqlite3_column_int(dbps, 6);
        NSNumber *cdate = [[NSNumber alloc] initWithInt:i];
        conversation = [[Conversation alloc] initWithId:cid
                                              andThread:thread
                                       andContactString:contact_str
                                            andReadFlag:read
                                            andImageUrl:image_url
                                           modifiedDate:mdate
                                            createdDate:cdate];
    }
    return conversation;

}

+ (NSString *)getThreadFromContacts:(NSArray *)_contacts
{
    NSMutableString *thread = [[NSMutableString alloc] init];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sorted = [[NSArray alloc] initWithArray:[_contacts sortedArrayUsingDescriptors:sortDescriptors]];
    for (Contact *contact in sorted) {
        [thread appendString:[NSString stringWithFormat:@"%@,",contact.heyloId]];
    }
    return [thread substringToIndex:[thread length]-1];
}

+ (BOOL)createContact:(Contact *)_contact
{
    Contact *contact = _contact;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *sqlstr = [NSString stringWithFormat:
            @"insert into contacts (id,record_id,heylo_id,first_name,last_name,phone_number,avatar,activity_date,created_date) values (%@,%@,\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",%@,%@)",
            contact.contactId,contact.abRecord,contact.heyloId,contact.firstName,contact.lastName,contact.phoneNumber,
            contact.avatar,contact.activityDate, contact.createdDate];
    // NSLog(@"create contact %@", sqlstr);
    return [appDelegate.heyloData execSQLwith:sqlstr];
}

+ (BOOL)updateContact:(Contact *)_contact
{
    Contact *contact = _contact;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *sqlstr = [NSString stringWithFormat:
                        @"update contacts set record_id=\"%@\", first_name=\"%@\", last_name=\"%@\", phone_number=\"%@\", activity_date=%@ where id=%@",
                        contact.abRecord, contact.firstName, contact.lastName,contact.phoneNumber,contact.activityDate,contact.contactId];
    return [appDelegate.heyloData execSQLwith:sqlstr];
}

+ (BOOL)destroyContactWithId:(NSNumber *)_id
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *sqlstr = [NSString stringWithFormat:@"delete from contacts where id = %@", _id];
    return [appDelegate.heyloData execSQLwith:sqlstr];
}

+ (BOOL)clearMessages
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *sqlstr = @"delete from messages";
    return [appDelegate.heyloData execSQLwith:sqlstr];
}


+ (BOOL)clearConversations
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *sqlstr = @"delete from conversations";
    return [appDelegate.heyloData execSQLwith:sqlstr];
}

+ (BOOL)clearContacts
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *sqlstr = @"delete from contacts";
    return [appDelegate.heyloData execSQLwith:sqlstr];
}

+ (NSDictionary *)getUser
{
    NSMutableDictionary *user = [[NSMutableDictionary alloc] init];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *sqlstr = [NSString stringWithFormat:@"select * from users where id=1"];
    sqlite3 *db;
    int dbrc; // database return code
    const char* dbFilePathUTF8 = [appDelegate.heyloData.dbFilePath UTF8String];
    dbrc = sqlite3_open (dbFilePathUTF8, &db);
    sqlite3_stmt *dbps;
    const char *sqlStatement = [sqlstr UTF8String];
    dbrc = sqlite3_prepare_v2 (db, sqlStatement, -1, &dbps, NULL);
    while ((dbrc = sqlite3_step (dbps)) == SQLITE_ROW) {
        int i = sqlite3_column_int(dbps, 0);
        NSNumber *uid = [[NSNumber alloc] initWithInt:i];
        [user setObject:uid forKey:@"userId"];
        NSString *hid = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 1)];
        [user setObject:hid forKey:@"heyloId"];
        NSString *auth = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 2)];
        [user setObject:auth forKey:@"authToken"];
        NSString *fname = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 3)];
        [user setObject:fname forKey:@"firstName"];
        NSString *lname = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 4)];
        [user setObject:lname forKey:@"lastName"];
        NSString *email = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 5)];
        [user setObject:email forKey:@"email"];
        NSString *phone = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 6)];
        [user setObject:phone forKey:@"phoneNumber"];
        NSString *country = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 7)];
        [user setObject:country forKey:@"country"];
        NSString *status = [[NSString alloc] initWithUTF8String: (char*) sqlite3_column_text (dbps, 8)];
        [user setObject:status forKey:@"status"];
        int lm = sqlite3_column_int(dbps, 9);
        NSNumber *mdate = [[NSNumber alloc] initWithInt:lm];
        [user setObject:mdate forKey:@"lastMessageDate"];
        int d = sqlite3_column_int(dbps, 10);
        NSNumber *cdate = [[NSNumber alloc] initWithInt:d];
        [user setObject:cdate forKey:@"createdDate"];
    }
    
    sqlite3_finalize (dbps);
    sqlite3_close(db);
    if (![user objectForKey:@"status"]) {
        [user setObject:@"inactive" forKey:@"status"];
        [user setObject:@"US" forKey:@"country"];
        NSNumber *ts = [HeyloData getTimestamp];
        [user setObject:ts forKey:@"lastMessageDate"];
    }
    
    return user;
}

+ (BOOL)updateUser:(User *)_user
{
    User *user = _user;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *sqlstr = [NSString stringWithFormat:
                        @"update users set heylo_id=\"%@\",auth_token=\"%@\",first_name=\"%@\",last_name=\"%@\",email=\"%@\",phone_number=\"%@\",country=\"%@\",status=\"%@\",last_message_date=%@ where id=1",
                        user.heyloId, user.authToken, user.firstName,user.lastName,user.email,user.phoneNumber,user.country.isoCode,user.status,user.lastMessageDate];
    return [appDelegate.heyloData execSQLwith:sqlstr];
}

+ (BOOL)createUser:(User *)_user
{
    NSNumber *ts = [HeyloData getTimestamp];
    User *user = _user;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *sqlstr = [NSString stringWithFormat:
                    @"insert into users (id, heylo_id, auth_token, first_name, last_name, email, phone_number, country, status, last_message_date, created_date) values (1,\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",%@,%@)",user.authToken,user.heyloId,user.firstName,user.lastName,user.email,user.phoneNumber,user.country.isoCode,user.status,ts,ts];
    return [appDelegate.heyloData execSQLwith:sqlstr];
}

                   

@end

/**
 insert into messages (id,conversation_id,from_id,image_url,message,created_date) values (34,3,"5542afcac2054f056b000013","","They \"seem seem finally to have taken on board something political scientists have been telling us for years: adopting \'centrist\' positions in an attempt to attract swing voters is a mugs game.\" The independent voters whose approval such a strategy seeks don\'t exist anymore, he said, as most of them affiliate strongly with one of the two major parties and the rest \"are mainly just confused.\"",1434479567)
*/