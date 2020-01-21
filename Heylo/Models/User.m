//
//  User.m
//  notify
//
//  Created by Scott Parris on 3/30/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import "User.h"
#import "Country.h"
#import "HeyloData.h"

@implementation User

+ (BOOL)stringIsValidEmail:(NSString *)checkString
{
    // From http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


- (id)init
{
    self = [super init];
    if (self) {
        NSDictionary *userDic = [HeyloData getUser];
        self.userId = [userDic objectForKey:@"userId"];
        self.heyloId = [userDic objectForKey:@"heyloId"];
        self.authToken = [userDic objectForKey:@"authToken"];
        self.firstName = [userDic objectForKey:@"firstName"];
        self.lastName = [userDic objectForKey:@"lastName"];
        self.phoneNumber = [userDic objectForKey:@"phoneNumber"];
        self.email = [userDic objectForKey:@"email"];
        self.status = [userDic objectForKey:@"status"];
        self.country = [[Country alloc] initWithCode:[userDic objectForKey:@"country"]];
        self.lastMessageDate = [userDic objectForKey:@"lastMessageDate"];
        self.createdDate = [userDic objectForKey:@"createdDate"];
    }
    return self;
}








@end
