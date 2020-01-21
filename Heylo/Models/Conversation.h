//
//  Conversation.h
//  notify
//
//  Created by Scott Parris on 3/30/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AppDelegate;

@interface Conversation : NSObject {
    AppDelegate *appDelegate;
}

@property (nonatomic, strong) NSNumber *conversationId;
@property (nonatomic, strong) NSString *thread;
@property (nonatomic, strong) NSString *contactString;
@property (nonatomic, strong) NSNumber *readFlag;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSDictionary *lastMessage;
@property (nonatomic, strong) NSNumber *modifiedDate;
@property (nonatomic, strong) NSNumber *createdDate;

- (id)initWithId:(NSNumber *)cid andThread:(NSString *)thread andContactString:(NSString *)contactStr
     andReadFlag:(NSNumber *)readFlag andImageUrl:(NSString *)url modifiedDate:(NSNumber *)modifiedDate createdDate:(NSNumber *)createdDate;

+ (Conversation *)findOrCreateWithThread:(NSString *)thread andContactString:(NSString *)contactStr andImageUrl:(NSString *)_imageUrl setUnread:(BOOL)_unread;
+ (NSArray *)getConversations;

- (BOOL)update;
- (BOOL)destroy;

@end
