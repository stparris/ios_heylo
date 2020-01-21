//
//  SendCardViewController.m
//  notify
//
//  Created by Scott Parris on 4/26/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "SendCardViewController.h"
#import "CardCustomizeViewController.h"
#import "AppDelegate.h"
#import "CardImage.h"
#import "Contact.h"
#import "InviteFriendsViewController.h"
#import "FindFriendsTableViewCell.h"
#import "HeaderGradientView.h"
#import "SendCardTableViewCell.h"
#import "Conversation.h"
#import "HeyloData.h"
#import "Message.h"
#import "FlashView.h"
#define MEMBERS_COUNT 20

@interface SendCardViewController () {
    AppDelegate *appDelegate;
    UIView *messageView;
    UIImageView *messageImage;
    UIColor *heyloGray;
    NSString *documentsDirectory;
    NSMutableDictionary *recipients;
    UILabel *recipientLabel;
    UIView *sentBackground;
    UIView *sentView;
    NSMutableData *theData;
    NSURLConnection *theConnection;
    NSMutableDictionary *recordContact;
    NSMutableDictionary *phoneRecord;
    NSMutableDictionary *recordPerson;
    NSArray *allPeople;
    UIView *addedMembersView;
    UIView *activityView;
    NSArray *alphaList;
    UIView *alphaView;
    CGFloat membersHeight;
    CGFloat membersWidth;
    CGFloat alphaWidth;
    
}

@property (nonatomic, strong) UITextView *messageText;
@property (nonatomic, strong) UIView *toView;
@property (nonatomic, strong) UIButton *friendsButton;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *sentButton;
@property (nonatomic, strong) UIButton *recentButton;
@property (nonatomic, strong) UIButton *abcde;
@property (nonatomic, strong) UIButton *fghij;
@property (nonatomic, strong) UIButton *klmno;
@property (nonatomic, strong) UIButton *pqrst;
@property (nonatomic, strong) UIButton *uvwxyz;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *members;

@property (nonatomic, strong) UITableView *alphaTable;

@property (nonatomic, assign) ABAddressBookRef addressBook;
@property (nonatomic, strong) NSArray *addedMembers;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UITableView *addedTableView;
@property (nonatomic, strong) UIButton *dismissMembersButton;
@property (nonatomic, strong) UIButton *inviteMoreButton;
@property (nonatomic, strong) FlashView *flashView;

- (void)sortRecent:(id)sender;
- (void)actionCustomize:(id)sender;
- (void)actionContacts:(id)sender;
- (void)inviteFriends:(id)sender;
- (void)actionSend:(id)sender;
- (void)actionSent:(id)sender;
- (void)dismissFriends:(id)sender;
- (void)showMessage;

@end

@implementation SendCardViewController

static NSString *CellIdentifier = @"HeyloTableCell";
static NSString *addedCellIdentifier = @"addedTableCell";
static NSString *alphaCellIdentifier = @"alphaCellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    recipients = [[NSMutableDictionary alloc] init];
    heyloGray = [[UIColor alloc] initWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
    self.navigationController.navigationBarHidden = NO;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.view.backgroundColor = [UIColor whiteColor];
    self.members = [Contact allContacts];

    UIScreen *screen = [UIScreen mainScreen];
    
    self.title = NSLocalizedString(@"SHARE POSTCARD", @"SHARE POSTCARD");
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor], NSForegroundColorAttributeName,
      [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:24],
      NSFontAttributeName, nil]];

    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    [backButton setTitleTextAttributes:@{
                                         NSFontAttributeName: [UIFont fontWithName:@"fontello" size:26.0],
                                         NSForegroundColorAttributeName: [UIColor blackColor]
                                         } forState:UIControlStateNormal];
    backButton.title = @"\uE9F8";
    backButton.target = self;
    backButton.action = @selector(actionCustomize:);
    [self.navigationItem setLeftBarButtonItem:backButton];

    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] init];
    [homeButton setTitleTextAttributes:@{
                                         NSFontAttributeName: [UIFont fontWithName:@"fontello" size:26],
                                         NSForegroundColorAttributeName: [UIColor blackColor]
                                         } forState:UIControlStateNormal];
    homeButton.title = @"\uEA03";
    homeButton.target = self;
    homeButton.action = @selector(goHome:);
    [self.navigationItem setRightBarButtonItem:homeButton];

    
    HeaderGradientView *dropShadow = [[HeaderGradientView alloc] initWithFrame:CGRectMake(0, 64, screen.bounds.size.width, 12.0)];
    [self.view addSubview:dropShadow];
    CGFloat msgHeight = screen.bounds.size.height * 0.18;
    messageView = [[UIView alloc] initWithFrame:CGRectMake(0, 72, screen.bounds.size.width, msgHeight)];
    messageView.backgroundColor = [UIColor whiteColor];
    
    CGFloat imageSide = screen.bounds.size.width/4 - 10;
    
    UIView *imagePlace = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, imageSide, imageSide)];
    imagePlace.backgroundColor = [UIColor lightGrayColor];
    messageImage = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, imageSide -2, imageSide -2)];
    messageImage.image = self.cardImage;
    messageImage.layer.masksToBounds = YES;
    messageImage.layer.borderColor = [UIColor whiteColor].CGColor;
    messageImage.layer.borderWidth = 3;
    
    
    self.messageText = [[UITextView alloc] initWithFrame:CGRectMake(imageSide + 20, 10, screen.bounds.size.width - (imageSide + 30), imageSide)];
    [self.messageText setDelegate:self];
    self.messageText.text = @"Write comment...";
    self.messageText.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:14];
    [self.messageText setReturnKeyType: UIReturnKeyDone];
    self.messageText.textColor = [UIColor lightGrayColor];
    

    [messageView addSubview:self.messageText];
    [imagePlace addSubview:messageImage];
    [messageView addSubview:imagePlace];
    [self.view addSubview:messageView];
    
    
    CGFloat originY = 68 + msgHeight;
    self.toView = [[UIView alloc] initWithFrame:CGRectMake(0, originY, screen.bounds.size.width, msgHeight * 0.4)];
    self.toView.backgroundColor = heyloGray;
   
    
    CALayer* toLayer = [self.toView layer];
    CALayer *topBorder = [CALayer layer];
    topBorder.borderWidth = 1;
    topBorder.frame = CGRectMake(-1, -1, toLayer.frame.size.width, 1);
    [topBorder setBorderColor:[UIColor grayColor].CGColor];
    [toLayer addSublayer:topBorder];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderWidth = 1;
    bottomBorder.frame = CGRectMake(-1,toLayer.frame.size.height -1, toLayer.frame.size.width, 1);
    [bottomBorder setBorderColor:[UIColor grayColor].CGColor];
    [toLayer addSublayer:bottomBorder];
    UILabel *toLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, self.toView.bounds.size.height/2 -10, 20, 20)];
    toLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:14];
    toLabel.text = @"To:";
    [self.toView addSubview:toLabel];
    
    recipientLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, self.toView.bounds.size.height/2 -10,self.toView.bounds.size.width - 40, 20)];
    recipientLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:14];
    recipientLabel.text = @"Select some friends...";
    recipientLabel.textColor = [UIColor grayColor];
    [self.toView addSubview:recipientLabel];
    [self.view addSubview:self.toView];
    
    originY += msgHeight * 0.4;
    CGFloat alphaY = originY;
    CGFloat alphaHeight = 18;
    alphaWidth = screen.bounds.size.width * 0.1;
    self.recentButton = [[UIButton alloc] initWithFrame:CGRectMake(0, originY, screen.bounds.size.width - alphaWidth, 18)];
    CALayer *recentLayer = [self.recentButton layer];
    CALayer *recentBorder = [CALayer layer];
    recentBorder.borderWidth = 1;
    recentBorder.frame = CGRectMake(-1,recentLayer.frame.size.height -1, recentLayer.frame.size.width, 1);
    [recentBorder setBorderColor:[UIColor grayColor].CGColor];
    [recentLayer addSublayer:recentBorder];

    UILabel *recentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 3, self.recentButton.bounds.size.width -20, 14)];
    recentLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:12];
    recentLabel.textAlignment = NSTextAlignmentLeft;
    recentLabel.textColor = [UIColor grayColor];
    recentLabel.text = @"RECENT";
    [self.recentButton addSubview:recentLabel];
    [self.recentButton setBackgroundColor:heyloGray];
    [self.recentButton addTarget:self action:@selector(sortRecent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.recentButton];
    if (self.members.count < MEMBERS_COUNT) {
        self.recentButton.hidden = YES;
        membersWidth = screen.bounds.size.width;
    } else {
        membersWidth = screen.bounds.size.width - alphaWidth;
        originY += 18;
    }
    
    
    CGFloat rowHeight = msgHeight/2;
    alphaHeight += rowHeight;
    UIView *friendView = [[UIView alloc] initWithFrame:CGRectMake(0, originY, membersWidth, rowHeight)];
    friendView.backgroundColor = heyloGray;
    CALayer *friendLayer = [friendView layer];
    CALayer *friendBorder = [CALayer layer];
    friendBorder.borderWidth = 1;
    friendBorder.frame = CGRectMake(-1,friendLayer.frame.size.height -1, friendLayer.frame.size.width, 1);
    [friendBorder setBorderColor:[UIColor grayColor].CGColor];
    [friendLayer addSublayer:friendBorder];

    
    CGFloat friendY = rowHeight/2;
    self.friendsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, friendY - 10, membersWidth, 20)];
    UILabel *plusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,0,20,20)];
    plusLabel.font = [UIFont fontWithName:@"fontello" size:20];
    plusLabel.text = @"\uE8E9";
    [self.friendsButton addTarget:self action:@selector(actionContacts:) forControlEvents:UIControlEventTouchUpInside];
    [self.friendsButton addSubview:plusLabel];
    
    
    UILabel *friendLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, self.friendsButton.bounds.size.width - 70, 20)];
    friendLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:20];
    friendLabel.text = @"ADD FRIENDS";
    friendLabel.textColor = [UIColor darkGrayColor];
    [self.friendsButton addSubview:friendLabel];
    
    UILabel *chevLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.friendsButton.bounds.size.width - 30, 0,20,20)];
    chevLabel.font = [UIFont fontWithName:@"fontello" size:20];
    chevLabel.text = @"\uE9AC";
    [self.friendsButton addSubview:chevLabel];

    [friendView addSubview:self.friendsButton];
    [self.view addSubview:friendView];
    
    originY += rowHeight;
    CGFloat tableHeight = screen.bounds.size.height - originY - 60;
    alphaHeight += tableHeight;

    if (self.members.count < MEMBERS_COUNT) {
        membersWidth = screen.bounds.size.width;
        membersHeight = screen.bounds.size.height - originY - 60;
    } else {
        membersWidth = screen.bounds.size.width - alphaWidth;
        membersHeight = screen.bounds.size.height - originY - 60;
    }
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, originY, membersWidth, membersHeight)];
    self.tableView.rowHeight = rowHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = heyloGray;
    [self.view addSubview:self.tableView];

    alphaView = [[UIView alloc] initWithFrame:CGRectMake(self.tableView.bounds.size.width, alphaY, alphaWidth, alphaHeight)];
    alphaView.backgroundColor = heyloGray;
    
    alphaList = [@"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z" componentsSeparatedByString:@" "];
    
    self.alphaTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 5, alphaWidth, alphaHeight - 10)];
    self.alphaTable.rowHeight = self.alphaTable.bounds.size.height/26;
    self.alphaTable.dataSource = self;
    self.alphaTable.delegate = self;
    self.alphaTable.backgroundColor = heyloGray;
    self.alphaTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.alphaTable.scrollEnabled = NO;
    [alphaView addSubview:self.alphaTable];
    
    [self.view addSubview:alphaView];
    
    
    
    if (self.members.count < MEMBERS_COUNT) {
        alphaView.hidden = YES;
    }
    
    self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, screen.bounds.size.height - 60, screen.bounds.size.width, 60.0)];
    [self.sendButton setTitle:@"SEND" forState:UIControlStateNormal];
    self.sendButton.titleLabel.font = [UIFont fontWithName:@"DIN Condensed" size:24];
    [self.sendButton setBackgroundColor:[UIColor colorWithRed:57.0/255 green:181.0/255 blue:73.0/255 alpha:1.0]];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.sendButton addTarget:self action:@selector(actionSend:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sendButton];
    
    sentBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0,screen.bounds.size.width, screen.bounds.size.height)];
    sentBackground.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:.5];
    
    sentView = [[UIView alloc] initWithFrame:CGRectMake(screen.bounds.size.width/2 - 34, screen.bounds.size.height/2 - 60, 88, 120)];
    sentView.backgroundColor = [UIColor blackColor];
    
    UILabel *airplaneLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 48, 48)];
    airplaneLabel.font = [UIFont fontWithName:@"fontello" size:48.0];
    airplaneLabel.textColor = [UIColor whiteColor];
    airplaneLabel.text = @"\uEA05";
    [sentView addSubview:airplaneLabel];
    
    UILabel *okLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, sentView.bounds.size.width, 20)];
    okLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:18];
    okLabel.textAlignment = NSTextAlignmentCenter;
    okLabel.text = @"SENT!";
    okLabel.textColor = [UIColor whiteColor];
    [sentView addSubview:okLabel];
    [sentBackground addSubview:sentView];

    self.sentButton = [[UIButton alloc] initWithFrame:sentBackground.frame];
    [self.sentButton addTarget:self action:@selector(actionSent:) forControlEvents:UIControlEventTouchUpInside];
    self.sentButton.backgroundColor = [UIColor clearColor];
    self.sentButton.layer.zPosition = 100;
    [sentBackground addSubview:self.sentButton];

    [self.view addSubview:sentBackground];
    sentBackground.hidden = YES;
    
    addedMembersView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen.bounds.size.width, screen.bounds.size.height)];
    addedMembersView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:.5];
    addedMembersView.layer.zPosition = 100;
    addedMembersView.hidden = YES;
    
    // New Heylo Memebers
    CGFloat marginX = screen.bounds.size.height * 0.2;
    UIView *membersMainView = [[UIView alloc] initWithFrame:CGRectMake(30, marginX, screen.bounds.size.width -60, screen.bounds.size.height - marginX * 2)];
    membersMainView.backgroundColor = [UIColor whiteColor];
    membersMainView.layer.cornerRadius = 10.0;
    
    self.dismissMembersButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.dismissMembersButton.titleLabel.font = [UIFont fontWithName:@"fontello" size:14 ];
    self.dismissMembersButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.dismissMembersButton setTitle:@" \uEA08" forState:UIControlStateNormal]; //  E8B2  E8E7 EA07 EA08
    [self.dismissMembersButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.dismissMembersButton.tag = 2;
    [self.dismissMembersButton addTarget:self action:@selector(dismissFriends:) forControlEvents:UIControlEventTouchUpInside];
    [membersMainView addSubview:self.dismissMembersButton];
    
    UILabel *membersHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, membersMainView.bounds.size.width -60, 55)];
    membersHeaderLabel.textAlignment = NSTextAlignmentLeft;
    membersHeaderLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:20];
    membersHeaderLabel.textColor = [UIColor darkGrayColor];
    membersHeaderLabel.text = @"ADDED FRIENDS";
    [membersMainView addSubview:membersHeaderLabel];
    
    self.addedTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, membersMainView.bounds.size.width, membersMainView.bounds.size.height -110)];
    self.addedTableView.dataSource = self;
    self.addedTableView.delegate = self;
    
    [membersMainView addSubview:self.addedTableView];
    
    self.inviteMoreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, membersMainView.bounds.size.height - 60, membersMainView.bounds.size.width, 60.0)];
    [self.inviteMoreButton setTitle:@"INVITE MORE FRIENDS" forState:UIControlStateNormal];
    [self.inviteMoreButton setBackgroundColor:[UIColor clearColor]];
    self.inviteMoreButton.titleLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:18];
    [self.inviteMoreButton setTitleColor:[UIColor colorWithRed:39.0/255 green:170.0/255 blue:255.0/255 alpha:1.0] forState:UIControlStateNormal];
    [self.inviteMoreButton addTarget:self action:@selector(inviteFriends:) forControlEvents:UIControlEventTouchUpInside];
    [membersMainView addSubview:self.inviteMoreButton];
    
    
    [addedMembersView addSubview:membersMainView];
    
    [self.view addSubview:addedMembersView];

    activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen.bounds.size.width, screen.bounds.size.height)];
    activityView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:.5];
    activityView.layer.zPosition = 100;
    activityView.hidden = YES;
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(screen.bounds.size.width/2 - 10, screen.bounds.size.height/2 - 10, 20, 20)];
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [activityView addSubview:self.activityIndicator];
    [self.view addSubview:activityView];
    [self.activityIndicator startAnimating];
    
    self.flashView = [[FlashView alloc] initWithScreenWidth:self.view.bounds.size.width];
    self.flashView.hidden = YES;
    [self.navigationController.navigationBar addSubview:self.flashView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"flashMessage" object:nil];
    self.members = [Contact allContacts];
    if (self.members.count < MEMBERS_COUNT) {
        self.recentButton.hidden = YES;
    }
    
    [self.tableView reloadData];
}

- (void)actionSent:(id)sender
{
    sentBackground.hidden = YES;
    appDelegate.selectedView = @"backToHome";
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)showMessage
{
    if (appDelegate.alert.length > 1)
        [self.flashView showMessage:appDelegate.alert];
    appDelegate.alert = @"";
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMessage) name:@"flashMessage" object:nil];
    
}

- (void)sortRecent:(id)sender
{
    NSArray *unsorted = self.members;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"activityDate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    self.members = [unsorted sortedArrayUsingDescriptors:sortDescriptors];
    [self.tableView reloadData];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (void)actionCustomize:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)actionContacts:(id)sender
{
    [self requestAddressBookAccess];
}

- (void)dismissFriends:(id)sender
{
    addedMembersView.hidden = YES;
    [self.tableView reloadData];
}

- (void)inviteFriends:(id)sender
{
    addedMembersView.hidden = YES;
    appDelegate.selectedView = @"send_card";
    InviteFriendsViewController *friendsView = [[InviteFriendsViewController alloc] init];
    [self.navigationController pushViewController:friendsView animated:YES];
}

- (void)actionSend:(id)sender
{
    NSArray *keys = [recipients allKeys];
    if (keys.count > 0) {
        NSMutableArray *unsorted = [[NSMutableArray alloc] init];
        NSMutableDictionary *myself = [[NSMutableDictionary alloc] init];
        for (NSString *key in keys) {
            Contact *c = [recipients objectForKey:key];
            [unsorted addObject:c];
            if ([appDelegate.user.heyloId isEqualToString:c.heyloId]) {
                [myself setObject:c forKey:@"myselfIncluded"];
            }
        }
        if (![myself objectForKey:@"myselfIncluded"]) {
            [unsorted addObject:appDelegate.myself];
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray *contacts = [unsorted sortedArrayUsingDescriptors:sortDescriptors];
        NSString *thread = @""; //[HeyloData getThreadFromContacts:contacts];
        NSString *contactStr = @"";
        for (Contact *c in contacts) {
            NSString *name = c.firstName;
            if (c.lastName.length > 0)
                name = [NSString stringWithFormat:@"%@ %@", name, c.lastName];
            contactStr = [contactStr stringByAppendingFormat:@"%@^$&",name];
            thread = [thread stringByAppendingFormat:@"%@,",c.heyloId];
        }
        
        NSString *message = @"";
        if (![self.messageText.text isEqualToString:@"Write comment..."]) {
            message = self.messageText.text;
        }
        contactStr = [contactStr substringToIndex:[contactStr length] - 3];
        thread = [thread substringToIndex:[thread length] - 1];
        // NSLog(@"url %@ l %lu %@", self.cardURL, (unsigned long)self.cardURL.length, contactStr);
        Conversation *conversation = [Conversation findOrCreateWithThread:thread
                                                         andContactString:contactStr
                                                              andImageUrl:self.cardURL
                                                                setUnread:NO];
        [Message createWithConversation:conversation
                             andContact:appDelegate.myself
                            andImageUrl:self.cardURL
                             andMessage:message
                                andDate:[HeyloData getTimestamp]
                             isIncoming:NO];
        sentBackground.hidden = NO;
        [sentBackground setAlpha:0.8f];
        [UIView animateWithDuration:2.0f animations:^{
            [sentBackground setAlpha:1.0f];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:4.0f animations:^{
                sentBackground.hidden = YES;
                appDelegate.selectedView = @"home";
                [self.navigationController popToRootViewControllerAnimated:NO];
            } completion:nil];
        }];
    }
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView == self.alphaTable) {
        return alphaList.count;
    } else if (tableView == self.tableView) {
        return self.members.count;
    } else {
        return self.addedMembers.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.alphaTable) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:alphaCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:alphaCellIdentifier];
        }
        cell.textLabel.frame = CGRectMake(0, 0, cell.contentView.bounds.size.width, cell.contentView.bounds.size.height);
        cell.textLabel.text = [alphaList objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:9];
        [cell.textLabel sizeToFit];
        cell.backgroundColor = heyloGray;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    } else if (tableView == self.addedTableView) {
        FindFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[FindFriendsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:addedCellIdentifier];
        }
        Contact *contact = self.addedMembers[indexPath.row];
        // NSLog(@"%@", contact.avatar);
        if ([contact.avatar isEqualToString:@"default_avatar"]) {
            cell.thumbnail.image = [UIImage imageNamed:@"default_avatar"];
        } else {
            NSString *path = [documentsDirectory stringByAppendingPathComponent:contact.avatar];
            cell.thumbnail.image = [UIImage imageWithContentsOfFile:path];
        }
        cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
        return cell;
        
    } else {
        SendCardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[SendCardTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        Contact *contact = self.members[indexPath.row];
        // NSLog(@"%@", contact.avatar);
        cell.backgroundColor = heyloGray;
        // circle check: E9FE empty circle: EA17
        if ([recipients objectForKey:contact.heyloId]) {
            cell.selectLabel.text = @"\uE9FE";
            cell.selectLabel.textColor = [UIColor colorWithRed:57.0/255 green:181.0/255 blue:73.0/255 alpha:1.0];
        } else {
            cell.selectLabel.text = @"\uEA17";
            cell.selectLabel.textColor = [UIColor grayColor];
        }
        // NSLog(@"%@", contact.avatar);
        if ([contact.avatar isEqualToString:@"default_avatar"]) {
            cell.thumbnail.image = [UIImage imageNamed:@"default_avatar"];
        } else {
            NSString *path = [documentsDirectory stringByAppendingPathComponent:contact.avatar];
            cell.thumbnail.image = [UIImage imageWithContentsOfFile:path];
        }
        cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.alphaTable) {
        int alphaIndex = 0;
        BOOL gotIt = NO;
        for (int i = (int)indexPath.row;i < 26;i++) {
            NSString *alpha = [alphaList objectAtIndex:i];
            NSLog(@"touched %@ %i", alpha, i);
            for (int c = 0; c < self.members.count; c++) {
                Contact *contact = [self.members objectAtIndex:c];
                if ([alpha caseInsensitiveCompare:[contact.firstName substringToIndex:1]] == NSOrderedSame) {
                    alphaIndex = c;
                    gotIt = YES;
                    break;
                }
            }
            if (gotIt) {
                break;
            }
        }
        if (gotIt == 0) {
            alphaIndex = (int)self.members.count - 1;
        }
        NSArray *unsorted = self.members;
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        self.members = [unsorted sortedArrayUsingDescriptors:sortDescriptors];
        [self.tableView reloadData];
        NSLog(@"alphaIndex %i", alphaIndex);
        if (alphaIndex > (int)self.members.count - 5) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:alphaIndex inSection:0]
                                  atScrollPosition:UITableViewScrollPositionBottom animated:YES];

        } else if (alphaIndex < 5) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:alphaIndex inSection:0]
                                  atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
        } else {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:alphaIndex inSection:0]
                              atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    } else {
        Contact *contact = [self.members objectAtIndex:indexPath.row];
        if ([recipients objectForKey:contact.heyloId]) {
            [recipients removeObjectForKey:contact.heyloId];
        } else {
            [recipients setObject:contact forKey:contact.heyloId];
        }
        NSArray *keys = [recipients allKeys];
        NSMutableString *str = [[NSMutableString alloc] init];
        for (NSString *hid in keys) {
            Contact *c = [recipients objectForKey:hid];
            NSString *name = [NSString stringWithFormat:@"%@ %@, ",c.firstName,[c.lastName substringToIndex:1]];
            [str appendString:name];
        }
        if (str.length > 1) 
            recipientLabel.text = [str substringToIndex:[str length] -1];
        if (keys.count > 0) {
            [self.sendButton setTitle:[NSString stringWithFormat:@"SEND TO %lu", (unsigned long)keys.count] forState:UIControlStateNormal];
        } else {
            recipientLabel.text = @"";
            [self.sendButton setTitle:@"SEND" forState:UIControlStateNormal];
        }
        
        [self.tableView reloadData];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Write comment..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Write comment...";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

- (void)goHome:(id)sender
{
    appDelegate.selectedView = @"home";
    [self.navigationController popToRootViewControllerAnimated:YES];
}


// Prompt the user for access to their Address Book data
-(void)requestAddressBookAccess
{
    SendCardViewController * __weak weakSelf = self;
    
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
    
    // NSLog(@"Access granted ++++++++");
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
        
        // NSLog(@"exists: %@ %@",recordId,  [recordContact objectForKey:recordId]);
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
    
    // NSLog(@"json: %@",jsonPostBody);
    
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
    NSMutableArray *unsorted = [[NSMutableArray alloc] init];
    NSError *error;
    // NSLog(@"====================\nFinally got a response");
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
                    NSNumber *contactId = appDelegate.heyloData.setMaxContactId;
                    Contact *contact = [[Contact alloc] initWithId:contactId abRecord:recordId heyloId:hid phoneNumber:pnum firstName:firstName lastName:lastName avatar:avatar activityDate:createdDate createdDate:createdDate];
                    [HeyloData createContact:contact];
                    [unsorted addObject:contact];
                }
                i++;
            }
        }
        // NSLog(@"====================\nstop animating and present modal");
        [self.activityIndicator stopAnimating];
        activityView.hidden = YES;
        // stop animating
        if (unsorted.count > 0) {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            self.addedMembers = [unsorted sortedArrayUsingDescriptors:sortDescriptors];;
            [self.addedTableView reloadData];
            addedMembersView.hidden = NO;
        } else {
            appDelegate.selectedView = @"send_card";
            InviteFriendsViewController *friendsView = [[InviteFriendsViewController alloc] init];
            [self.navigationController pushViewController:friendsView animated:YES];
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
