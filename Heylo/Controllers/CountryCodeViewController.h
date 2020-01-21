//
//  CountryCodeViewController.h
//  heylo
//
//  Created by Scott Parris on 2/28/15.
//  Copyright (c) 2015 TapIn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegistrationViewController.h"

@interface CountryCodeViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating> {
    NSArray *countries;
}

@end
