//
//  GetMessages.m
//  notify
//
//  Created by Scott Parris on 5/7/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import "GetMessages.h"
#import "AppDelegate.h"
#import "ImageCache.h"
#import "User.h"
#import "Conversation.h"
#import "Message.h"
#import "Contact.h"
#import "HeyloData.h"

@implementation GetMessages


- (id)init
{
    self = [super init];
    return self;
}

- (void)getMessages
{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    // NSLog(@"%@/%@/getMessages?user_id=%@&last_time=%@&reset_count=1", BASE_URL, API_VERSION, appDelegate.user.heyloId,appDelegate.user.lastMessageDate);
    [request setURL:[NSURL URLWithString:
                     [NSString stringWithFormat:@"%@/%@/getMessages?user_id=%@&last_time=%@&reset_count=1", BASE_URL, API_VERSION, appDelegate.user.heyloId,appDelegate.user.lastMessageDate]]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setValue:appDelegate.user.heyloId forHTTPHeaderField:@"X-API-UID"];
    [request setValue:appDelegate.user.authToken forHTTPHeaderField:@"X-API-TOKEN"];

    theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [theConnection start];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error;
    NSDictionary *results = [NSJSONSerialization
                             JSONObjectWithData:theData
                             options:NSJSONReadingMutableLeaves
                             error:&error];
    
    NSString *succesStr = [results objectForKey:@"success"];
    if ([succesStr isEqualToString:@"true"]) {
        // appDelegate.user.lastMessageDate = appDelegate.user.lastMessageDate;
        NSArray *unreadMessages = [results objectForKey:@"msgs"];
        for (NSDictionary *msg in unreadMessages) { 
            /** NSArray *keys = [msg allKeys];
            for (NSString *k in keys) {
                NSLog(@"key %@ value %@", k, [msg objectForKey:k]);
            }
             */
            NSString *image_url = @"";
            if ([[msg objectForKey:@"image_url"] length] > 0)
                image_url = [msg objectForKey:@"image_url"];
            
            Conversation *conversation = [Conversation findOrCreateWithThread:[msg objectForKey:@"conv"] andContactString:[msg objectForKey:@"contact_str"] andImageUrl:image_url setUnread:YES];
            if (image_url.length > 0) {
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:image_url]];
                UIImage *theImage = [UIImage imageWithData:imageData];
                if (theImage) {
                    [appDelegate.imageCache cacheImage:theImage withData:imageData forURL:image_url];
                }
            }
            
            Contact *from = [HeyloData getContactByHeyloId:[msg objectForKey:@"from_id"]];
            if (!from) {
                NSArray *hids = [conversation.thread componentsSeparatedByString:@","];
                NSArray *names = [conversation.contactString componentsSeparatedByString:@","];
                int i = 0;
                for (NSString *hid in hids) {
                    if ([hid isEqualToString:[msg objectForKey:@"from_id"]]) {
                        from = [[Contact alloc] initWithId:[NSNumber numberWithInt:99999]
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
            
            Message *message = [Message createWithConversation:conversation
                                                andContact:from
                                               andImageUrl:[msg objectForKey:@"image_url"]
                                                andMessage:[msg objectForKey:@"msg_text"]
                                                   andDate:[NSNumber numberWithInt:[[msg objectForKey:@"send_time"] intValue]]
                                                isIncoming:YES];
            if (message) {
                appDelegate.user.lastMessageDate = [NSNumber numberWithInt:[[msg objectForKey:@"send_time"] intValue]];
                int i = [appDelegate.inboxCount intValue] + 1;
                appDelegate.inboxCount = [NSNumber numberWithInt:i];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadInbox" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMessages" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"homeInboxCount" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"categoryInboxCount" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"flashMessage" object:nil];
            }
        }
        [HeyloData updateUser:appDelegate.user];
    } else {
        NSLog(@"error: %@", [results objectForKey:@"msg"]);
    }
    theConnection = nil;
    theData = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    theData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [theData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    theConnection = nil;
    theData = nil;
}


@end
