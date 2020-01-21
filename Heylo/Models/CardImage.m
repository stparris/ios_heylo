//
//  Image.m
//  TapToMe
//
//  Created by Scott Parris on 2/10/15.
//  Copyright (c) 2015 TapIn. All rights reserved.
//

#import "CardImage.h"
#import "User.h"
#import "AppDelegate.h"
#import "ImageCache.h"

@implementation CardImage

+ (NSArray *)getCategories
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/getImages?sort=recent&user_id=%@", BASE_URL, API_VERSION, delegate.user.heyloId]]];

    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    NSError *error;
    NSURLResponse *requestResponse;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:nil];
    if (data != nil) {
        NSDictionary *results = [NSJSONSerialization
                                 JSONObjectWithData:data
                                 options:NSJSONReadingMutableLeaves
                                 error:&error];
        
        NSString *succesStr = [results objectForKey:@"success"];
        if ([succesStr isEqualToString:@"true"]) {
           NSMutableDictionary *categories = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *images = [[NSMutableDictionary alloc] init];
            NSArray *jsonImages = [results objectForKey:@"images"];
            for (NSDictionary *imageDic in jsonImages) {
                NSArray *keys = imageDic.allKeys;
                CardImage *appImage = [[CardImage alloc] initWithName:[imageDic objectForKey:@"name"] imageId:[imageDic objectForKey:@"image_id"] imageUrl:@""];
                for (NSString *key in keys) {
                    if ([key isEqualToString:@"categories"]) {
                        if ([categories objectForKey:@"Home"]) {
                            [[categories objectForKey:@"Home"] addObject:appImage.imageId];
                        } else {
                            NSMutableArray *cardImages = [[NSMutableArray alloc] initWithArray:@[appImage.imageId]];
                            [categories setObject:cardImages forKey:@"Home"];
                        }
                        for (NSString *cat in [imageDic objectForKey:key]) {
                            if ([categories objectForKey:cat]) {
                                [[categories objectForKey:cat] addObject:appImage.imageId];
                            } else {
                                NSMutableArray *cardImages = [[NSMutableArray alloc] initWithArray:@[appImage.imageId]];
                                [categories setObject:cardImages forKey:cat];
                            }
                        }
                    } else if ([key isEqualToString:@"favorite_count"]) {
                        NSNumber *favs = [imageDic objectForKey:key];
                        appImage.favorites = favs;
                    } else if ([key isEqualToString:@"my_favorite"]) {
                        appImage.myFavorite = @"false";
                        
                        if ([[imageDic objectForKey:key] isEqualToString:@"true"]) {
                            appImage.myFavorite = @"true";
                        }
                    } else if ([key isEqualToString:@"create_time"]) {
                        appImage.date = [imageDic objectForKey:@"create_time"];
                    } else if ([key isEqualToString:@"images"]) {
                        NSArray *versions = [imageDic objectForKey:@"images"];
                        NSMutableArray *imgs = [[NSMutableArray alloc] init];
                        int i = 1;
                        for (NSDictionary *version in versions) {
                            [imgs addObject:[version objectForKey:@"url"]];
                            if (i == 1) {
                                appImage.imageUrl = [version objectForKey:@"url"];
                            }
                            i++;
                            if (![delegate.imageCache doesExist:[version objectForKey:@"url"]]) {
                                dispatch_queue_t queue = dispatch_queue_create("downloadAsset",NULL);
                                
                                dispatch_async(queue, ^{
                                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[version objectForKey:@"url"]]];
                                    UIImage *theImage = [UIImage imageWithData:imageData];
                                    if (theImage) {
                                        [delegate.imageCache cacheImage:theImage withData:imageData forURL:[version objectForKey:@"url"]];
                                        NSLog(@"\nSuccess - cache %@", [version objectForKey:@"url"]);
                                    } else {
                                        NSLog(@"\nFailed to cache %@", [version objectForKey:@"url"]);
                                    }
                                });
                            }
                            
                        }
                        appImage.cardImages = [[NSArray alloc] initWithArray:imgs];
                    }
                    [images setObject:appImage forKey:appImage.imageId];
                }
            }

            NSMutableArray *unsorted = [[NSMutableArray alloc] init];
            NSMutableArray *sorted;
            for (NSString *cat in categories) {
                NSString *catName = [cat uppercaseString];
                CardCategory *cardCat = [[CardCategory alloc] initWithName:catName];
                NSMutableArray *unsorted_images = [[NSMutableArray alloc] init];
                for (NSString *imgId in [categories objectForKey:cat]) {
                    [unsorted_images addObject:[images objectForKey:imgId]];
                }
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"favorites" ascending:YES];
                NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                NSArray *sorted_images = [[NSArray alloc] initWithArray:[unsorted_images sortedArrayUsingDescriptors:sortDescriptors]];
                cardCat.images = sorted_images;
                
                // NSLog(@"category %@", cardCat.name);
                
                if ([cardCat.name isEqualToString:@"HOME"]) {
                    delegate.defaultCategory = cardCat;
                    sorted = [[NSMutableArray alloc] initWithArray:@[cardCat]];
                } else {
                    [unsorted addObject:cardCat];
                }
            }
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            [sorted addObjectsFromArray:[unsorted sortedArrayUsingDescriptors:sortDescriptors]];
            return sorted;

        } else {
       //     delegate.user.errorMessage = @"Bad response from server.";
        }
    } else {
       // delegate.user.errorMessage = @"Cannot connect to server.";
    }
    return @[];
}


- (id)initWithName:(NSString *)imageName imageId:(NSString *)imgId imageUrl:(NSString *)url
{
    self.name = imageName;
    self.imageId = imgId;
    self.imageUrl = url;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return self;
}

- (void)setCardFavorite:(BOOL)setFavorite
{
    BOOL got_favorites = NO;
    for (CardCategory *category in appDelegate.categories) {
        NSLog(@"category %@", category.name);
        if ([category.name isEqualToString:@"MY FAVORITES"]) {
            NSLog(@"========== old count %lu", category.images.count);

            got_favorites = YES;
            if (setFavorite == NO) {
                NSMutableArray *newFavs = [[NSMutableArray alloc] init];
                for (CardImage *img in category.images) {
                    if (![self.imageId isEqualToString:img.imageId]) {
                        [newFavs addObject:img];
                    }
                }
                category.images = newFavs;
            } else {
                NSMutableArray *newFavs = [[NSMutableArray alloc] initWithArray:category.images];
                [newFavs addObject:self];
                category.images = newFavs;
            }
            NSLog(@"========== new count %lu", category.images.count);

            if (category.images.count < 1) {
                NSMutableArray *newCategories = [[NSMutableArray alloc] init];
                for (CardCategory *category in appDelegate.categories) {
                    if (![category.name isEqualToString:@"MY FAVORITES"]) {
                        [newCategories addObject:category];
                    }
                }
                appDelegate.categories = newCategories;
                // reload categories table
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadCategories" object:nil];
            }
        }
    }
    if (got_favorites == NO && setFavorite == YES) {
        CardCategory *myFavs = [[CardCategory alloc] initWithName:@"MY FAVORITES"];
        myFavs.images = @[self];
        NSMutableArray *newCategories = [[NSMutableArray alloc] init];
        for (CardCategory *category in appDelegate.categories) {
            if([category.name isEqualToString:@"HOME"]) {
                [newCategories addObject:category];
                [newCategories addObject:myFavs];
            } else {
                [newCategories addObject:category];
            }
        }
        appDelegate.categories = newCategories;
        // reload table
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadCategories" object:nil];
    }
    
    // perform server update in background
    NSString *action = @"setImageFavorite";
    if (setFavorite == NO)
        action = @"clearImageFavorite";
    NSString *urlString = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@/%@/%@?user_id=%@&image_id=%@", BASE_URL, API_VERSION, action, appDelegate.user.heyloId, self.imageId]];
     NSLog(@"url %@", urlString);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
   
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
                 NSLog(@"Failed to set favorite");
            }
        }
    }];
}
    
- (void)getCardImage
{
    if ([appDelegate.imageCache doesExist:self.imageUrl]) {
        NSLog(@"Cache YES %@", self.imageUrl);
        self.cardImage = [appDelegate.imageCache getImageForURL:self.imageUrl];
        if (self.completionHandler)
        {
            self.completionHandler();
        }
     } else {
        NSLog(@"Cache NO  %@", self.imageUrl);
        self.imageData = [NSMutableData data];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.imageUrl]];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        self.tapConnection = conn;
    }
}

- (void)cancelDownload
{
    [self.tapConnection cancel];
    self.tapConnection = nil;
    self.imageData = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // resize here maybe?
    UIImage *image = [[UIImage alloc] initWithData:self.imageData];
    self.cardImage = image;
    [appDelegate.imageCache cacheImage:image withData:self.imageData forURL:self.imageUrl];
    self.tapConnection = nil;
    self.imageData = nil;
    if (self.completionHandler)
    {
        self.completionHandler();
    }
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.tapConnection = nil;
    self.imageData = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.imageData appendData:data];
}


@end
