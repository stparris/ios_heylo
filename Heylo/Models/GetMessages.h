//
//  MissedMessages.h
//  notify
//
//  Created by Scott Parris on 5/7/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BASE_URL @"http://tapto.me:3000"
#define API_VERSION @"api/v1"

@class AppDelegate;

@interface GetMessages : NSObject{
    AppDelegate *appDelegate;
    NSMutableData *theData;
    NSURLConnection *theConnection;
}

- (void)getMessages;

@end
