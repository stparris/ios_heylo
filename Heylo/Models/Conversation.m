//
//  Conversation.m
//  notify
//
//  Created by Scott Parris on 3/30/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import "Conversation.h"
#import "AppDelegate.h"
#import "Contact.h"
#import "HeyloData.h"

@implementation Conversation

- (id)initWithId:(NSNumber *)cid andThread:(NSString *)thread andContactString:(NSString *)contactStr
     andReadFlag:(NSNumber *)readFlag andImageUrl:(NSString *)url modifiedDate:(NSNumber *)modifiedDate createdDate:(NSNumber *)createdDate
{
    self = [super init];
    if (self) {
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.conversationId = cid;
        self.thread = thread;
        self.contactString = contactStr;
        self.readFlag = readFlag;
        self.imageUrl = url;
        self.modifiedDate = modifiedDate;
        self.createdDate = createdDate;
    }
    return self;
}

+ (Conversation *)findOrCreateWithThread:(NSString *)thread andContactString:(NSString *)contactStr andImageUrl:(NSString *)_imageUrl setUnread:(BOOL)unread;
{
    NSNumber *date = [HeyloData getTimestamp];
    NSString *contactString = contactStr;
    NSString *url = _imageUrl;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Conversation *conversation = [HeyloData getConversationFromThread:thread];
    for (Contact *contact in [HeyloData getContactsFromThread:thread]) {
        contact.activityDate = date;
        [HeyloData updateContact:contact];
    }
    if (conversation) {
        if (unread) {
            int unreadCount = [conversation.readFlag intValue] + 1;
            conversation.readFlag = [NSNumber numberWithInt:unreadCount];
        }
        conversation.modifiedDate = date;
        if (url.length > 1)
            conversation.imageUrl = url;
        if (![conversation update]) {
            NSLog(@"Failed to update conversation.");
        }
        return conversation;
    } else {
        NSNumber *cid = [appDelegate.heyloData setMaxConversationId];
        NSNumber *readFlag = [NSNumber numberWithInt:0];
        if (unread)
            readFlag = [NSNumber numberWithInt:1];
        Conversation *conversation = [[Conversation alloc] initWithId:cid andThread:thread andContactString:contactString andReadFlag:readFlag andImageUrl:_imageUrl modifiedDate:date createdDate:date];
        
        if (![HeyloData createConversation:conversation]) {
            NSLog(@"Failed to creeate conversation.");
        }
        return conversation;
    }
}

+ (NSArray *)getConversations
{
    NSArray *conversations = [HeyloData getConversations];
    for (Conversation *c in conversations) {
        c.lastMessage = [HeyloData lastMessageFromConversation:c];
    }
    return conversations; 
}


- (BOOL)update
{
    return [HeyloData updateConversation:self];
}

- (BOOL)destroy
{
    if ([HeyloData destroyMessagesWithConversationId:self.conversationId]) {
        return [HeyloData destroyConversationWithId:self.conversationId];
    } else {
        return NO;
    }
}

- (NSArray *)getContactsFromNumbers:(NSArray *)_numbers
{
    return @[];
}

@end
