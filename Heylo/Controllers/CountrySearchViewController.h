//
//  CountrySearchViewController.h
//  heylo
//
//  Created by Scott Parris on 3/9/15.
//  Copyright (c) 2015 TapIn. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Country;

@interface CountrySearchViewController : UITableViewController {
    
}

@property (nonatomic, strong) NSArray *filteredCountries;
@property (nonatomic, strong) Country *selectedCountry;

@end
