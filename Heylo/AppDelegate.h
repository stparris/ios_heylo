//
//  AppDelegate.h
//  Heylo
//
//  Created by Scott Parris on 5/7/15.
//  Copyright (c) 2015 Heylo. All rights reserved.
//

#define DATABASE_RESOURCE_NAME @"heylo"
#define DATABASE_RESOURCE_TYPE @"db"
#define DATABASE_FILE_NAME @"heylo.db"

#import <UIKit/UIKit.h>

@class User;
@class Contact;
@class CardCategory;
@class CardImage;
@class ImageCache;
@class HeyloData;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
}

@property (nonatomic, strong) HeyloData *heyloData;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Contact *myself;
@property (nonatomic, strong) NSString *selectedView;
@property (nonatomic, strong) NSArray *conversations;
@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) CardCategory *defaultCategory;
@property (nonatomic, strong) CardCategory *selectedCategory;
@property (nonatomic, strong) CardImage *selectedImage;
@property (nonatomic, strong) ImageCache *imageCache;
@property (nonatomic, strong) NSNumber *inboxCount;
@property (nonatomic, strong) NSString *alert;

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

@end


