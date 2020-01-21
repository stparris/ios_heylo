//
//  AppDelegate.m
//  Heylo
//
//  Created by Scott Parris on 5/7/15.
//  Copyright (c) 2015 Heylo. All rights reserved.
//


#import "AppDelegate.h"
#import "RootViewController.h"
#import "HeyloData.h"
#import "HeyloConnection.h"
#import "User.h"
#import "Contact.h"
#import "Conversation.h"
#import "Message.h"
#import "CardImage.h"
#import "ImageCache.h"
#import "GetMessages.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize conversations, selectedView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // Let the device know we want to receive push notifications
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
/**
    NSDictionary *debug = @{
                            @"ent_time" : @"1431632667",
                            @"badge" : @"1",
                            @"conv" : @"530d31a6f36837d754000001,5542afcac2054f056b000013",
                            @"image_url" : @"",
                            @"from_id" : @"530d31a6f36837d754000001",
                            @"sound" : @"siren.aiff",
                            @"content-available" : @"1",
                            @"alert" : @"test"
                            };
    Message *message = [self processIncoming:debug];
    if (message) {
        int msgCount = [self.inboxCount intValue] + 1;
        self.inboxCount = [NSNumber numberWithInt:msgCount];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:msgCount];
    }
*/
    self.alert = @"";
    self.imageCache = [[ImageCache alloc] init];
    self.inboxCount = [[NSNumber alloc] initWithInt:0];
    self.heyloData = [[HeyloData alloc] initializeData];
    self.user = [[User alloc] init];
    NSLog(@"%@ %@",self.user.phoneNumber, self.user.status);
    if (![self.user.status isEqualToString:@"inactive"]) {
        self.selectedView = @"home";
        int i = 1;
        self.myself = [[Contact alloc] initWithId:[NSNumber numberWithInt:i] abRecord:[NSNumber numberWithInt:i] heyloId:self.user.heyloId phoneNumber:self.user.phoneNumber firstName:self.user.firstName lastName:self.user.lastName avatar:@"default_avatar" activityDate:self.user.createdDate createdDate:self.user.createdDate];
    } else {
        [HeyloData createUser:self.user];
        // self.selectedView = @"intro";
        self.selectedView = @"intro";
    }

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    RootViewController *rootView = [[RootViewController alloc] init];
    [rootView.activityIndicator startAnimating];
    self.navController = [[UINavigationController alloc] initWithRootViewController:rootView];
    [self.window setRootViewController:self.navController];
    [self.window setBackgroundColor:[UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1]];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    self.deviceToken = [NSString stringWithString:[token stringByReplacingOccurrencesOfString:@" " withString:@""]];
    NSLog(@"content---%@", self.deviceToken);
    if (![self.user.status isEqualToString:@"inactive"]) {
        NSDictionary *results = [HeyloConnection newSession];
        if ([[results objectForKey:@"success"] isEqualToString:@"false"]) {
            NSLog(@"post device error ---%@", [results objectForKey:@"message"]);
        }
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    self.deviceToken = nil;
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *) application handleActionWithIdentifier: (NSString *) identifier
forRemoteNotification: (NSDictionary *) notification completionHandler: (void (^)()) completionHandler {
    
    if ([identifier isEqualToString: @"ACCEPT_IDENTIFIER"]) {
        //      [self handleAcceptActionWithNotification:notification];
    }
    
    // Must be called when finished
    completionHandler();
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    self.alert = [aps objectForKey:@"alert"];
    NSLog(@"alert set? %@",[userInfo objectForKey:@"alert"]);
    
    GetMessages *mmobj = [[GetMessages alloc] init];
    [mmobj getMessages];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    self.inboxCount = [HeyloData unreadMessageCount];
    int msgCount = [self.inboxCount intValue];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:msgCount];
    [HeyloConnection setBadgeCount];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [HeyloData updateUser:self.user];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (![self.user.status isEqualToString:@"inactive"]) {
        GetMessages *mmobj = [[GetMessages alloc] init];
        [mmobj getMessages];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// test

@end
