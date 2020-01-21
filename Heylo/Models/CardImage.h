//
//  Image.h
//  TapToMe
//
//  Created by Scott Parris on 2/10/15.
//  Copyright (c) 2015 TapIn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardCategory.h"

#define BASE_URL @"http://tapto.me:3000"
#define API_VERSION @"api/v1"

@class AppDelegate;

@interface CardImage : NSObject {
    NSMutableArray *unsortedImages;
    AppDelegate *appDelegate;
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imageId;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) UIImage *cardImage;
@property (nonatomic, strong) NSNumber *date;
@property (nonatomic, strong) NSNumber *favorites;
@property (nonatomic, strong) NSString *myFavorite;
@property (nonatomic, strong) NSArray *cardImages;
@property (nonatomic, strong) NSArray *cardAttribs;
@property (nonatomic, strong) NSArray *cardAttribURLs;
@property (nonatomic, strong) NSMutableData *imageData;
@property (nonatomic, strong) NSURLConnection *tapConnection;
@property (nonatomic, copy) void (^completionHandler)(void);

- (id)initWithName:(NSString *)imageName imageId:(NSString *)imgId imageUrl:(NSString *)url;
- (void)getCardImage;
- (void)setCardFavorite:(BOOL)setFavorite;

+ (NSArray *)getCategories;

@end
