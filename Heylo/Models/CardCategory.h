//
//  TapCategory.h
//  TapToMe
//
//  Created by Scott Parris on 2/10/15.
//  Copyright (c) 2015 TapIn. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AppDelegate;

#define BASE_URL @"http://tapto.me:3000"
#define API_VERSION @"api/v1"

@interface CardCategory : NSObject {
    NSMutableArray *unsortedImages;
    AppDelegate *appDelegate;
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *categoryId;
@property (nonatomic, strong) NSArray *images;

// @property (nonatomic, strong) NSString *active;
// @property (nonatomic, strong) NSMutableData *categoryData;
// @property (nonatomic, strong) NSURLConnection *tapConnection;
// @property (nonatomic, copy) void (^completionHandler)(void);


- (id)initWithName:(NSString *)name;

// - (void)getCategoryImages;
// + (NSArray *)allCategories;

@end
