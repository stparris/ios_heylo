//
//  InviteFriendsSearchViewController.h
//  notify
//
//  Created by Scott Parris on 4/24/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InviteFriendsSearchViewController : UITableViewController

@property (nonatomic, strong) NSArray *filteredContacts;
@property (nonatomic, strong) NSDictionary *selectedContacts;

@end
