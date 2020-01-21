//
//  InviteFriendsViewController.h
//  notify
//
//  Created by Scott Parris on 4/24/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>
#import <MessageUI/MessageUI.h>

@class AppDelegate;

@interface InviteFriendsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, MFMessageComposeViewControllerDelegate>
{
    AppDelegate *appDelegate;
}

@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSMutableDictionary *selectedContacts;
@property (nonatomic, strong) NSArray *abContacts;

@end
