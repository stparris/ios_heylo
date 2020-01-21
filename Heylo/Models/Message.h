//
//  Message.h
//  notify
//
//  Created by Scott Parris on 3/30/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AppDelegate;
@class Conversation;
@class Contact;

@interface Message : NSObject {
    AppDelegate *appDelegate;
    NSMutableData *theData;
    NSURLConnection *theConnection;
}

@property (nonatomic, strong) NSNumber *messageId;
@property (nonatomic, strong) Conversation *conversation;
@property (nonatomic, strong) Contact *contact;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSNumber *createdDate;

- (id)initWithId:(NSNumber *)mid andConversation:(Conversation *)conversation andContact:(Contact *)contact
     andImageUrl:(NSString *)url andMessage:(NSString *)message andDate:(NSNumber *)date;

+ (Message *)createWithConversation:(Conversation *)conversation andContact:(Contact *)contact
                        andImageUrl:(NSString *)url andMessage:(NSString *)message andDate:(NSNumber *)_date isIncoming:(BOOL)_incoming;
+ (NSArray *)getMessagesForConversation:(Conversation *)_conversation;

@end
