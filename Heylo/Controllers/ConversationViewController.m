  //
//  ChatViewController.m
//  notify
//
//  Created by Scott Parris on 3/30/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ConversationViewController.h"
#import "Conversation.h"
#import "ReplyViewController.h"
#import "Message.h"
#import "Contact.h"
#import "User.h"
#import "AppDelegate.h"
#import "HeyloData.h"
#import "HeyloConnection.h"
#import "HeaderGradientView.h"
#import "ConvImageTableViewCell.h"
#import "ConvFromTableViewCell.h"
#import "ConvToTableViewCell.h"
#import "ImageCache.h"
#import "FlashView.h"

static NSString *CellFrom = @"FromCell";
static NSString *CellTo = @"ToCell";
static NSString *CellImage = @"ImageCell";

@interface ConversationViewController () {
    UIColor *redColor;
    UIColor *blueColor;
    UIColor *greenColor;
    UIColor *yellowColor;
    UIColor *roseColor;
    NSString *documentsDirectory;
    NSDateFormatter *dateFormatter;
    NSLocale *usLocale;
    NSArray *messsages;
    CGFloat animatedDistance;
    CGFloat keyboardHeight;
    BOOL keyboardActive;
    BOOL scrollUp;
    NSMutableDictionary *contactColor;
    UIView *replyView;
    UITextView *replyText;
    UIButton *replyButton;
    UISwipeGestureRecognizer *dismissGesture;
    CGFloat textViewHeight;
}

@property (nonatomic, strong) FlashView *flashView;
@property (nonatomic, assign) CGFloat lastContentOffset;

- (void)backToInbox:(id)sender;
- (void)showMessage;
- (void)sendReply;

@end

@implementation ConversationViewController

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;

- (void)loadView
{
    [super loadView];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    redColor = [UIColor colorWithRed:251.0/255 green:236.0/255 blue:233.0/255 alpha:1.0];
    blueColor = [UIColor colorWithRed:181.0/255 green:234.0/255 blue:247.0/255 alpha:1.0];
    greenColor = [UIColor colorWithRed:214.0/255 green:255.0/255 blue:217.0/255 alpha:1.0];
    yellowColor = [UIColor colorWithRed:254.0/255 green:255.0/255 blue:225.0/255 alpha:1.0];
    contactColor = [[NSMutableDictionary alloc] init];
    self.view.backgroundColor = [UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    messages = [[NSMutableArray alloc] init];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    self.title = NSLocalizedString(@"CONVERSATION", @"CONVERSATION");
    self.view.backgroundColor = [UIColor whiteColor];
    usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    [dateFormatter setLocale:usLocale];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor], NSForegroundColorAttributeName,
      [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:24],
      NSFontAttributeName, nil]];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    [backButton setTitleTextAttributes:@{
                                         NSFontAttributeName: [UIFont fontWithName:@"fontello" size:26.0],
                                         NSForegroundColorAttributeName: [UIColor blackColor]
                                         } forState:UIControlStateNormal];
    backButton.title = @"\uE9F8";
    backButton.target = self;
    backButton.action = @selector(backToInbox:);
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
    
    
    UIScreen *screen = [UIScreen mainScreen];
    HeaderGradientView *dropShadow = [[HeaderGradientView alloc] initWithFrame:CGRectMake(0, 64, screen.bounds.size.width, 12.0)];
    dropShadow.backgroundColor = [UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
    [self.view addSubview:dropShadow];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 76, screen.bounds.size.width, screen.bounds.size.height - 140)];
    self.tableView.backgroundColor = [UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 80;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    textViewHeight = 44;
    replyView = [[UIView alloc] initWithFrame:CGRectMake(0, self.tableView.bounds.size.height + 76, screen.bounds.size.width, textViewHeight + 20)];
    replyView.backgroundColor = [UIColor grayColor];
    
/**    replyButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, replyView.bounds.size.width - 20, 44)];
    replyButton.layer.cornerRadius = 5;
    replyButton.backgroundColor = [UIColor whiteColor];
    replyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [replyButton setTitle:@"  Add a reply" forState:UIControlStateNormal];
    replyButton.titleLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:18];
    [replyButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [replyButton addTarget:self action:@selector(showReply) forControlEvents:UIControlEventTouchUpInside];
    [replyView addSubview:replyButton];
    [self.view addSubview:replyView];
*/
    
    replyButton = [[UIButton alloc] initWithFrame:CGRectMake(replyView.bounds.size.width - 60, 10, 60, 44)];
    replyButton.backgroundColor = [UIColor grayColor];
    replyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [replyButton setTitle:@"\uEA05" forState:UIControlStateNormal];
    replyButton.titleLabel.font = [UIFont fontWithName:@"fontello" size:24];
    [replyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [replyButton addTarget:self action:@selector(sendReply) forControlEvents:UIControlEventTouchUpInside];
    [replyView addSubview:replyButton];
    
    dismissGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [dismissGesture setDirection:UISwipeGestureRecognizerDirectionDown];
    [replyView addGestureRecognizer:dismissGesture];
    dismissGesture.enabled = NO;

    replyText = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, replyView.bounds.size.width - 70, textViewHeight)];
    replyText.layer.cornerRadius = 5.0;
    replyText.scrollEnabled = NO;
    
    [replyText setDelegate:self];
    [replyText setKeyboardType:UIKeyboardTypeDefault];
    
    replyText.autocorrectionType = UITextAutocorrectionTypeYes;
    replyText.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    replyText.returnKeyType = UIReturnKeyDefault;
    replyText.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:20];
    keyboardActive = NO;
    scrollUp = NO;
    replyText.textColor = [UIColor lightGrayColor];
    
    replyText.text = @"Add a reply...";
    
    [replyView addSubview:replyText];
    [self.view addSubview:replyView];

    self.flashView = [[FlashView alloc] initWithScreenWidth:self.view.bounds.size.width];
    self.flashView.hidden = YES;
    [self.navigationController.navigationBar addSubview:self.flashView];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(reloadTable:) name:@"reloadMessages" object:nil];
    [defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}


- (void)reloadTable:(NSNotification *)notification
{
    int msgCount = [appDelegate.inboxCount intValue] - [self.conversation.readFlag intValue];
    appDelegate.inboxCount = [NSNumber numberWithInt:msgCount];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:msgCount];
    self.conversation.readFlag = [NSNumber numberWithInt:0];
    if (![self.conversation update])
        NSLog(@"Unable to update conversation");

    
    [self reloadMessages];
}

- (void)reloadMessages
{
    int i = 0;
    NSArray *colors = @[yellowColor,greenColor,redColor,blueColor];
    NSArray *hids = [self.conversation.thread componentsSeparatedByString:@","];
    for (NSString *hid in hids) {
        if (![appDelegate.myself.heyloId isEqualToString:hid]) {
            [contactColor setObject:[colors objectAtIndex:i] forKey:hid];
            i++;
            if (i == 3)
                i = 0;
        }
    }
    NSArray *msgs = [Message getMessagesForConversation:self.conversation];
    [messages removeAllObjects];
    for (Message *msg in msgs) {
        if (msg.imageUrl.length > 0) {
            [messages addObject:msg];
            Message *msg2 = [[Message alloc] initWithId:[NSNumber numberWithInt:1] andConversation:self.conversation andContact:msg.contact andImageUrl:@"" andMessage:msg.message andDate:msg.createdDate];
            msg2.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:msg2.imageUrl]];
            [messages addObject:msg2];
            // tableHeight += imageHeight;
        } else {
            [messages addObject:msg];
        }
        // tableHeight += 50;
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:msg.message];
        NSRange all = NSMakeRange(0, text.length);
        [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:12] range:all];
    }
    [self.tableView reloadData];
    NSIndexPath* path = [NSIndexPath indexPathForRow:messages.count -1 inSection:0];
    // Hack from http://stackoverflow.com/questions/25686490/ios-8-auto-cell-height-cant-scroll-to-last-row
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadTheTable" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"flashMessage" object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMessage) name:@"flashMessage" object:nil];
    
}

- (void)showMessage
{
    if (appDelegate.alert.length > 1)
        [self.flashView showMessage:appDelegate.alert];
    appDelegate.alert = @"";
}

- (void)viewWillAppear:(BOOL)animated
{
    self.conversation.readFlag = [NSNumber numberWithInt:0];
    [HeyloData updateConversation:self.conversation];
    [self reloadMessages];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
 
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // NSLog(@"%lu", (unsigned long)messages.count);
    return messages.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Message *message = [messages objectAtIndex:indexPath.row];
    if (message.imageUrl.length > 0) {
        ConvImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellImage];
        if (cell == nil) {
            cell = [[ConvImageTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellImage];
        }
        if ([appDelegate.imageCache doesExist:message.imageUrl]) {
            cell.cardImage.image = [appDelegate.imageCache getImageForURL:message.imageUrl];
        } else {
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:message.imageUrl]];
            UIImage *theImage = [UIImage imageWithData:imageData];
            cell.cardImage.image = theImage;
            cell.cardImage.layer.masksToBounds = YES;
            [appDelegate.imageCache cacheImage:theImage withData:imageData forURL:message.imageUrl];
        }
        return cell;
    } else if ([message.contact.heyloId isEqualToString:appDelegate.user.heyloId]) {
        ConvToTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTo];
        if (cell == nil) {
            cell = [[ConvToTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellTo];
        }
        if ([message.contact.avatar isEqualToString:@"default_avatar"]) {
            cell.avatar.image = [UIImage imageNamed:@"default_avatar"];
        } else {
            NSString *path = [documentsDirectory stringByAppendingPathComponent:message.contact.avatar];
            cell.avatar.image = [UIImage imageWithContentsOfFile:path];
            
        }
        cell.messageColor = [UIColor whiteColor];
        cell.contactLabel.text = @"Me";
        cell.messageText.text = message.message;
        cell.dateLabel.text =  [self timeStamp:message];
        return cell;
    } else {
        ConvFromTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellFrom];
        if (cell == nil) {
            cell = [[ConvFromTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellFrom];
        }

        if ([message.contact.avatar isEqualToString:@"default_avatar"]) {
            cell.avatar.image = [UIImage imageNamed:@"default_avatar"];
        } else {
            NSString *path = [documentsDirectory stringByAppendingPathComponent:message.contact.avatar];
            cell.avatar.image = [UIImage imageWithContentsOfFile:path];
        }
        cell.messageColor = [contactColor objectForKey:message.contact.heyloId];
        // NSLog(@"conact id %@", message.contact.heyloId);
        cell.contactLabel.text = [NSString stringWithFormat:@"%@ %@", message.contact.firstName, message.contact.lastName];
        cell.messageText.text = message.message;
        cell.dateLabel.text = [self timeStamp:message];
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        return cell;
    }
}


- (NSString *)timeStamp:(Message *)message
{
    int secondsSinceUnixEpoch = (int)[[NSDate date]timeIntervalSince1970];
    NSString *dateTime;
    // NSLog(@"nsnum %@ vs int %i", message.createdDate, [message.createdDate intValue]);
    int diff = secondsSinceUnixEpoch - [message.createdDate intValue];
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
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[message.createdDate doubleValue]];
        dateTime = [dateFormatter stringFromDate:date];
    }
    return dateTime;
}

- (void)backToInbox:(id)sender
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromLeft;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    appDelegate.selectedView = @"inbox";
    [self.navigationController popToRootViewControllerAnimated:NO];
}


- (void)showAccount:(id)sender
{
    appDelegate.selectedView = @"account";
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)goHome:(id)sender
{
    appDelegate.selectedView = @"home";
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    replyText.textColor = [UIColor blackColor];
    if ([replyText.text isEqualToString:@"Add a reply..."]) {
        replyText.textColor = [UIColor blackColor];
        replyText.text = @"";
        replyButton.enabled = YES;
    }
    keyboardActive = YES;
    NSDictionary *keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    keyboardHeight = keyboardFrameBeginRect.size.height;
}


- (void)textViewDidBeginEditing:(UITextField *)textView
{
    dismissGesture.enabled = YES;
    CGRect textFieldRect = [self.view.window convertRect:textView.bounds fromView:textView];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0) {
        heightFraction = 0.0;
    } else if (heightFraction > 1.0) {
        heightFraction = 1.0;
    }
    if (textViewHeight > 44) {
        animatedDistance = keyboardHeight + (textViewHeight - 44);
        CGRect replyFrame = replyView.frame;
        replyFrame.origin.y = self.tableView.bounds.size.height + 76;
        replyView.frame = replyFrame;
    } else {
        animatedDistance = floor(keyboardHeight * heightFraction);
    }

    
    CGRect viewFrame = self.view.frame;
    // NSLog(@"y %f - d %f", viewFrame.origin.y,animatedDistance);
    viewFrame.origin.y -= animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    

}

- (void)textViewDidChange:(UITextView *)textView
{
    CGRect textFrame = textView.frame;
    CGFloat newHeight = [textView sizeThatFits:CGSizeMake(textFrame.size.width, CGFLOAT_MAX)].height;
    if (newHeight < 45) {
        newHeight = 44;
    }
    textFrame.size = CGSizeMake(textFrame.size.width, newHeight);
    CGFloat heightDiff;
    CGRect viewFrame = self.view.frame;
    CGRect replyFrame = replyView.frame;
    if (textViewHeight > newHeight) {
        heightDiff = textViewHeight - newHeight;
        replyFrame.size = CGSizeMake(replyFrame.size.width, newHeight + 20);
        viewFrame.origin.y += heightDiff;
        textViewHeight = newHeight;
        replyText.frame = textFrame;
        replyView.frame = replyFrame;
        self.view.frame = viewFrame;
        animatedDistance -= heightDiff;
    } else if (newHeight > textViewHeight) {
        heightDiff = newHeight - textViewHeight;
        // NSLog(@"%f - %f = %f reply y %f", newHeight, textViewHeight, heightDiff, replyFrame.origin.y);
        replyFrame.size = CGSizeMake(replyFrame.size.width, newHeight + 20);
        // NSLog(@"old height %f newHeight %f new y %f", replyView.bounds.size.height, replyFrame.size.height, replyFrame.origin.y);
        viewFrame.origin.y -= heightDiff;
        textViewHeight = newHeight;
        replyText.frame = textFrame;
        replyView.frame = replyFrame;
        self.view.frame = viewFrame;
        animatedDistance += heightDiff;
    }
}



/**
- (void)textViewDidEndEditing:(UITextField *)textView
{
    if (replyText.text.length > 0) {
        Message *newMessage = [Message createWithConversation:self.conversation andContact:appDelegate.myself andImageUrl:@"" andMessage:replyText.text andDate:[HeyloData getTimestamp] isIncoming:NO];
        if (!newMessage) {
            NSLog(@"Oppps...");
        }
        replyText.textColor = [UIColor lightGrayColor];
        replyText.text = @"Add a reply...";
        
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
    
    [self reloadMessages];
}
*/

/**
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (keyboardActive == YES && scrollView == self.tableView) {
        // NSLog(@"%f -- %f", self.lastContentOffset, scrollView.contentOffset.y);
        if (self.lastContentOffset < scrollView.contentOffset.y)
            scrollUp = NO;
        else if (self.lastContentOffset + 10 > scrollView.contentOffset.y)
            scrollUp = YES;
        self.lastContentOffset = scrollView.contentOffset.y;
        if (scrollUp == YES) {
            [replyText resignFirstResponder];
            keyboardActive = NO;
            CGRect viewFrame = self.view.frame;
            viewFrame.origin.y += animatedDistance;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
            [self.view setFrame:viewFrame];
            [UIView commitAnimations];
            CGRect viewFrame = CGRectMake(replyView.frame.origin.x, originY, replyView.frame.size.width, textViewHeight + 20);
            replyView.frame = viewFrame;
            CGRect textFrame = CGRectMake(replyText.frame.origin.x, replyText.frame.origin.y, replyText.frame.size.width, textViewHeight);
            replyText.frame = textFrame;
            if (replyText.text.length < 1) {
                replyText.textColor = [UIColor lightGrayColor];
                replyText.text = @"Add a reply...";
                replyButton.enabled = NO;
            }
            CGPoint offset = scrollView.contentOffset;
            [scrollView setContentOffset:offset animated:NO];
        }
    }
}
*/ 

- (void)dismissKeyboard
{
    dismissGesture.enabled = NO;
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
    keyboardActive = NO;
    if (replyText.text.length < 1) {
        replyText.text = @"Add a reply...";
        replyText.textColor = [UIColor lightGrayColor];
        replyButton.enabled = NO;
    } else if (textViewHeight > 44) {
        CGRect replyFrame = replyView.frame;
        replyFrame.origin.y = self.view.bounds.size.height - (textViewHeight + 20);
        replyView.frame = replyFrame;
    }
    [replyText resignFirstResponder];
}

- (void)sendReply
{
    if (replyText.text.length > 0) {
        Message *newMessage = [Message createWithConversation:self.conversation andContact:appDelegate.myself andImageUrl:@"" andMessage:replyText.text andDate:[HeyloData getTimestamp] isIncoming:NO];
        if (!newMessage) {
            NSLog(@"Oppps...");
        }
    }
    if (keyboardActive == YES) {
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y += animatedDistance;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        [self.view setFrame:viewFrame];
        [UIView commitAnimations];
        keyboardActive = NO;
    }
    [replyText resignFirstResponder];
    CGRect textFrame = replyText.frame;
    textFrame.size = CGSizeMake(textFrame.size.width, 44.0);
    textViewHeight = 44;
    replyText.frame = textFrame;
    replyText.textColor = [UIColor lightGrayColor];
    replyText.text = @"Add a reply...";
    replyButton.enabled = NO;
    dismissGesture.enabled = NO;
    [self reloadMessages];
}




/**    
- (void)showReply
{
 ReplyViewController *reply = [[ReplyViewController alloc] init];
 reply.conversation = self.conversation;
 CATransition *transition = [CATransition animation];
 transition.duration = 0.5;
 transition.type = kCATransitionMoveIn;
 transition.subtype = kCATransitionFromBottom;
 transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
 [self.navigationController.view.layer addAnimation:transition forKey:nil];
 [self.navigationController pushViewController:reply animated:NO];
}
 */


- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end
