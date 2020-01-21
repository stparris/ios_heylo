//
//  HeyloConnection.m
//  notify
//
//  Created by Scott Parris on 4/6/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import "HeyloConnection.h"
#import "AppDelegate.h"
#import "HeyloData.h"
#import "User.h"
#import "Country.h"
#import "Conversation.h"
#import "Message.h"
#import "Contact.h"

@implementation HeyloConnection

+ (void)requestConfirmationCode
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *phoneString = [NSString stringWithFormat:@"%@%@", appDelegate.user.country.dialingCode, appDelegate.user.phoneNumber];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/registrations/new", BASE_URL, API_VERSION]]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setValue:phoneString forHTTPHeaderField:@"X-API-PHONE"];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] > 0 && error == nil) {
             NSDictionary *results = [NSJSONSerialization
                                      JSONObjectWithData:data
                                      options:NSJSONReadingMutableLeaves
                                      error:&error];
       
             NSString *succesStr = [results objectForKey:@"success"];
             if ([succesStr isEqualToString:@"false"]) {
                 NSLog(@"Error from server: %@", [results objectForKey:@"message"]);
             }
         } else {
             NSLog(@"Cannot connect to server: %@", error.description);
         }
    }];
}

+ (NSDictionary *)confirmationWithCode:(NSString *)_code
{
    NSString *code = _code;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *phoneString = [NSString stringWithFormat:@"%@%@", appDelegate.user.country.dialingCode, appDelegate.user.phoneNumber];
    NSMutableDictionary *returnDoc = [[NSMutableDictionary alloc] init];
    NSError *error;
    NSString *jsonPostBody = [NSString stringWithFormat:
                            @"{ \"confirmation_code\": \"%@\", \"device_token\": \"%@\", \"first_name\": \"%@\", \"last_name\": \"%@\", \"email\": \"%@\",\"platform\": \"%@\" }", code, appDelegate.deviceToken, appDelegate.user.firstName, appDelegate.user.lastName, appDelegate.user.email, PLATFORM];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonPostBody length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/registrations", BASE_URL, API_VERSION]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:phoneString forHTTPHeaderField:@"X-API-PHONE"];
    [request setHTTPBody:[jsonPostBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLResponse *requestResponse;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:nil];
    if (data != nil) {
        NSDictionary *results = [NSJSONSerialization
                                 JSONObjectWithData:data
                                 options:NSJSONReadingMutableLeaves
                                 error:&error];
        NSString *succesStr = [results objectForKey:@"success"];
        [returnDoc setValue:succesStr forKey:@"success"];
        if ([succesStr isEqualToString:@"true"]) {
            appDelegate.user.status = @"beginer";
            appDelegate.user.heyloId = [results objectForKey:@"user_id"];
            appDelegate.user.authToken = [results objectForKey:@"auth_token"];
            [HeyloData updateUser:appDelegate.user];
        } else {
            [returnDoc setValue:[results objectForKey:@"message"] forKey:@"message"];
        }
    } else {
        [returnDoc setValue:@"Cannot connect to server." forKey:@"message"];
    }
    return returnDoc;
}

+ (NSDictionary *)newSession
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableDictionary *returnDoc = [[NSMutableDictionary alloc] init];
    NSError *error;
    NSString *jsonPostBody = [NSString stringWithFormat:@"{ \"device_token\": \"%@\" }", appDelegate.deviceToken];
    // NSLog(@"json: %@", jsonPostBody);
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonPostBody length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/sessions", BASE_URL, API_VERSION]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:appDelegate.user.authToken forHTTPHeaderField:@"X-API-TOKEN"];
    [request setValue:appDelegate.user.heyloId forHTTPHeaderField:@"X-API-UID"];
    [request setHTTPBody:[jsonPostBody dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLResponse *requestResponse;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:nil];
    if (data != nil) {
        NSDictionary *results = [NSJSONSerialization
                                 JSONObjectWithData:data
                                 options:NSJSONReadingMutableLeaves
                                 error:&error];
        NSString *succesStr = [results objectForKey:@"success"];
        [returnDoc setValue:succesStr forKey:@"success"];
        if ([succesStr isEqualToString:@"false"]) {
            [returnDoc setValue:[results objectForKey:@"message"] forKey:@"message"];
        }
    } else {
        [returnDoc setValue:@"Cannot connect to server." forKey:@"message"];
    }
    return returnDoc;
}
 
+ (void)postMessage:(Message *)_message forConversation:(Conversation *)_conversation
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Message *message = _message;
    Conversation *conversation = _conversation;
    NSString *text = [message.message stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSMutableString *jsonPostBody = [NSMutableString stringWithFormat:@"{ \"user_id\": \"%@\",", appDelegate.user.heyloId];
    [jsonPostBody appendFormat:@"\"conv\":\"%@\",", conversation.thread];
    [jsonPostBody appendFormat:@"\"contact_str\":\"%@\",", conversation.contactString];
    [jsonPostBody appendFormat:@"\"image_url\":\"%@\",", message.imageUrl];
    [jsonPostBody appendFormat:@"\"message\":\"%@\",", text];
    [jsonPostBody appendFormat:@"\"send_time\":\"%@\"}", message.createdDate];

    // NSLog(@"json: %@ url: %@",jsonPostBody, [NSString stringWithFormat:@"%@/%@/send", BASE_URL, API_VERSION]);
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonPostBody length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/send", BASE_URL, API_VERSION]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:appDelegate.user.authToken forHTTPHeaderField:@"X-API-TOKEN"];
    [request setValue:appDelegate.user.heyloId forHTTPHeaderField:@"X-API-UID"];
    [request setHTTPBody:[jsonPostBody dataUsingEncoding:NSUTF8StringEncoding]];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] > 0 && error == nil) {
             NSDictionary *results = [NSJSONSerialization
                                      JSONObjectWithData:data
                                      options:NSJSONReadingMutableLeaves
                                      error:&error];
             
             NSString *succesStr = [results objectForKey:@"success"];
             if ([succesStr isEqualToString:@"false"]) {
                 NSLog(@"Error from server: %@", [results objectForKey:@"message"]);
             }
         } else {
             NSLog(@"Cannot connect to server: %@", error.description);
         }
     }];
}



/**
Device Registration
After a user downloads and registers the mobile app, send the device token, which is used to send APNS notifications.

newToken - Set new mobile token ID, to be used for sending Apple notify push messages.
Method: POST
Request Parameters
{
user_id:”12345678901”
type: “IOS”,
OS: <IOS version>,
HW: <phone hardware configuration>,
token: “xxxxx”,
time_zone: “”
}
Response:
{“success":"true"}
    {“success”:”false”,”msg”:”Unknown user.”}
    {“success”:”false”,”msg”:”Something went wrong.”}
TEST:
    curl -H "Content-Type: application/json" -X POST -d '{"user_id":"530d31a6f36837d754000001","token":"12345”}' http://localhost:3000/api/v1/newToken
    Mobile App Start
    Since the device token can change, it should be sent each time the mobile app starts.
*/


+ (BOOL)registerDevice
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSError *error;
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    NSMutableString *jsonPostBody = [NSMutableString stringWithFormat:@"{ \"user_id\": \"%@\",", appDelegate.user.heyloId];
    [jsonPostBody appendString:@"\"type\":\"IOS\","];
    [jsonPostBody appendFormat:@"\"OS\":\"%@\",", currSysVer];
    [jsonPostBody appendFormat:@"\"token\":\"%@\"}", appDelegate.deviceToken];
    
    // NSLog(@"json: %@ url:%@",jsonPostBody,[NSString stringWithFormat:@"%@/%@/newToken", BASE_URL, API_VERSION]);
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonPostBody length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/newToken", BASE_URL, API_VERSION]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:appDelegate.user.authToken forHTTPHeaderField:@"X-API-TOKEN"];
    [request setHTTPBody:[jsonPostBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLResponse *requestResponse;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:nil];
    if (data != nil) {
        NSDictionary *results = [NSJSONSerialization
                                 JSONObjectWithData:data
                                 options:NSJSONReadingMutableLeaves
                                 error:&error];
        NSString *succesStr = [results objectForKey:@"success"];
        if ([succesStr isEqualToString:@"true"]) {
            return YES;
        } else {
            NSLog(@"Failed: %@",[results objectForKey:@"msg"]);
        }
    }
    return NO;
}

/**
UpdateToken - Update user's mobile token ID, to be used for sending Apple notify push messages
Method POST
Request Parameters
{
user_id:”12345678901”
type: “IOS”,
token: “xxxxx"
}
Response:
{“success":"true"}
    {“success”:”false”,”msg”:”Unknown user.”}
    {“success”:”false”,”msg”:”Something went wrong.”}
    
    TEST
    curl -H "Content-Type: application/json" -X POST -d '{"user_id":"530d31a6f36837d754000001","token":"67890"}' http://localhost:3000/api/v1/updateToken
    
*/

+ (BOOL)updateDeviceToken
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSError *error;
    NSMutableString *jsonPostBody = [NSMutableString stringWithFormat:@"{ \"user_id\": \"%@\",", appDelegate.user.heyloId];
    [jsonPostBody appendString:@"\"type\":\"IOS\""];
    [jsonPostBody appendFormat:@"\"token\":\"%@\"}", appDelegate.deviceToken];
    
    // NSLog(@"json: %@",jsonPostBody);
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonPostBody length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/updateToken", API_VERSION, BASE_URL]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:appDelegate.user.authToken forHTTPHeaderField:@"X-API-TOKEN"];
    [request setHTTPBody:[jsonPostBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLResponse *requestResponse;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:nil];
    if (data != nil) {
        NSDictionary *results = [NSJSONSerialization
                                 JSONObjectWithData:data
                                 options:NSJSONReadingMutableLeaves
                                 error:&error];
        NSString *succesStr = [results objectForKey:@"success"];
        if ([succesStr isEqualToString:@"true"]) {
            return YES;
        } else {
            NSLog(@"Failed: %@",[results objectForKey:@"msg"]);
        }
    }
    return NO;
}


/** This method allows the mobile app to set the Heylo icon’s badge count on the server.  The next APNS message sent to this user will be this number plus one.
 
 Method:  GET
 
 Request Parameters
 user_id=
 count=<integer>
 
 Response
 {”success":"true"}
 {“success”:”false”,”msg”:”Unknown user.”}
 {“success”:”false”,”msg”:”Something went wrong.”}
 
 Test Command
 curl 'http://localhost:3000/api/v1/setBadgeCount?user_id=530d31a6f36837d754000001&count=5'
 */


+ (void)setBadgeCount
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:
                     [NSString stringWithFormat:@"%@/%@/setBadgeCount?user_id=%@&count=%@", BASE_URL, API_VERSION, appDelegate.user.heyloId, appDelegate.inboxCount]]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setValue:appDelegate.user.authToken forHTTPHeaderField:@"X-API-TOKEN"];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] > 0 && error == nil) {
             NSDictionary *results = [NSJSONSerialization
                                      JSONObjectWithData:data
                                      options:NSJSONReadingMutableLeaves
                                      error:&error];
             
             NSString *succesStr = [results objectForKey:@"success"];
             if ([succesStr isEqualToString:@"false"]) {
                 NSLog(@"Error from server: %@", [results objectForKey:@"message"]);
             }
         } else {
             NSLog(@"Cannot connect to server: %@", error.description);
         }
     }];
    
}

/**
Category Select
Whenever the user selects a category, the app will retrieve a list of images from the server.

getImages
method GET
Request Parameters
user_id=
category=
Response
{“success”:”false”,”msg”:”Unknown user.”}
{“success”:”false”,”msg”:”Something went wrong.”}
{
    “success”:”true”,
    “images”: [{
           “image_id”: “<string>”,   # unique id
            “name”: “<string>”,
            “categories”: [ “<string>”,...] ,    # array of category names
            “favorite_count”: <integer>,      # count of times this group was favorited. Use this for Popular sort.
                “my_favorite”: “<string>",          #  TRUE | FALSE   If this was favorited by this user
                “create_time”: <integer>,          # epoch time when this group was created. Use this for Recent sort.
                    “update_time”: <integer>,         # epoch time when this group was last updated
                    “image_size”: “<string>”,                      # image aspect ration, select from list
                     “images”: [                                # array of images belonging to this group
                                          {
                                                  “url”: “<string>”,              # URL to the image
                                                  “my_favorite”: “<string>”, #  TRUE | FALSE   This image favorited by this user
                                              },
                                          ...
                                     ],
                    “create_time”: <integer>,          # epoch time when this group was created
                }]
}

TEST
curl http://localhost:3000/api/v1/getImages?user_id=530d31a6f36837d754000001

{
    "success": "true",
    "images": [
               {
                   "image_id": "54f3664025dc9ac696000002",
                   "categories": [
                                  "Relationship"
                                  ],
                   "images": [
                              {
                                  "url": "http://54.159.134.168:3000/thebold_1.png",
                                  "my_favorite": "false"
                              }
                              ],
                   "my_favorite": "false",
                   "favorite_count": 0,
                   "image_size": "1:1",
                   "name": "Bold1",
                   "create_time": 1425237568,
                   "update_time": 1425868425
               }
               ]
}
*/





@end
