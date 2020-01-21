//
//  ReplyViewController.m
//  Heylo
//
//  Created by Scott Parris on 6/15/15.
//  Copyright (c) 2015 Heylo. All rights reserved.
//

#import "ReplyViewController.h"
#import "AppDelegate.h"
#import "HeyloData.h"
#import "HeyloConnection.h"
#import "Conversation.h"
#import "Message.h"
#import "Contact.h"
#import "FlashView.h"
#import "HeaderGradientView.h"


@interface ReplyViewController () {
    AppDelegate *appDelegate;
    UIView *replyView;
    UITextView *replyText;
    UIView *toView;
    UILabel *toText;
    CGFloat keyboardHeight;
}

@property (nonatomic, strong) FlashView *flashView;

- (void)cancelReply;
- (void)showMessage;
- (void)sendAction;

@end

@implementation ReplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
    self.title = NSLocalizedString(@"REPLY", @"REPLY");
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor], NSForegroundColorAttributeName,
      [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:24],
      NSFontAttributeName, nil]];
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    [backButton setTitleTextAttributes:@{
                                         NSFontAttributeName: [UIFont fontWithName:@"fontello" size:18.0],
                                         NSForegroundColorAttributeName: [UIColor blackColor]
                                         } forState:UIControlStateNormal];
    backButton.title = @" \uEA08";
    backButton.target = self;
    backButton.action = @selector(cancelReply);
    [self.navigationItem setLeftBarButtonItem:backButton];
    
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] init];
    [sendButton setTitleTextAttributes:@{
                                              NSFontAttributeName: [UIFont fontWithName:@"fontello" size:26.0],
                                              NSForegroundColorAttributeName: [UIColor blackColor]
                                              } forState:UIControlStateNormal];
    sendButton.title = @"\uEA05";
    sendButton.target = self;
    sendButton.action = @selector(sendAction);
    [self.navigationItem setRightBarButtonItem:sendButton];

    
    toView = [[UIView alloc] init];
    toView.backgroundColor = [UIColor clearColor];
    toView.translatesAutoresizingMaskIntoConstraints = NO;
    toText = [[UILabel alloc] init];
    toText.translatesAutoresizingMaskIntoConstraints = NO;
    toText.lineBreakMode = NSLineBreakByWordWrapping;
    toText.numberOfLines = 0;
    toText.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:16];
    [toText sizeToFit];
    [toView addSubview:toText];
    [self.view addSubview:toView];
    
    replyView = [[UIView alloc] init];
    replyView.backgroundColor = [UIColor grayColor];
    replyView.translatesAutoresizingMaskIntoConstraints = NO;
    replyText = [[UITextView alloc] init];
    replyText.backgroundColor = [UIColor whiteColor];
    replyText.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:14];
    replyText.translatesAutoresizingMaskIntoConstraints = NO;
    [replyText setDelegate:self];
    [replyText setKeyboardType:UIKeyboardTypeDefault];
    replyText.autocorrectionType = UITextAutocorrectionTypeYes;
    replyText.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    replyText.returnKeyType = UIReturnKeyDefault;
    replyText.clipsToBounds = YES;
    replyText.layer.cornerRadius = 5.0f;
    [replyView addSubview:replyText];
    [self.view addSubview:replyView];

    UIScreen *screen = [UIScreen mainScreen];
    HeaderGradientView *dropShadow = [[HeaderGradientView alloc] initWithFrame:CGRectMake(0, 64, screen.bounds.size.width, 12.0)];
    [self.view addSubview:dropShadow];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    NSString *contactStr = @"To: ";
    NSArray *hids = [self.conversation.thread componentsSeparatedByString:@","];
    NSArray *names = [self.conversation.contactString componentsSeparatedByString:@"^$&"];
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
        toText.text = [contactStr substringToIndex:[contactStr length] -2];
    
    [replyText becomeFirstResponder];
    

}

- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary *keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    keyboardHeight = keyboardFrameBeginRect.size.height;
    
    NSDictionary *viewsDictionary = @{@"toView":toView,
                                      @"toText":toText,
                                      @"replyView":replyView,
                                      @"replyText":replyText
                                      };
    CGFloat textH = self.view.bounds.size.height/4;
    NSDictionary *metrics = @{@"keyboardHeight":[NSNumber numberWithFloat:keyboardHeight],
                              @"textHeight":[NSNumber numberWithFloat:textH]
                              };
    
    NSArray *toText_constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[toText]-20-|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:viewsDictionary];
    [toView addConstraints:toText_constraint_H];
    
    NSArray *toText_constraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[toText]-5-|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:viewsDictionary];
    [toView addConstraints:toText_constraint_V];
    
    
    
    NSArray *replyText_constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-12-[replyText]-12-|"
                                                                              options:0
                                                                              metrics:metrics
                                                                                views:viewsDictionary];
    [replyView addConstraints:replyText_constraint_H];
    
    NSArray *replyText_constraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[replyText]-12-|"
                                                                              options:0
                                                                              metrics:metrics
                                                                                views:viewsDictionary];
    [replyView addConstraints:replyText_constraint_V];
    
    
    
    NSArray *toView_constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toView]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:viewsDictionary];
    [self.view addConstraints:toView_constraint_H];
    
    NSArray *replyView_constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[replyView]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:viewsDictionary];
    [self.view addConstraints:replyView_constraint_H];
    
    
    NSArray *views_constraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-74-[toView]-10-[replyView]-keyboardHeight-|"
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:viewsDictionary];
    [self.view addConstraints:views_constraint_V];

    
}


- (void)viewWillDisappear:(BOOL)animated
{
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

- (void)sendAction
{
    if (replyText.text.length > 0) {
        Message *newMessage = [Message createWithConversation:self.conversation andContact:appDelegate.myself andImageUrl:@"" andMessage:replyText.text andDate:[HeyloData getTimestamp] isIncoming:NO];
        if (!newMessage) {
            NSLog(@"Oppps...");
        }
    }
    [self.navigationController popViewControllerAnimated:NO];
}


- (void)cancelReply
{
    [self.navigationController popViewControllerAnimated:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
