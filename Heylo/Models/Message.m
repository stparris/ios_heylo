//
//  Message.m
//  notify
//
//  Created by Scott Parris on 3/30/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import "Message.h"
#import "AppDelegate.h"
#import "Conversation.h"
#import "Contact.h"
#import "HeyloData.h"
#import "HeyloConnection.h"
#include <sqlite3.h>

@implementation Message

+ (NSArray *)getMessagesForConversation:(Conversation *)_conversation
{
    NSArray *messages = [[NSArray alloc] initWithArray:[HeyloData getMessagesForConversation:_conversation]];
    return messages;
}

+ (Message *)createWithConversation:(Conversation *)conversation andContact:(Contact *)contact andImageUrl:(NSString *)url andMessage:(NSString *)message andDate:(NSNumber *)_date isIncoming:(BOOL)_incoming
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber *date = _date;
    // NSLog(@"======================\nCreating msg with ts %@", date);
    
    NSNumber *mid = [appDelegate.heyloData setMaxMessageId];
    Message *msg = [[Message alloc] initWithId:mid andConversation:conversation andContact:contact andImageUrl:url andMessage:message andDate:date];
    if (![HeyloData createMessage:msg])
            NSLog(@"Data insert failed");
    if (!_incoming) {
        // Post message
        [HeyloConnection postMessage:msg forConversation:conversation];
    }
    return msg;
}

- (id)initWithId:(NSNumber *)mid andConversation:(Conversation *)conversation andContact:(Contact *)contact
   andImageUrl:(NSString *)url andMessage:(NSString *)message andDate:(NSNumber *)date;
{
    self = [super init];
    if (self) {
        self.messageId = mid;
        self.conversation = conversation;
        self.contact = contact;
        self.imageUrl = url;
        self.message = message;
        self.createdDate = date;
    }
    return self;
}







@end
