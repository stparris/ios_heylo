//
//  InviteFriendsViewController.m
//  notify
//
//  Created by Scott Parris on 4/24/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import "InviteFriendsViewController.h"
#import "AppDelegate.h"
#import "Contact.h"
#import "InviteFriendsTableViewCell.h"
#import "InviteFriendsSearchViewController.h"
#import "ABRecord.h"
#import "HeaderGradientView.h"
#import "FlashView.h"
#import "HeyloData.h"
#import "PopupView.h"

@interface InviteFriendsViewController () {
    UIView *searchView;
    CGFloat navHeight;
    UIView *infoView;
    UIColor *heyloRed;
    UIColor *heyloGreen;
}


@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIBarButtonItem *sendButton;
@property (nonatomic, strong) UIBarButtonItem *backButton;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) InviteFriendsSearchViewController *resultsTableController;
@property (nonatomic, assign) ABAddressBookRef addressBook;
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;
@property (nonatomic, strong) FlashView *flashView;

- (void)sendAction:(id)sender;
- (void)backAction:(id)sender;
- (void)showMessage;
- (void)dismissModal:(id)sender;

@end

@implementation InviteFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    heyloGreen = [UIColor colorWithRed:57.0/255 green:181.0/255 blue:73.0/255 alpha:1.0];
    heyloRed = [UIColor colorWithRed:210.0/255 green:78.0/255 blue:59.0/255 alpha:1.0];
    _resultsTableController = [[InviteFriendsSearchViewController alloc] init];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableController];
    self.searchController.searchResultsUpdater = self;
   //
    navHeight = self.navigationController.navigationBar.bounds.size.height + 20;
    self.searchController.searchBar.frame = CGRectMake(0, 4, self.view.bounds.size.width, 46);
    searchView = [[UIView alloc] initWithFrame:CGRectMake(0, navHeight, self.view.bounds.size.width, 52)];
    searchView.backgroundColor = [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1.0]; 
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0, 51, searchView.frame.size.width, 1.0);
    bottomBorder.backgroundColor = [UIColor darkGrayColor].CGColor;
    [searchView.layer addSublayer:bottomBorder];

    UIView *searchBar = [[UIView alloc] initWithFrame:CGRectMake(0, 4, self.view.bounds.size.width, 52 )];
    [searchBar addSubview:self.searchController.searchBar];
    [self.searchController.searchBar sizeToFit];
    HeaderGradientView *dropShadow = [[HeaderGradientView alloc] initWithFrame:CGRectMake(0, 0, searchView.bounds.size.width, 12.0)];
    [searchView addSubview:dropShadow];
    [searchView addSubview:searchBar];
    [self.view addSubview:searchView];
    
    CGFloat tableHeight = self.view.bounds.size.height - (navHeight + 52);
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navHeight + 52, self.view.bounds.size.width, tableHeight)];
    
    // self.tableView.tableHeaderView = self.searchController.searchBar;
    // self.tableView.tableHeaderView.backgroundColor = [UIColor whiteColor];
    self.resultsTableController.tableView.delegate = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    
    
    self.title = NSLocalizedString(@"INVITE FRIENDS", @"INVITE FRIENDS");
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1.0];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.navigationItem.hidesBackButton = YES;
    self.backButton = [[UIBarButtonItem alloc] init];
    [self.backButton setTitleTextAttributes:@{
                                         NSFontAttributeName: [UIFont fontWithName:@"fontello" size:26.0],
                                         NSForegroundColorAttributeName: [UIColor blackColor]
                                         } forState:UIControlStateNormal];
    if ([appDelegate.selectedView isEqualToString:@"home"]) {
        self.backButton.title = @"\uEA03";
    } else {
        self.backButton.title = @"\uE9F8";
    }
    self.backButton.target = self;
    self.backButton.action = @selector(backAction:);
    [self.navigationItem setLeftBarButtonItem:self.backButton];
    
    self.sendButton = [[UIBarButtonItem alloc] init];
    [self.sendButton setTitleTextAttributes:@{
                                         NSFontAttributeName: [UIFont fontWithName:@"fontello" size:26.0],
                                         NSForegroundColorAttributeName: [UIColor blackColor]
                                         } forState:UIControlStateNormal];
    self.sendButton.title = @"\uEA05";
    self.sendButton.target = self;
    self.sendButton.action = @selector(sendAction:);
    [self.navigationItem setRightBarButtonItem:self.sendButton];

    self.selectedContacts = [[NSMutableDictionary alloc] init];
    self.contacts = [Contact allContacts];
    self.flashView = [[FlashView alloc] initWithScreenWidth:self.view.bounds.size.width];
    self.flashView.hidden = YES;
    [self.navigationController.navigationBar addSubview:self.flashView];
    self.navigationController.navigationBarHidden = NO;

}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"flashMessage" object:nil];
}

- (void)showMessage
{
    if (appDelegate.alert.length > 1)
        [self.flashView showMessage:appDelegate.alert];
    appDelegate.alert = @"";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMessage) name:@"flashMessage" object:nil];
    // restore the searchController's active state
    if (self.searchControllerWasActive) {
        self.searchController.active = self.searchControllerWasActive;
        _searchControllerWasActive = NO;
        
        if (self.searchControllerSearchFieldWasFirstResponder) {
            [self.searchController.searchBar becomeFirstResponder];
            _searchControllerSearchFieldWasFirstResponder = NO;
        }
    }
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self requestAddressBookAccess];
    if ([appDelegate.user.status isEqualToString:@"beginer"] ||
        [appDelegate.user.status isEqualToString:@"peewee"]) {
        PopupView *invitePopup = [[PopupView alloc] init];
        [self.view addSubview:invitePopup];
        NSString *title = @"INVITE FRIENDS";
        NSString *message = @"Select your iPhone contacts (Android coming soon) to invite them to join you on Heylo.";
        [invitePopup showPopup:title message:message icon:@""];
    }
}

-(void)requestAddressBookAccess
{
    InviteFriendsViewController * __weak weakSelf = self;
    
    ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error)
                                             {
                                                 if (granted)
                                                 {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         [weakSelf accessGrantedForAddressBook];
                                                         
                                                     });
                                                 }
                                             });
}

// This method is called when the user has granted access to their address book data.
-(void)accessGrantedForAddressBook
{
    NSArray *rawRecords = [ABRecord abRecords];
    NSMutableArray *pnums = [[NSMutableArray alloc] init];
    for (ABRecord *abr in rawRecords) {
        for (NSDictionary *pnum in abr.phoneNumbers) {
            // NSLog(@"%@ %@ %@ %@",abr.firstName,abr.lastName,[pnum objectForKey:@"type"],[pnum objectForKey:@"number"]);
            NSString *isMember = @"no";
            if (abr.isMember) {
                isMember = @"yes";
               // NSLog(@"wtf %@ %@", abr.firstName, pnum);
            }
            NSDictionary *record = [[NSDictionary alloc]
                                    initWithObjects:@[abr.firstName,abr.lastName,[pnum objectForKey:@"type"],[pnum objectForKey:@"number"],isMember]
                                            forKeys:@[@"fname",@"lname",@"type",@"number",@"member"]];
            [pnums addObject:record];
        }
        
    }
    self.abContacts = pnums;
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - UISearchControllerDelegate

// Called after the search controller's search bar has agreed to begin editing or when
// 'active' is set to YES.
// If you choose not to present the controller yourself or do not implement this method,
// a default presentation is performed on your behalf.
//
// Implement this method if the default presentation is not adequate for your purposes.
//
- (void)presentSearchController:(UISearchController *)searchController {
    
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    // do something before the search controller is presented
    searchView.backgroundColor = [UIColor whiteColor];
    searchView.hidden = YES;
    CGFloat tableHeight = self.view.bounds.size.height - (navHeight);
    self.tableView.frame = CGRectMake(0, navHeight, self.view.bounds.size.width, tableHeight);
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    // do something after the search controller is presented
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    // self.searchController.searchBar.frame = CGRectMake(0, 4, self.view.bounds.size.width, 36);
    searchView.backgroundColor = [UIColor lightGrayColor];
    searchView.hidden = NO;
    CGFloat tableHeight = self.view.bounds.size.height - (navHeight + 52);
    self.tableView.frame = CGRectMake(0, navHeight + 52, self.view.bounds.size.width, tableHeight);

}

- (void)didDismissSearchController:(UISearchController *)searchController {
    // do something after the search controller is dismissed
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.abContacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    InviteFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[InviteFriendsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSDictionary *contact = [self.abContacts objectAtIndex:indexPath.row];
    // NSLog(@"%@ %@ %@ %@", [contact objectForKey:@"fname"], [contact objectForKey:@"lname"], [contact objectForKey:@"type"], [contact objectForKey:@"number"]);
    if ([[contact objectForKey:@"member"] isEqualToString:@"yes"]) {
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

// here we are the table view delegate for both our main table and filtered table, so we can
// push from the current navigation controller (resultsTableController's parent view controller
// is not this UINavigationController)
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *selectedContact = (tableView == self.tableView) ?
    self.abContacts[indexPath.row] : self.resultsTableController.filteredContacts[indexPath.row];
   // NSLog(@"%@ %@ %@ %@", [selectedContact objectForKey:@"fname"], [selectedContact objectForKey:@"lname"], [selectedContact objectForKey:@"type"], [selectedContact objectForKey:@"number"]);
    
    if (![[selectedContact objectForKey:@"member"] isEqualToString:@"yes"]) {
        // do nothing if already a member
        if ([self.selectedContacts objectForKey:[selectedContact objectForKey:@"number"]]) {
            [self.selectedContacts removeObjectForKey:[selectedContact objectForKey:@"number"]];
            if (self.selectedContacts.count < 1) {
                self.sendButton.enabled = NO;
            }
        } else {
            [self.selectedContacts setObject:selectedContact forKey:[selectedContact objectForKey:@"number"]];
            if (self.sendButton.enabled == NO) {
                self.sendButton.enabled = YES;
            }
        }
    }
    // restore the searchController's active state
    if (self.searchController.active) {
        self.searchController.active = NO;
        _searchControllerWasActive = NO;
        
        if (self.searchControllerSearchFieldWasFirstResponder) {
            [self.searchController.searchBar becomeFirstResponder];
            _searchControllerSearchFieldWasFirstResponder = NO;
        }
        if (![[selectedContact objectForKey:@"member"] isEqualToString:@"yes"]) {
            [self.tableView reloadData];
            NSInteger anIndex = [self.abContacts indexOfObject:selectedContact];
           // NSLog(@"row is %li section %li", (long)anIndex, (long)indexPath.section);
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:anIndex inSection:0]
                                  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        }
    } else {
        if (![[selectedContact objectForKey:@"member"] isEqualToString:@"yes"])
            [self.tableView reloadData];
    }
    if ([appDelegate.user.status isEqualToString:@"novice"] ||
        [appDelegate.user.status isEqualToString:@"intermediate"]) {
        PopupView *invitePopup = [[PopupView alloc] init];
        invitePopup.gotIt.tag = 2;
        invitePopup.hideButton.tag = 2;
        [self.view addSubview:invitePopup];
        NSString *title = @"SELECT FRIENDS";
        NSString *message = @"Continue selecting friends to invite to join HeyLo, and when finished tap the send button:";
        [invitePopup showPopup:title message:message icon:@"\uEA05"];

    }
}

- (void)reloadTable:(int)row
{
    
}

- (void)sendAction:(id)sender
{
    NSMutableArray *receipients = [[NSMutableArray alloc] init];
    NSArray *allKeys = [self.selectedContacts allKeys];
    for (NSString *key in allKeys) {
        [receipients addObject:key];
    }
    MFMessageComposeViewController *smsView = [[MFMessageComposeViewController alloc] init];
    [smsView setMessageComposeDelegate:self];
    if ([MFMessageComposeViewController canSendText]) {
        [smsView setRecipients:receipients];
        [smsView setBody:@""];
        [self presentViewController:smsView animated:YES completion:NULL];
    } else {
        NSLog(@"cannot send");
    }

   
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            // NSLog(@"canceled");
            break;
        case MessageComposeResultFailed:
            // NSLog(@"canceled");
            break;
        case MessageComposeResultSent:
            // NSLog(@"canceled");
            break;
            
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)dismissModal:(id)sender
{
    UIButton *clickedButton = (UIButton *)sender;
    if (clickedButton.tag == 2) {
        appDelegate.user.status = @"expert";
        [HeyloData updateUser:appDelegate.user];
    }
    infoView.hidden = YES;
}


- (IBAction)backAction:(id)sender
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    if ([appDelegate.selectedView isEqualToString:@"home"] || [appDelegate.selectedView isEqualToString:@"account"]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // update the filtered array based on the search text
    NSString *searchText = searchController.searchBar.text;
    NSMutableArray *searchResults = [self.abContacts mutableCopy];
    
    // strip out all the leading and trailing spaces
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // break up the search terms (separated by spaces)
    NSArray *searchItems = nil;
    if (strippedString.length > 0) {
        searchItems = [strippedString componentsSeparatedByString:@" "];
    }
    
    // build all the "AND" expressions for each value in the searchString
    //
    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    
    for (NSString *searchString in searchItems) {
        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
        NSExpression *lhs = [NSExpression expressionForKeyPath:@"fname"];
        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        lhs = [NSExpression expressionForKeyPath:@"lname"];
        rhs = [NSExpression expressionForConstantValue:searchString];
        finalPredicate = [NSComparisonPredicate
                          predicateWithLeftExpression:lhs
                          rightExpression:rhs
                          modifier:NSDirectPredicateModifier
                          type:NSContainsPredicateOperatorType
                          options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        // at this OR predicate to our master AND predicate
        NSCompoundPredicate *orMatchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
    }
    
    // match up the fields of the Product object
    NSCompoundPredicate *finalCompoundPredicate =
    [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    searchResults = [[searchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
    
    // hand over the filtered results to our search results table
    InviteFriendsSearchViewController *tableController = (InviteFriendsSearchViewController *)self.searchController.searchResultsController;
    tableController.filteredContacts = searchResults;
    tableController.selectedContacts = self.selectedContacts;
    [tableController.tableView reloadData];
}

@end
