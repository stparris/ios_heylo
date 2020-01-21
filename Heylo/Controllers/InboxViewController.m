 //
//  TableViewController.m
//  notify
//
//  Created by Scott Parris on 4/3/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import "InboxViewController.h"
#import "AppDelegate.h"
#import "ImageCache.h"
#import "HeyloData.h"
#import "Conversation.h"
#import "Contact.h"
#import "ConversationViewController.h"
#import "Message.h"
#import "HeaderGradientView.h"
#import "InboxTableViewCell.h"

static NSString *CellIdentifier = @"TapTableCell";

@interface InboxViewController () {
    BOOL editMode;
    UIView *controlView;
    HeaderGradientView *dropShadow;
    UIView *navBorder;
    NSDateFormatter *dateFormatter;
    NSLocale *usLocale;
}

@property (nonatomic, strong) UIButton *editButton;

- (void)actionEdit:(id)sender;
- (void)showCategories:(id)sender;

@end

@implementation InboxViewController

- (void)loadView
{
    [super loadView];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.navigationController.navigationBarHidden = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    [dateFormatter setLocale:usLocale];
    UIScreen *screen = [UIScreen mainScreen];
    controlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen.bounds.size.width, 64)];
    controlView.backgroundColor = [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1.0];
    self.categoriesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.categoriesButton.frame = CGRectMake(0,0, 64, 64);
    UIEdgeInsets insets = { .left = 10, .right = 30, .top = 30, .bottom = 10 };
    self.categoriesButton.titleEdgeInsets = insets;
    self.categoriesButton.titleLabel.font = [UIFont fontWithName:@"fontello" size:24];
    self.categoriesButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.categoriesButton setTitle:@" \uEA00" forState:UIControlStateNormal]; //   EA04
    [self.categoriesButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.categoriesButton.tag = 1;
    [self.categoriesButton addTarget:self action:@selector(showCategories:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *inboxLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, 10, screen.bounds.size.width -128, 64)];
    inboxLabel.textAlignment = NSTextAlignmentCenter;
    inboxLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:26];
    inboxLabel.text = @"MESSAGES";
    inboxLabel.textColor = [UIColor darkGrayColor];
    [controlView addSubview:inboxLabel];
    
    self.editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.editButton.frame = CGRectMake(screen.bounds.size.width - 64, 10, 64, 64);
//    UIEdgeInsets EditInsets = { .left = 30, .right = 10, .top = 30, .bottom = 10 };
//    self.editButton.titleEdgeInsets = EditInsets;
    self.editButton.titleLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:20];
    self.editButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.editButton setTitle:@"Edit" forState:UIControlStateNormal];
    [self.editButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.editButton.tag = 1;
    [self.editButton addTarget:self action:@selector(actionEdit:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:controlView];
    
    navBorder = [[UIView alloc] initWithFrame:CGRectMake(0,controlView.bounds.size.height -2, screen.bounds.size.width, 2)];
    navBorder.tag = 1;
    navBorder.backgroundColor = [UIColor grayColor];

    dropShadow = [[HeaderGradientView alloc] initWithFrame:CGRectMake(0, 64, screen.bounds.size.width, 14.0)];

    self.view.backgroundColor = [UIColor whiteColor];


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable:) name:@"reloadInbox" object:nil];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 79.0, screen.bounds.size.width, screen.bounds.size.height - 102)
                                                        style:UITableViewStylePlain
                            ];
   // self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.estimatedRowHeight = 80;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
}


- (void)viewWillAppear:(BOOL)animated
{
    [controlView addSubview:self.editButton];
    [controlView addSubview:self.categoriesButton];
    [controlView addSubview:navBorder];
    [controlView addSubview:dropShadow];
    
    self.navigationController.navigationBarHidden = NO;
    editMode = NO;
    appDelegate.conversations = [Conversation getConversations];
    [self.tableView setEditing:NO animated:NO];
    [self.tableView reloadData];
}

- (void)reloadTable:(NSNotification *)notification
{
    [self reloadTableAndData];
}

- (void)reloadTableAndData
{
    appDelegate.conversations = [Conversation getConversations];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadInbox" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)showCategories:(id)sender
{
    UIButton *button = sender;
    switch (button.tag) {
        case 0: {
            [_delegate movePanelToOriginalPosition];
            break;
        }
            
        case 1: {
            [_delegate movePanelRight];
            break;
        }
            
        default:
            break;
    }
    
}

- (void)actionEdit:(id)sender
{
    if (editMode == YES) {
        editMode = NO;
        [self.editButton setTitle:@"Edit" forState:UIControlStateNormal];
        [self.tableView setEditing:NO animated:YES];
    } else {
        editMode = YES;
        [self.editButton setTitle:@"Done" forState:UIControlStateNormal];
        [self.tableView setEditing:YES animated:YES];
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return appDelegate.conversations.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Conversation *conv = [appDelegate.conversations objectAtIndex:indexPath.row];
    InboxTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[InboxTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
    if ([appDelegate.imageCache doesExist:conv.imageUrl]) {
        cell.thumbnail.image = [appDelegate.imageCache getImageForURL:conv.imageUrl];
    } else if (conv.imageUrl.length > 0) {
        NSLog(@"%@",conv.imageUrl);
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:conv.imageUrl]];
        UIImage *theImage  = [UIImage imageWithData:imageData];
        if (theImage) {
            cell.thumbnail.image = theImage;
            [appDelegate.imageCache cacheImage:theImage withData:imageData forURL:conv.imageUrl];
        }
    }
    cell.thumbnail.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.thumbnail.layer.borderWidth = 3;
    if ([conv.readFlag integerValue] > 0) {
        cell.unreadFlag.backgroundColor = [UIColor colorWithRed:39.0/255 green:170.0/255 blue:255.0/255 alpha:1.0];
    } else {
        cell.unreadFlag.backgroundColor = [UIColor whiteColor];
    }
    NSString *contactStr = @"";
    NSLog(@"%@ %@ %@", conv.contactString, appDelegate.myself.heyloId, conv.thread);
    NSArray *hids = [conv.thread componentsSeparatedByString:@","];
    NSArray *names = [conv.contactString componentsSeparatedByString:@"^$&"];
    int i = 0;
    for (NSString *heyloId in hids) {
        // NSLog(@"name %@", contact.firstName);
        if (hids.count == 1 && [heyloId isEqualToString:appDelegate.myself.heyloId]) {
            contactStr = [contactStr stringByAppendingFormat:@"%@ %@, ", appDelegate.myself.firstName, appDelegate.myself.lastName];
        } else {
            if (![heyloId isEqualToString:appDelegate.myself.heyloId] && i < names.count)
                contactStr = [contactStr stringByAppendingFormat:@"%@, ", [names objectAtIndex:i]];
        }
        i++;
    }
    if (contactStr.length > 2)
        cell.contactsLabel.text = [contactStr substringToIndex:[contactStr length] -2];
    // NSLog(@"messsage %@", [conv.lastMessage objectForKey:@"message"]);
    cell.messageText.text = [self getMessageSummary:[conv.lastMessage objectForKey:@"message"]];
    cell.messageIcon.font = [UIFont fontWithName:@"fontello" size:12];
    cell.messageIcon.text = @"\uE904";

    cell.messageCount.text = [NSString stringWithFormat:@"%@", [conv.lastMessage objectForKey:@"count"]];
    // NSLog(@"count %@", cell.messageCount.text);
    cell.dateLabel.text = [self timeStamp:conv.modifiedDate];
    NSLog(@"modified date %@",conv.modifiedDate);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // ret unread message count
    Conversation *conversation = [appDelegate.conversations objectAtIndex:indexPath.row];
    int msgCount = [appDelegate.inboxCount intValue] - [conversation.readFlag intValue];
    appDelegate.inboxCount = [NSNumber numberWithInt:msgCount];
    conversation.readFlag = [NSNumber numberWithInt:0];
    if (editMode == YES) {
        if (!conversation.destroy) {
            NSLog(@"Unable to destroy conversation");
        } else {
            [self reloadTableAndData];
        }

    } else {
        if (![conversation update])
            NSLog(@"Unable to update conversation");
        ConversationViewController *conversationView = [[ConversationViewController alloc] init];
        conversationView.conversation = conversation;
        [self.navigationController pushViewController:conversationView animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Conversation *conversation = [appDelegate.conversations objectAtIndex:indexPath.row];
        if(conversation.destroy) {
            [self reloadTableAndData];
        }
    }
}


- (BOOL)tableView:(UITableView *)tableView canDeleteRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (NSString *)getMessageSummary:(NSString *)message
{
    NSString *summary = @"";
    NSArray *words = [message componentsSeparatedByString:@" "];
    CGFloat maxSize = 2*(self.tableView.bounds.size.width - 80);
    CGFloat currentSize = 0.0;
    for (NSString *word in words) {
        currentSize += [word sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:14]}].width;
        if (currentSize + 3.0 < maxSize) {
            summary = [summary stringByAppendingString:[NSString stringWithFormat:@"%@ ",word]];
        } else {
            int index = (int)(summary.length - 1);
            summary = [summary substringToIndex:index];
            summary = [summary stringByAppendingString:@"..."];
            return summary;
            break;
        }
    }
    return summary;
}

- (NSString *)timeStamp:(NSNumber *)modifiedDate
{
    int secondsSinceUnixEpoch = (int)[[NSDate date]timeIntervalSince1970];
    NSString *dateTime;
    // NSLog(@"nsnum %@ vs int %i", message.createdDate, [message.createdDate intValue]);
    int diff = secondsSinceUnixEpoch - [modifiedDate intValue];
    if (diff < 60) {
        dateTime =  @"seconds ago";
    } else if (diff < 120 && diff >= 60) {
        dateTime =  @"1 min ago";
    } else if (diff < 3600) {
        int i = floor(diff/60);
        dateTime = [NSString stringWithFormat:@"%i mins ago", i];
    } else if (diff < 7200 && diff >= 3600) {
        dateTime =  @"1 hour ago";
    } else if (diff < 86400) {
        int i = floor(diff/3600);
        dateTime = [NSString stringWithFormat:@"%i hours ago", i];
    } else {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[modifiedDate doubleValue]];
        dateTime = [dateFormatter stringFromDate:date];
    }
    return dateTime;
}


- (void)showAccount:(id)sender
{
    appDelegate.selectedView = @"account";
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end
