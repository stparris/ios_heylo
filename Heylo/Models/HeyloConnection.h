//
//  HeyloConnection.h
//  notify
//
//  Created by Scott Parris on 4/6/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#define BASE_URL @"http://tapto.me:3000"
#define API_VERSION @"api/v1"
#define PLATFORM @"APNS_SANDBOX"

#import <Foundation/Foundation.h>

@class User;
@class Message;
@class Conversation;

@interface HeyloConnection : NSObject

@property (nonatomic, strong) NSMutableData *theData;
@property (nonatomic, strong) NSURLConnection *theConnection;
@property (nonatomic, copy) void (^completionHandler)(void);

+ (void)requestConfirmationCode;
+ (NSDictionary *)confirmationWithCode:(NSString *)_code;
+ (NSDictionary *)newSession;

+ (void)postMessage:(Message *)_message forConversation:(Conversation *)_conversation;
+ (BOOL)updateDeviceToken;
+ (void)setBadgeCount;

@end
