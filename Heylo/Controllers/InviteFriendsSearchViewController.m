//
//  InviteFriendsSearchViewController.m
//  notify
//
//  Created by Scott Parris on 4/24/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import "InviteFriendsSearchViewController.h"
#import "InviteFriendsTableViewCell.h"
#import "ABRecord.h"

@interface InviteFriendsSearchViewController () {
    UIColor *heyloRed;
    UIColor *heyloGreen;
}

@end




@implementation InviteFriendsSearchViewController


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredContacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    heyloGreen = [UIColor colorWithRed:57.0/255 green:181.0/255 blue:73.0/255 alpha:1.0];
    heyloRed = [UIColor colorWithRed:210.0/255 green:78.0/255 blue:59.0/255 alpha:1.0];

    static NSString *CellIdentifier = @"Cell";
    InviteFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[InviteFriendsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *contact = self.filteredContacts[indexPath.row];
    if([[contact objectForKey:@"member"] isEqualToString:@"yes"]) {
        cell.addLabel.text = @"\uE821"; // heart @"\uE821";
        cell.addLabel.textColor = heyloRed;
    } else if ([self.selectedContacts objectForKey:[contact objectForKey:@"number"]]) {
        cell.addLabel.text = @"\uEA0B"; // @"\uEA0B";
        cell.addLabel.textColor = heyloGreen;
    } else {
        cell.addLabel.text = @"\uE8B9"; // + = @"\uE8B9";
        cell.addLabel.textColor = [UIColor darkGrayColor];
    }
    if ([[contact objectForKey:@"type"] isEqualToString:@"Mobile"] ||
        [[contact objectForKey:@"type"] isEqualToString:@"iPhone"]) {
        cell.nameLabel.textColor = [UIColor blueColor];
        cell.phoneLabel.textColor = [UIColor blueColor];
    } else {
        cell.nameLabel.textColor = [UIColor blueColor];
        cell.phoneLabel.textColor = [UIColor blueColor];
    }
    cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [contact objectForKey:@"fname"], [contact objectForKey:@"lname"]];
    cell.phoneLabel.text = [NSString stringWithFormat:@"%@: %@", [contact objectForKey:@"type"], [contact objectForKey:@"number"]];
    
    return cell;
}


@end
