//
//  User.h
//  notify
//
//  Created by Scott Parris on 3/30/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Country;

@interface User : NSObject {
    NSMutableDictionary *settings;
}

@property(nonatomic, strong) NSNumber *userId;
@property(nonatomic, strong) NSString *heyloId;
@property(nonatomic, strong) NSString *authToken;
@property(nonatomic, strong) NSString *firstName;
@property(nonatomic, strong) NSString *lastName;
@property(nonatomic, strong) NSString *phoneNumber;
@property(nonatomic, strong) Country *country;
@property(nonatomic, strong) NSString *email;
@property(nonatomic, strong) NSString *status;
@property(nonatomic, strong) NSNumber *lastMessageDate;
@property(nonatomic, strong) NSNumber *createdDate;

- (id)init;

+ (BOOL)stringIsValidEmail:(NSString *)checkString;

@end