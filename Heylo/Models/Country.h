//
//  Country.h
//  notify
//
//  Created by Scott Parris on 3/30/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Country : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *isoCode;
@property (nonatomic, strong) NSString *dialingCode;

- (id)initWithCode:(NSString *)_code;
- (NSArray *)allCountries;
- (NSDictionary *)dialingCodes;

@end
