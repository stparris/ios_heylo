//
//  CountrySearchViewController.m
//  heylo
//
//  Created by Scott Parris on 3/9/15.
//  Copyright (c) 2015 TapIn. All rights reserved.
//

#import "CountrySearchViewController.h"
#import "Country.h"
#import "User.h"
#import "AppDelegate.h"

@interface CountrySearchViewController () {
    AppDelegate *delegate;
}

@end

@implementation CountrySearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredCountries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Country *country = self.filteredCountries[indexPath.row];
    cell.textLabel.text = country.name;
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
