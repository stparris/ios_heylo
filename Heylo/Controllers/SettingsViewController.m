//
//  MyViewController.m
//  notify
//
//  Created by Scott Parris on 4/23/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import "SettingsViewController.h"
#import "User.h"
#import "Contact.h"
#import "Country.h"
#import "HeyloData.h"
#import "AppDelegate.h"
#import "HeaderGradientView.h"
#import "InviteFriendsViewController.h"

@interface SettingsViewController () {
    AppDelegate *appDelegate;
    UIView *controlView;
    HeaderGradientView *dropShadow;
    UIView *navBorder;
    CGFloat animatedDistance;
    CGFloat keyboardHeight;
}

@property (nonatomic, strong) UITextField *firstName;
@property (nonatomic, strong) UITextField *lastName;
@property (nonatomic, strong) UITextField *email;
@property (strong, nonatomic) UIButton *saveDetails;
@property (strong, nonatomic) UIButton *homeButton;
@property (strong, nonatomic) UIButton *resetButton;
@property (strong, nonatomic) UIButton *signoutButton;
@property (strong, nonatomic) UIButton *findFriendsButton;

- (void)actionHome:(id)sender;
- (void)saveDetails:(id)sender;
- (void)findFriends:(id)sender;
- (void)signout:(id)sender;
- (void)resetDemo:(id)sender;

@end

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;

@implementation SettingsViewController


- (void)loadView
{
    [super loadView];
    [self setNeedsStatusBarAppearanceUpdate];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.navigationController.navigationBarHidden = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    self.view.backgroundColor = [UIColor whiteColor];
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
    inboxLabel.text = @"SETTINGS";
    inboxLabel.textColor = [UIColor darkGrayColor];
    [controlView addSubview:inboxLabel];
    self.homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.homeButton.frame = CGRectMake(screen.bounds.size.width - 64, 10, 64, 64);

    self.homeButton.titleLabel.font = [UIFont fontWithName:@"fontello" size:24];
    self.homeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.homeButton setTitle:@" \uEA03" forState:UIControlStateNormal]; //   EA04
    [self.homeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.homeButton.tag = 1;
    [self.homeButton addTarget:self action:@selector(actionHome:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *settingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, 10, screen.bounds.size.width -128, 64)];
    settingsLabel.textAlignment = NSTextAlignmentCenter;
    settingsLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:26];
    settingsLabel.text = @"SETTINGS";
    settingsLabel.textColor = [UIColor darkGrayColor];
    [controlView addSubview:settingsLabel];
    
    [self.view addSubview:controlView];
    
    navBorder = [[UIView alloc] initWithFrame:CGRectMake(0,controlView.bounds.size.height -2, screen.bounds.size.width, 2)];
    navBorder.tag = 1;
    navBorder.backgroundColor = [UIColor grayColor];
    
    dropShadow = [[HeaderGradientView alloc] initWithFrame:CGRectMake(0, 64, screen.bounds.size.width, 14.0)];
    float originY = 60.0;
    
    float margin = 24.0;
    originY = originY + 62.0;
    self.firstName = [[UITextField alloc] initWithFrame:CGRectMake(margin, originY, screen.bounds.size.width - margin*2, 46.0)];
    [self.firstName setDelegate:self];
    [self.firstName setKeyboardType:UIKeyboardTypeDefault];
    self.firstName.autocorrectionType = UITextAutocorrectionTypeNo;
    self.firstName.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.firstName.borderStyle = UITextBorderStyleRoundedRect;
    [self.firstName.layer setCornerRadius:23.0f];
    [self.firstName setBackgroundColor:[UIColor whiteColor]];
    [self.firstName.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.firstName.layer setBorderWidth:1.0];
    UIView *spacerView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 10)];
    [self.firstName setLeftViewMode:UITextFieldViewModeAlways];
    [self.firstName setLeftView:spacerView1];
    [self.firstName setDefaultTextAttributes:@{
                                               NSFontAttributeName: [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:20],
                                               NSForegroundColorAttributeName: [UIColor blackColor]
                                               }];
    self.firstName.placeholder = @"first name";
    self.firstName.text = appDelegate.user.firstName;
    [self.view addSubview:self.firstName];
    
    originY = originY + 64.0;
    self.lastName = [[UITextField alloc] initWithFrame:CGRectMake(margin, originY, screen.bounds.size.width -margin*2, 46.0)];
    [self.lastName setDelegate:self];
    [self.lastName setKeyboardType:UIKeyboardTypeDefault];
    self.lastName.autocorrectionType = UITextAutocorrectionTypeNo;
    self.lastName.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.lastName.borderStyle = UITextBorderStyleRoundedRect;
    [self.lastName.layer setCornerRadius:23.0f];
    [self.lastName setBackgroundColor:[UIColor whiteColor]];
    [self.lastName.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.lastName.layer setBorderWidth:1.0];
    UIView *spacerView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 10)];
    [self.lastName setLeftViewMode:UITextFieldViewModeAlways];
    [self.lastName setLeftView:spacerView2];
    [self.lastName setDefaultTextAttributes:@{
                                              NSFontAttributeName: [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:20],
                                              NSForegroundColorAttributeName: [UIColor blackColor]
                                              }];
    self.lastName.placeholder = @"last name";
    self.lastName.text = appDelegate.user.lastName;
    [self.view addSubview:self.lastName];
    
    originY = originY + 64.0;
    self.email = [[UITextField alloc] initWithFrame:CGRectMake(margin, originY, screen.bounds.size.width - margin*2, 46.0)];
    [self.email setDelegate:self];
    [self.email setKeyboardType:UIKeyboardTypeEmailAddress];
    self.email.autocorrectionType = UITextAutocorrectionTypeNo;
    self.email.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.email.borderStyle = UITextBorderStyleRoundedRect;
    self.email.borderStyle = UITextBorderStyleRoundedRect;
    [self.email.layer setCornerRadius:23.0f];
    [self.email setBackgroundColor:[UIColor whiteColor]];
    [self.email.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.email.layer setBorderWidth:1.0];
    UIView *spacerView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 10)];
    [self.email setLeftViewMode:UITextFieldViewModeAlways];
    [self.email setLeftView:spacerView3];
    [self.email setDefaultTextAttributes:@{
                                           NSFontAttributeName: [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:20],
                                           NSForegroundColorAttributeName: [UIColor blackColor]
                                           }];
    self.email.placeholder = @"email address";
    self.email.text = appDelegate.user.email;
    [self.view addSubview:self.email];
    
//    originY += 64.0;
//    self.saveDetails = [[UIButton alloc] initWithFrame:CGRectMake(margin, originY, screen.bounds.size.width - margin*2, 46.0)];
    self.saveDetails = [[UIButton alloc] initWithFrame:CGRectMake(0.0, screen.bounds.size.height - 60, screen.bounds.size.width, 60.0)];

    [self.saveDetails setTitle:@"SAVE DETAILS" forState:UIControlStateNormal];
    self.saveDetails.titleLabel.font = [UIFont fontWithName:@"DIN Condensed" size:24];
/**    [self.saveDetails.layer setCornerRadius:23.0f];
    [self.saveDetails setBackgroundColor:[UIColor whiteColor]];
    [self.saveDetails.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.saveDetails.layer setBorderWidth:1.0];
*/
    [self.saveDetails setBackgroundColor:[UIColor colorWithRed:57.0/255 green:181.0/255 blue:73.0/255 alpha:1.0]];
    [self.saveDetails setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.saveDetails addTarget:self action:@selector(saveDetails:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveDetails];
    
    
    
    originY += + 64.0;
    self.findFriendsButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, originY, screen.bounds.size.width, 50.0)];
    [self.findFriendsButton setTitle:@"INVITE FRIENDS" forState:UIControlStateNormal];
    self.findFriendsButton.titleLabel.font = [UIFont fontWithName:@"DIN Condensed" size:24];
    [self.findFriendsButton setBackgroundColor:[UIColor clearColor]];
    [self.findFriendsButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.findFriendsButton addTarget:self action:@selector(findFriends:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.findFriendsButton];
    
    originY += + 54.0;
    self.resetButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, originY, screen.bounds.size.width, 50.0)];
    [self.resetButton setTitle:@"RESET DEMO" forState:UIControlStateNormal];
    self.resetButton.titleLabel.font = [UIFont fontWithName:@"DIN Condensed" size:24];
    [self.resetButton setBackgroundColor:[UIColor clearColor]];
    [self.resetButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.resetButton addTarget:self action:@selector(resetDemo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.resetButton];
    
    originY += 54.0;
    self.signoutButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, originY, screen.bounds.size.width, 40.0)];
    [self.signoutButton setTitle:@"SIGN OUT" forState:UIControlStateNormal];
    self.signoutButton.titleLabel.font = [UIFont fontWithName:@"DIN Condensed" size:24];
    [self.signoutButton setBackgroundColor:[UIColor clearColor]];
    [self.signoutButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.signoutButton addTarget:self action:@selector(signout:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.signoutButton];
    
    
    
}



- (void)viewWillAppear:(BOOL)animated
{
    [controlView addSubview:self.homeButton];
    [controlView addSubview:self.categoriesButton];
    [controlView addSubview:navBorder];
    [controlView addSubview:dropShadow];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    keyboardHeight = keyboardFrameBeginRect.size.height;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
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
    animatedDistance = floor(keyboardHeight * heightFraction);
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}



- (void)actionHome:(id)sender
{
    appDelegate.selectedView = @"home";
    [self.navigationController popViewControllerAnimated:YES];
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


- (void)findFriends:(id)sender
{
    InviteFriendsViewController *inviteVeiw = [[InviteFriendsViewController alloc] init];
    appDelegate.selectedView = @"account";
    [self.navigationController pushViewController:inviteVeiw animated:YES];
}

- (void)resetDemo:(id)sender
{
    appDelegate.user.status = @"inactive";
    [HeyloData updateUser:appDelegate.user];
    [HeyloData clearContacts];
    [HeyloData clearMessages];
    [HeyloData clearConversations];
    exit(0);
}

- (void)signout:(id)sender
{
    exit(0);
}

- (void)saveDetails:(id)sender
{
    appDelegate.user.firstName = self.firstName.text;
    appDelegate.user.lastName = self.lastName.text;
    BOOL isValidEmail = NO;
    if (self.email.text && [User stringIsValidEmail:self.email.text]) {
        appDelegate.user.email = self.email.text;
        isValidEmail = YES;
    }
    
    if (isValidEmail && appDelegate.user.firstName.length > 0
        && appDelegate.user.lastName.length > 0) {
        if ([HeyloData updateUser:appDelegate.user]) {
            UIAlertView *saved = [[UIAlertView alloc]initWithTitle:@"Saved"
                                                                message:@"Your details have been updated."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [saved show];

        } else {
            UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                                message:@"Oops! Something went wrong saving your details."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorAlert show];
        }
    } else {
        UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Required Fields"
                                                            message:@"Please give us your first and last names, and a valid email address."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end
