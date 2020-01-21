//
//  TapCategory.m
//  TapToMe
//
//  Created by Scott Parris on 2/10/15.
//  Copyright (c) 2015 TapIn. All rights reserved.
//

#import "CardCategory.h"
// #import "CardImage.h"
#import "AppDelegate.h"
// #import "User.h"

@implementation CardCategory

/**
+ (NSArray *)allCategories
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/categories", BASE_URL, API_VERSION]]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setValue:delegate.user.heyloId forHTTPHeaderField:@"X-API-UID"];
    [request setValue:delegate.user.authToken forHTTPHeaderField:@"X-API-TOKEN"];
    NSError *error;
    NSURLResponse *requestResponse;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:nil];
    NSMutableArray *unsorted = [[NSMutableArray alloc] init];
    if (data != nil) {

        NSDictionary *results = [NSJSONSerialization
                                 JSONObjectWithData:data
                                 options:NSJSONReadingMutableLeaves
                                 error:&error];
        NSString *succesStr = [results objectForKey:@"success"];
        if ([succesStr isEqualToString:@"true"]) {
            NSArray *categories = [results objectForKey:@"categories"];
            for (NSDictionary *catDict in categories) {
                NSString *name = [catDict objectForKey:@"name"];
                NSString *catId = [catDict objectForKey:@"category_id"];
                CardCategory *cat = [[CardCategory alloc] initWithName:name categoryId:catId];
                if ([name isEqualToString:@"Popular"]) {
      //              delegate.popularCategory = cat;
                }
                if ([name isEqualToString:@"Recent"]) {
        //            delegate.recentCategory = cat;
                }
                [unsorted addObject:cat];
        
            }
        } else {
 //           delegate.user.errorMessage = @"Bad response from server.";
        }
    } else {
 //       delegate.user.errorMessage = @"Cannot connect to server.";
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sorted = [[NSArray alloc] initWithArray:[unsorted sortedArrayUsingDescriptors:sortDescriptors]];
    return sorted;
}

*/
 
- (id)initWithName:(NSString *)name
{
    self.name = name;
    return self;
}


/**
- (void)getCategoryImages
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/categories/%@", BASE_URL, API_VERSION, self.categoryId]]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setValue:delegate.user.heyloId forHTTPHeaderField:@"X-API-UID"];
    [request setValue:delegate.user.authToken forHTTPHeaderField:@"X-API-TOKEN"];
    NSError *error;
    NSURLResponse *requestResponse;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:nil];
    unsortedImages = [[NSMutableArray alloc] init];
    if (data != nil) {
        
        NSDictionary *results = [NSJSONSerialization
                                 JSONObjectWithData:data
                                 options:NSJSONReadingMutableLeaves
                                 error:&error];
        NSString *succesStr = [results objectForKey:@"success"];
        if ([succesStr isEqualToString:@"true"]) {
            NSArray *images = [results objectForKey:@"images"];
            for (NSDictionary *imageDic in images) {
                // NSLog(@"===%@ === %@", [imageDic objectForKey:@"name"], [imageDic objectForKey:@"image_url"] );
                CardImage *tapImage = [[CardImage alloc] initWithName:[imageDic objectForKey:@"name"]
                                                            imageId:[imageDic objectForKey:@"image_id"]
                                                                url:[imageDic objectForKey:@"image_url"]];
                [unsortedImages addObject:tapImage];
            }
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            
            self.images = [[NSArray alloc] initWithArray:[unsortedImages sortedArrayUsingDescriptors:sortDescriptors]];
        } else {
         //   delegate.user.errorMessage = @"Bad response from server.";
        }
    } else {
      //  delegate.user.errorMessage = @"Cannot connect to server.";
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sorted = [[NSArray alloc] initWithArray:[unsortedImages sortedArrayUsingDescriptors:sortDescriptors]];
    self.images = [[NSArray alloc] initWithArray:sorted];
   // TapImage *test = [self.images objectAtIndex:20];
   // NSLog(@"category %@ image %@", self.name, test.imageUrl);
}
*/

/**
- (void)getCategoryImages
{
    self.categoryData = [NSMutableData data];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.categoryUrl];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.tapConnection = conn;
}

- (void)cancelDownload
{
    [self.tapConnection cancel];
    self.tapConnection = nil;
    self.categoryData = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *realResponse = (NSHTTPURLResponse *)response;
    if (realResponse.statusCode == 200){
        self.categoryData = [[NSMutableData alloc] init];
    } else {
        self.tapConnection = nil;
        self.categoryData = nil;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    unsortedImages = [[NSMutableArray alloc] init];
    
    NSError *error = nil;
    NSDictionary *results = [NSJSONSerialization
                             JSONObjectWithData:self.categoryData
                             options:NSJSONReadingMutableLeaves
                             error:&error];

    NSString *succesStr = [results objectForKey:@"success"];
    if ([succesStr isEqualToString:@"true"]) {
        NSArray *images = [results objectForKey:@"images"];
        for (NSDictionary *imageDic in images) {
            TapImage *tapImage = [[TapImage alloc] initWithName:[imageDic objectForKey:@"name"]
                                                            url:[imageDic objectForKey:@"url"]];
            [unsortedImages addObject:tapImage];
        }
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        self.images = [[NSArray alloc] initWithArray:[unsortedImages sortedArrayUsingDescriptors:sortDescriptors]];
    }
    if (self.completionHandler)
    {
        self.completionHandler();
    }
    unsortedImages = nil;
    self.tapConnection = nil;
    self.categoryData = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.tapConnection = nil;
    self.categoryData = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.categoryData appendData:data];
}
 
*/


@end
