//
//  ImageCache.h
//  notify
//
//  Created by Scott Parris on 5/4/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import <UIKit/UIKit.h>
#define BASE_URL @"http://tapto.me:3000"
#define API_VERSION @"api/v1"

@interface ImageCache : NSObject

@property (nonatomic, strong) NSCache *imageCache;
@property (nonatomic, strong) NSDictionary *diskCache;
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSString *cacheDir;
@property (nonatomic, copy) void (^completionHandler)(void);

- (void)cacheImage:(UIImage *)theImage withData:(NSData *)imageData forURL:(NSString *)imageURL;
- (UIImage *)getImageForURL:(NSString *)imageURL;
- (BOOL)doesExist:(NSString *)imageURL;
- (void)refreshCache;
- (BOOL)loadCache;

@end
