//
//  FindFriendsViewController.m
//  notify
//
//  Created by Scott Parris on 4/17/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "FindFriendsViewController.h"
#import "AppDelegate.h"
#import "HeaderGradientView.h"
#import "User.h"
#import "Contact.h"
#import "HeyloData.h"
#import "InviteFriendsViewController.h"
#import "FindFriendsTableViewCell.h"

@interface FindFriendsViewController () {
    AppDelegate *appDelegate;
    UIView *activityView;
    UIView *inviteView;
    UIView *membersView;
    NSMutableData *theData;
    NSURLConnection *theConnection;
    NSMutableDictionary *recordContact;
    NSMutableDictionary *phoneRecord;
    NSMutableDictionary *recordPerson;
    NSArray *allPeople;
    NSString *documentsDirectory;
}

@property (nonatomic, strong) UIButton *findFriendsButton;
@property (nonatomic, strong) UIButton *inviteFriendsButton;
@property (nonatomic, strong) UIButton *inviteMoreButton;
@property (nonatomic, strong) UIButton *dismissInviteButton;
@property (nonatomic, strong) UIButton *dismissMembersButton;
@property (nonatomic, assign) ABAddressBookRef addressBook;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSArray *heyloMembers;
@property (nonatomic, strong) UITableView *membersTableView;


- (void)skipFriends:(id)sender;
- (void)findFriends:(id)sender;
- (void)dismissModals:(id)sender;
- (void)inviteFriends:(id)sender;
- (void)actionBackTo:(id)sender;

@end

@implementation FindFriendsViewController

static NSString *CellIdentifier = @"HeyloTableCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.view.backgroundColor = [UIColor whiteColor]; //[UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
    self.title = NSLocalizedString(@"FIND FRIENDS", @"FIND FRIENDS");
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor], NSForegroundColorAttributeName,
      [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:24],
      NSFontAttributeName, nil]];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] init];
    [doneButton setTitleTextAttributes:@{
                                         NSFontAttributeName: [UIFont fontWithName:@"fontello" size:26],
                                         NSForegroundColorAttributeName: [UIColor blackColor]
                                         } forState:UIControlStateNormal];
    doneButton.title = @"\uEA03";
    doneButton.target = self;
    doneButton.action = @selector(skipFriends:);
    [self.navigationItem setRightBarButtonItem:doneButton];
    
    if ([appDelegate.selectedView isEqualToString:@"send_card"] || [appDelegate.selectedView isEqualToString:@"account"]) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
        [backButton setTitleTextAttributes:@{
                                             NSFontAttributeName: [UIFont fontWithName:@"fontello" size:26.0],
                                             NSForegroundColorAttributeName: [UIColor blackColor]
                                             } forState:UIControlStateNormal];
        backButton.title = @"\uE9F8";
        backButton.target = self;
        backButton.action = @selector(actionBackTo:);
        [self.navigationItem setLeftBarButtonItem:backButton];
    }
    UIScreen *screen = [UIScreen mainScreen];
    HeaderGradientView *dropShadow = [[HeaderGradientView alloc] initWithFrame:CGRectMake(0, 64, screen.bounds.size.width, 12.0)];
    [self.view addSubview:dropShadow];
    
    float originY = (screen.bounds.size.height * 0.36)/2 + 25.0;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, originY, screen.bounds.size.width, 30.0)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:26];
    titleLabel.text = @"Find Your Friends";
    titleLabel.textColor = [UIColor grayColor];
    [self.view addSubview:titleLabel];
    
    originY = originY + 50.0;
    UILabel *instruction1 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, originY, screen.bounds.size.width, 20.0)];
    instruction1.textAlignment = NSTextAlignmentCenter;
    instruction1.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:18];
    instruction1.text = @"Add your contacts so you can";
    instruction1.textColor = [UIColor grayColor];
    [self.view addSubview:instruction1];

    originY = originY + 25.0;
    UILabel *instruction2 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, originY, screen.bounds.size.width, 20.0)];
    instruction2.textAlignment = NSTextAlignmentCenter;
    instruction2.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:18];
    instruction2.text = @"see who else is on Heylo and";
    instruction2.textColor = [UIColor grayColor];
    [self.view addSubview:instruction2];
    
    originY = originY + 25.0;
    UILabel *instruction3 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, originY, screen.bounds.size.width, 20.0)];
    instruction3.textAlignment = NSTextAlignmentCenter;
    instruction3.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:18];
    instruction3.text = @"send them messages";
    instruction3.textColor = [UIColor grayColor];
    [self.view addSubview:instruction3];
    
    
    UIImageView *friendsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, screen.bounds.size.height/2 + 30, screen.bounds.size.width, screen.bounds.size.height/2 - 60)];
    friendsImageView.image = [UIImage imageNamed:@"find_friends.png"];
    [self.view addSubview:friendsImageView];
    
    self.findFriendsButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, screen.bounds.size.height - 60, screen.bounds.size.width, 60.0)];
    [self.findFriendsButton setTitle:@"ADD CONTACTS" forState:UIControlStateNormal];
    self.findFriendsButton.titleLabel.font = [UIFont fontWithName:@"DIN Condensed" size:24];
    [self.findFriendsButton setBackgroundColor:[UIColor colorWithRed:57.0/255 green:181.0/255 blue:73.0/255 alpha:1.0]];
    [self.findFriendsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.findFriendsButton addTarget:self action:@selector(findFriends:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.findFriendsButton];
    
    activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen.bounds.size.width, screen.bounds.size.height)];
    activityView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:.5];
    activityView.layer.zPosition = 100;
    activityView.hidden = YES;
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(screen.bounds.size.width/2 - 10, screen.bounds.size.height/2 - 10, 20, 20)];
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [activityView addSubview:self.activityIndicator];
    [self.view addSubview:activityView];
    [self.activityIndicator startAnimating];
     
    
    inviteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen.bounds.size.width, screen.bounds.size.height)];
    inviteView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:.5];
    inviteView.layer.zPosition = 100;
    inviteView.hidden = YES;
    CGFloat marginX = screen.bounds.size.height * 0.2;
    UIView *inviteTextView = [[UIView alloc] initWithFrame:CGRectMake(30, marginX, screen.bounds.size.width -60, screen.bounds.size.height - marginX * 2)];
    inviteTextView.backgroundColor = [UIColor whiteColor];
    inviteTextView.layer.cornerRadius = 10.0;
    
    self.dismissInviteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.dismissInviteButton.titleLabel.font = [UIFont fontWithName:@"fontello" size:18];
    self.dismissInviteButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.dismissInviteButton setTitle:@" \uEA08" forState:UIControlStateNormal]; //  E8B2  E8E7 EA07 EA08
    [self.dismissInviteButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.dismissInviteButton.tag = 1;
    [self.dismissInviteButton addTarget:self action:@selector(dismissModals:) forControlEvents:UIControlEventTouchUpInside];
    
    [inviteTextView addSubview:self.dismissInviteButton];

    
    UILabel *inviteHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, inviteTextView.bounds.size.width -60, 55)];
    inviteHeaderLabel.textAlignment = NSTextAlignmentLeft;
    inviteHeaderLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:20];
    inviteHeaderLabel.textColor = [UIColor darkGrayColor];
    inviteHeaderLabel.text = @"FRIENDS ON HEYLO";
    [inviteTextView addSubview:inviteHeaderLabel];
    
    UIView *inviteMainView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, inviteTextView.bounds.size.width, inviteTextView.bounds.size.height -110)];
    CALayer* inviteLayer = [inviteMainView layer];
    CALayer *topBorder = [CALayer layer];
    topBorder.borderColor = [UIColor lightGrayColor].CGColor;
    topBorder.borderWidth = 1;
    topBorder.frame = CGRectMake(-1, -1, inviteLayer.frame.size.width, 1);
    [topBorder setBorderColor:[UIColor blackColor].CGColor];
    [inviteLayer addSublayer:topBorder];
    
    CGFloat marginY = inviteMainView.bounds.size.height *0.25;
    UILabel *inviteLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, marginY, inviteTextView.bounds.size.width, 20)];
    inviteLabel1.textAlignment = NSTextAlignmentCenter;
    inviteLabel1.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:18];
    inviteLabel1.textColor = [UIColor darkGrayColor];
    inviteLabel1.text = @"Hmmm... Looks like you";
    [inviteMainView addSubview:inviteLabel1];
    marginY += 25;
    UILabel *inviteLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, marginY, inviteTextView.bounds.size.width, 20)];
    inviteLabel2.textAlignment = NSTextAlignmentCenter;
    inviteLabel2.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:18];
    inviteLabel2.textColor = [UIColor darkGrayColor];
    inviteLabel2.text = @"don't have any friends on";
    [inviteMainView addSubview:inviteLabel2];
    marginY += 25;
    UILabel *inviteLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(0, marginY, inviteTextView.bounds.size.width, 20)];
    inviteLabel3.textAlignment = NSTextAlignmentCenter;
    inviteLabel3.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:18];
    inviteLabel3.textColor = [UIColor darkGrayColor];
    inviteLabel3.text = @"Heylo yet.";
    [inviteMainView addSubview:inviteLabel3];
    marginY += 35;
    UILabel *inviteLabel4 = [[UILabel alloc] initWithFrame:CGRectMake(0, marginY, inviteTextView.bounds.size.width, 20)];
    inviteLabel4.textAlignment = NSTextAlignmentCenter;
    inviteLabel4.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:18];
    inviteLabel4.textColor = [UIColor darkGrayColor];
    inviteLabel4.text = @"You should invite some!";
    [inviteMainView addSubview:inviteLabel4];
    [inviteTextView addSubview:inviteMainView];

    self.inviteFriendsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, inviteTextView.bounds.size.height - 60, inviteTextView.bounds.size.width, 60.0)];
    [self.inviteFriendsButton setTitle:@"INVITE FRIENDS" forState:UIControlStateNormal];
    [self.inviteFriendsButton setBackgroundColor:[UIColor clearColor]];
    self.inviteFriendsButton.titleLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:18];
    [self.inviteFriendsButton setTitleColor:[UIColor colorWithRed:39.0/255 green:170.0/255 blue:255.0/255 alpha:1.0] forState:UIControlStateNormal];
    [self.inviteFriendsButton addTarget:self action:@selector(inviteFriends:) forControlEvents:UIControlEventTouchUpInside];
    [inviteTextView addSubview:self.inviteFriendsButton];
    
    [inviteView addSubview:inviteTextView];
    [self.view addSubview:inviteView];
    
    
    membersView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen.bounds.size.width, screen.bounds.size.height)];
    membersView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:.5];
    membersView.layer.zPosition = 100;
    membersView.hidden = YES;
    
    UIView *membersMainView = [[UIView alloc] initWithFrame:CGRectMake(30, marginX, screen.bounds.size.width -60, screen.bounds.size.height - marginX * 2)];
    membersMainView.backgroundColor = [UIColor whiteColor];
    membersMainView.layer.cornerRadius = 10.0;
    
    self.dismissMembersButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.dismissMembersButton.titleLabel.font = [UIFont fontWithName:@"fontello" size:18];
    self.dismissMembersButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.dismissMembersButton setTitle:@" \uEA08" forState:UIControlStateNormal]; //  E8B2  E8E7 EA07 EA08
    [self.dismissMembersButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.dismissMembersButton.tag = 2;
    [self.dismissMembersButton addTarget:self action:@selector(dismissModals:) forControlEvents:UIControlEventTouchUpInside];
    [membersMainView addSubview:self.dismissMembersButton];
    
    UILabel *membersHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, inviteTextView.bounds.size.width -60, 55)];
    membersHeaderLabel.textAlignment = NSTextAlignmentLeft;
    membersHeaderLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:20];
    membersHeaderLabel.textColor = [UIColor darkGrayColor];
    membersHeaderLabel.text = @"FRIENDS ON HEYLO";
    [membersMainView addSubview:membersHeaderLabel];
    
    self.membersTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, membersMainView.bounds.size.width, membersMainView.bounds.size.height -110)];
    self.membersTableView.dataSource = self;
    self.membersTableView.delegate = self;
/**
    CALayer *membersLayer = [self.membersTableView layer];
    CALayer *topMembersBorder = [CALayer layer];
    topMembersBorder.borderColor = [UIColor lightGrayColor].CGColor;
    topMembersBorder.borderWidth = 1;
    topMembersBorder.frame = CGRectMake(-1, -1, membersLayer.frame.size.width, 1);
    [topMembersBorder setBorderColor:[UIColor blackColor].CGColor];
    [membersLayer addSublayer:topMembersBorder];

    CALayer *bottomMembersBorder = [CALayer layer];
    bottomMembersBorder.borderColor = [UIColor lightGrayColor].CGColor;
    bottomMembersBorder.borderWidth = 1;
    bottomMembersBorder.frame = CGRectMake(-1, membersLayer.frame.size.height-1, bottomMembersBorder.frame.size.width, 1);
    [bottomMembersBorder setBorderColor:[UIColor blackColor].CGColor];
    [membersLayer addSublayer:bottomMembersBorder];
 
*/
    [membersMainView addSubview:self.membersTableView];
    
    self.inviteMoreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, inviteTextView.bounds.size.height - 60, inviteTextView.bounds.size.width, 60.0)];
    [self.inviteMoreButton setTitle:@"INVITE MORE FRIENDS" forState:UIControlStateNormal];
    [self.inviteMoreButton setBackgroundColor:[UIColor clearColor]];
    self.inviteMoreButton.titleLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:18];
    [self.inviteMoreButton setTitleColor:[UIColor colorWithRed:39.0/255 green:170.0/255 blue:255.0/255 alpha:1.0] forState:UIControlStateNormal];
    [self.inviteMoreButton addTarget:self action:@selector(inviteFriends:) forControlEvents:UIControlEventTouchUpInside];
    [membersMainView addSubview:self.inviteMoreButton];

    
    [membersView addSubview:membersMainView];
    
    [self.view addSubview:membersView];
 
}

- (void)viewDidAppear:(BOOL)animated
{
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        [self accessGrantedForAddressBook];
    } else {
        [self requestAddressBookAccess];
    }
}

- (void)skipFriends:(id)sender
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    appDelegate.selectedView = @"home";
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)findFriends:(id)sender
{
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        [self accessGrantedForAddressBook];
    } else {
        [self requestAddressBookAccess];
    }
}


// Prompt the user for access to their Address Book data
-(void)requestAddressBookAccess
{
    FindFriendsViewController * __weak weakSelf = self;
    
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



-(void)accessGrantedForAddressBook
{
    
    NSLog(@"Access granted ++++++++");
    activityView.hidden = NO;
    [self.activityIndicator startAnimating];
    // Creates a dictionary of existing members
    recordContact = [[NSMutableDictionary alloc] init];
    for (Contact *c in [Contact allContacts]) {
        [recordContact setObject:c.contactId forKey:c.abRecord];
        // NSLog(@"contact: %@ %@ %@",c.heyloId, c.firstName, c.abRecord);
    }
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\(|\\)|\\-|\\s+"
                                                                           options:0
                                                                             error:NULL];
    
    
    NSMutableString *phoneStr = [[NSMutableString alloc] init];
    // To get a record from a phone
    phoneRecord = [[NSMutableDictionary alloc] init];
    // to get the index
    recordPerson = [[NSMutableDictionary alloc] init];
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    allPeople = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBookRef));
    for (int i= 0; i < [allPeople count]; i++) {
        ABRecordRef person = CFBridgingRetain([allPeople objectAtIndex:i]);
        NSNumber *recordId = [NSNumber numberWithInteger:ABRecordGetRecordID(person)];
        // Check if record exists and add to web query if not
        
        NSLog(@"exists: %@ %@",recordId,  [recordContact objectForKey:recordId]);
        if (![recordContact objectForKey:recordId]) {
            [recordPerson setObject:[NSNumber numberWithInt:i] forKey:recordId];
            ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            CFIndex PhoneCount = ABMultiValueGetCount(phones);
            for (int k  = 0; k < PhoneCount; k++) {
                NSString *pnum = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phones, k);
                NSString *phoneNum = [regex stringByReplacingMatchesInString:pnum options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [pnum length]) withTemplate:@""];
                if (![phoneRecord objectForKey:phoneNum]) {
                    [phoneRecord setObject:recordId forKey:phoneNum];
                    [phoneStr appendFormat:@"\"%@\",",phoneNum];
                }
            }
        }
    }
    
    // Web query
    NSMutableString *jsonPostBody = [NSMutableString stringWithFormat:@"{\"user_id\":\"%@\",\"contacts\":[", appDelegate.user.heyloId];
    [jsonPostBody appendString:[phoneStr substringToIndex:[phoneStr length] -1]];
    [jsonPostBody appendString:@"]}"];
    
    NSLog(@"json: %@",jsonPostBody);
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonPostBody length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/userSynch", BASE_URL, API_VERSION]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:[jsonPostBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [theConnection start];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"wtf %@",appDelegate.heyloData.maxContactId);
    
    NSMutableArray *unsorted = [[NSMutableArray alloc] init];
    NSError *error;
    NSLog(@"====================\nFinally got a response");
    NSDictionary *results = [NSJSONSerialization
                             JSONObjectWithData:theData
                             options:NSJSONReadingMutableLeaves
                             error:&error];
    
    NSString *succesStr = [results objectForKey:@"success"];
    if ([succesStr isEqualToString:@"true"]) {
        //     {"success":"true","match":[{"orig":"14153057744","id":"530d31a6f36837d754000001","phone_number":"+14153057744"}]}
        int i = 0;
        NSArray *members = [results objectForKey:@"match"];
        for (NSDictionary *match in members) {
            NSString *pnum = [match objectForKey:@"orig"];
            NSString *hid = [match objectForKey:@"id"];
            if (![hid isEqualToString:appDelegate.user.heyloId]) {
                if ([phoneRecord objectForKey:pnum]) {
                    NSNumber *recordId = [phoneRecord objectForKey:pnum];
                    ABRecordRef person = CFBridgingRetain([allPeople objectAtIndex:[[recordPerson objectForKey:recordId] integerValue]]);
                    // AB Created date used with first name to sync address book (incase restored from backup) - stored as integer in sqlite
                    // To retrieve: NSDate *createdDate = [NSDate dateWithTimeIntervalSince1970:contact.createdDate];
                    NSDate *creationDate = (__bridge NSDate*) ABRecordCopyValue(person, kABPersonCreationDateProperty);
                    NSTimeInterval time_seconds = [creationDate timeIntervalSince1970];
                    NSNumber *createdDate = [NSNumber numberWithDouble:time_seconds];
                    // NSString *firstName = (__bridge NSString *)(ABRecordCopyValue (person, kABPersonFirstNameProperty));
                    // NSString *lastName  = (__bridge NSString *)(ABRecordCopyValue (person, kABPersonLastNameProperty));
                    NSString *firstName = [match objectForKey:@"first_name"];
                    NSString *lastName = [match objectForKey:@"last_name"];
                    NSString *avatar = @"default_avatar";
                    if (ABPersonHasImageData(person)) {
                        NSData *data = (__bridge NSData*)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
                        avatar = [NSString stringWithFormat:@"%@.png",hid];
                        NSString *path = [documentsDirectory stringByAppendingPathComponent:avatar];
                        [data writeToFile:path atomically:YES];
                    }
                    // NSString *hid = [heyloIds objectAtIndex:i];
                    // Temp placeholder
                    NSNumber *contactId = appDelegate.heyloData.setMaxContactId;
                    Contact *contact = [[Contact alloc] initWithId:contactId abRecord:recordId heyloId:hid phoneNumber:pnum firstName:firstName lastName:lastName avatar:avatar activityDate:createdDate createdDate:createdDate];
                    [HeyloData createContact:contact];
                    [unsorted addObject:contact];
                }
                i++;
            }
        }
        NSLog(@"====================\nstop animating and present modal");
        [self.activityIndicator stopAnimating];
        activityView.hidden = YES;
        // stop animating
        if (unsorted.count > 0) {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            self.heyloMembers = [unsorted sortedArrayUsingDescriptors:sortDescriptors];;
            [self.membersTableView reloadData];
            membersView.hidden = NO;
        } else {
            inviteView.hidden = NO;
        }
    } else {
         NSLog(@"====================\nBad response");
    }
    
    activityView.hidden = YES;
    [self.activityIndicator stopAnimating];
    theConnection = nil;
    theData = nil;
}
    
    

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    theData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    theConnection = nil;
    theData = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [theData appendData:data];
}


- (void)actionBackTo:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)dismissModals:(id)sender
{
    inviteView.hidden = YES;
    membersView.hidden = YES;
}

- (void)inviteFriends:(id)sender
{
    appDelegate.selectedView = @"home";
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    InviteFriendsViewController *inviteViewController = [[InviteFriendsViewController alloc] init];
    [self.navigationController pushViewController:inviteViewController animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.heyloMembers.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FindFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FindFriendsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    Contact *contact = self.heyloMembers[indexPath.row];
    NSLog(@"%@", contact.avatar);
    if ([contact.avatar isEqualToString:@"default_avatar"]) {
        cell.thumbnail.image = [UIImage imageNamed:@"default_avatar"];
    } else {
        NSString *path = [documentsDirectory stringByAppendingPathComponent:contact.avatar];
        cell.thumbnail.image = [UIImage imageWithContentsOfFile:path];
    }
    cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
