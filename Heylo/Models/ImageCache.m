 //
//  ImageCache.m
//  notify
//
//  Created by Scott Parris on 5/4/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import "ImageCache.h"
#import <CommonCrypto/CommonDigest.h>
#import "AppDelegate.h"
#import "User.h"
#import "CardImage.h"
#import "CardCategory.h"


@implementation ImageCache {
    NSMutableData *theData;
    NSURLConnection *theConnection;
    AppDelegate *appDelegate;
}


// From SDWebImage
static unsigned char kPNGSignatureBytes[8] = {0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A};
static NSData *kPNGSignatureData = nil;

- (id)init
{
    self = [super init];
    if (self) {
        self.imageCache = [[NSCache alloc] init];
        self.fileManager = [[NSFileManager alloc] init];
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllObjects) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}


- (UIImage *)getImageForURL:(NSString *)imageURL
{
    NSString *filename = [self fileNameFromURL:imageURL];
   
    if ([self.imageCache objectForKey:filename]) {
        return [self.imageCache objectForKey:filename];
    }
    // NSLog(@"getImageForURL getting file path");
    NSString *filePath = [[self cacheDirectoryName] stringByAppendingString:filename];
    if ([self.fileManager fileExistsAtPath:filePath]) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
        UIImage *theImage = [UIImage imageWithData:data];
        [self.imageCache setObject:theImage forKey:filename];
        return theImage;
    } else {
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        UIImage *theImage = [UIImage imageWithData:imageData];
        [self.imageCache setObject:theImage forKey:filename];
        [self writeToFile:filePath withImage:theImage withData:imageData];
        return theImage;
    }
}

- (void)cacheImage:(UIImage *)theImage withData:(NSData *)imageData forURL:(NSString *)imageURL
{
    NSString *filename = [self fileNameFromURL:imageURL];
    NSString *filePath = [[self cacheDirectoryName] stringByAppendingString:filename];
    [self.imageCache setObject:theImage forKey:filename];
    [self writeToFile:filePath withImage:theImage withData:imageData];
}

- (BOOL)doesExist:(NSString *)imageURL
{
    NSString *filename = [self fileNameFromURL:imageURL];
    if ([self.imageCache objectForKey:filename]) {
        return YES;
    }
    NSString *filePath = [[self cacheDirectoryName] stringByAppendingString:filename];
    if ([self.fileManager fileExistsAtPath:filePath]) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
        UIImage *theImage = [UIImage imageWithData:data];
        [self.imageCache setObject:theImage forKey:filename];
        return YES;
    }
    return NO;
}


/**********************************************************************************/


- (NSString *)fileNameFromURL:(NSString *)url
{
    const char *cStr = [url UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (int)strlen(cStr), result );
    NSString *fileName = [NSString stringWithFormat:
                           @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                           result[0], result[1], result[2], result[3],
                           result[4], result[5], result[6], result[7],
                           result[8], result[9], result[10], result[11],
                           result[12], result[13], result[14], result[15]
                           ];
    return fileName;
}

// From SDWebImage
-(BOOL)imageDataHasPNGPreffix:(NSData *)data
{
    NSUInteger pngSignatureLength = [kPNGSignatureData length];
    if ([data length] >= pngSignatureLength) {
        if ([[data subdataWithRange:NSMakeRange(0, pngSignatureLength)] isEqualToData:kPNGSignatureData]) {
            return YES;
        }
    }
    return NO;
}



- (void)writeToFile:(NSString *)filePath withImage:(UIImage *)image withData:(NSData *)imageData
{
    // From SDWebImage
    kPNGSignatureData = [NSData dataWithBytes:kPNGSignatureBytes length:8];
    BOOL imageIsPng = YES;
    if ([imageData length] >= [kPNGSignatureData length]) {
        imageIsPng = [self imageDataHasPNGPreffix:imageData];
    }
    
    if (imageIsPng) {
        imageData = UIImagePNGRepresentation(image);
    }
    else {
        imageData = UIImageJPEGRepresentation(image, (CGFloat)1.0);
    }
    [self.fileManager createFileAtPath:filePath contents:imageData attributes:nil];
}

- (NSString *)cacheDirectoryName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *cacheDirectoryName = [documentsDirectory stringByAppendingPathComponent:@"heyloCards"];
    return cacheDirectoryName;
}

- (BOOL)loadCache
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/getImages?sort=recent&user_id=%@", BASE_URL, API_VERSION, appDelegate.user.heyloId]]];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    NSURLResponse *requestResponse;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:nil];
    if (data != nil) {
        NSError *error;
        NSDictionary *results = [NSJSONSerialization
                                 JSONObjectWithData:data
                                 options:NSJSONReadingMutableLeaves
                                 error:&error];
        [self processResults:results];
    }
    return YES;
}

- (void)processResults:(NSDictionary *)results
{
    if ([[results objectForKey:@"success"] isEqualToString:@"true"]) {
        NSMutableDictionary *categories = [[NSMutableDictionary alloc] init];
        NSMutableArray *favorites = [[NSMutableArray alloc] init];
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
                        [favorites addObject:appImage];
                    }
                } else if ([key isEqualToString:@"create_time"]) {
                    appImage.date = [imageDic objectForKey:@"create_time"];
                } else if ([key isEqualToString:@"images"]) {
                    NSArray *versions = [imageDic objectForKey:@"images"];
                    NSDictionary *image = [versions objectAtIndex:0];
                    appImage.imageUrl = [image objectForKey:@"url"];
                    BOOL isFavorite = NO;
                    if ([[image objectForKey:@"my_favorite"] isEqualToString:@"true"]) {
                        isFavorite = YES;
                    }
                    [self getImageForURL:appImage.imageUrl];
                    NSMutableArray *imgs = [[NSMutableArray alloc] init];
                    NSMutableArray *attribs = [[NSMutableArray alloc] init];
                    NSMutableArray *attribUrls = [[NSMutableArray alloc] init];
                    for (NSDictionary *version in versions) {
/**                     NSArray *keys = [version allKeys];
                        for (NSString *key in keys) {
                            NSLog(@"key %@ val %@", key, [version objectForKey:key]);
                        }
*/
                        [imgs addObject:[version objectForKey:@"url"]];
                        [attribs addObject:[version objectForKey:@"source_text"]];
                        [attribUrls addObject:[version objectForKey:@"source_url"]];
                    }
                    appImage.cardImages = [[NSArray alloc] initWithArray:imgs];
                    appImage.cardAttribs = [[NSArray alloc] initWithArray:attribs];
                    appImage.cardAttribURLs = [[NSArray alloc] initWithArray:attribUrls];
                    /** For now let's not cache the alternates
                     for (NSDictionary *version in versions) {
                     if (![appDelegate.imageCache doesExist:[version objectForKey:@"url"]]) {
                     
                     dispatch_queue_t queue = dispatch_queue_create("downloadAsset",NULL);
                     dispatch_async(queue, ^{
                     NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[version objectForKey:@"url"]]];
                     UIImage *theImage = [UIImage imageWithData:imageData];
                     if (theImage) {
                     [appDelegate.imageCache cacheImage:theImage forURL:[version objectForKey:@"url"]];
                     NSLog(@"\nSuccess - cache %@", [version objectForKey:@"url"]);
                     } else {
                     NSLog(@"\nFailed to cache %@", [version objectForKey:@"url"]);
                     }
                     });
                     }
                     }
                     */
                }
                [images setObject:appImage forKey:appImage.imageId];
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
                    appDelegate.defaultCategory = cardCat;
                    sorted = [[NSMutableArray alloc] initWithArray:@[cardCat]];
                    if (favorites.count > 0) {
                        CardCategory *favCat = [[CardCategory alloc] initWithName:@"MY FAVORITES"];
                        favCat.images = [[NSArray alloc] initWithArray:favorites];
                        [sorted addObject:favCat];
                    }
                } else {
                    [unsorted addObject:cardCat];
                }
            }
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            [sorted addObjectsFromArray:[unsorted sortedArrayUsingDescriptors:sortDescriptors]];
            appDelegate.categories = sorted;
        }
    }

}

- (void)refreshCache
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/getImages?sort=recent&user_id=%@&limit=50", BASE_URL, API_VERSION, appDelegate.user.heyloId]]];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    
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
    [self processResults:results];
    theConnection = nil;
    theData = nil;
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    theData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    theConnection = nil;
    theData = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [theData appendData:data];
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
}


@end
