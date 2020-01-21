 //
//  RegistrationViewController.m
//  notify
//
//  Created by Scott Parris on 4/17/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import "RegistrationViewController.h"
#import "AppDelegate.h"
#import "CountryCodeViewController.h"
#import "User.h"
#import "Contact.h"
#import "Country.h"
#import "HeyloData.h"
#import "HeyloConnection.h"
#import "HeaderGradientView.h"
#import "PopupView.h"

@interface RegistrationViewController () {
    AppDelegate *appDelegate;
    CGSize kbSize;
    UIView *confirmView;
    UIAlertView *confirmationCode;
    PopupView *confirmationError;
}

@property (nonatomic, strong) UITextField *phoneNumber;
@property (nonatomic, strong) UIButton *registerButton;
@property (nonatomic, strong) UIButton *countryCodeButton;
@property (nonatomic, strong) UILabel *countryCode;
@property (nonatomic, strong) UILabel *countryLabel;

- (void)registerPhone:(id)sender;

@end

@implementation RegistrationViewController

- (void)loadView {
    [super loadView];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
    self.navigationItem.hidesBackButton = YES;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.view.backgroundColor = [UIColor whiteColor]; //[UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
    self.title = NSLocalizedString(@"SIGN UP", @"SIGN UP");
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor], NSForegroundColorAttributeName,
      [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:24],
      NSFontAttributeName, nil]];
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] init];
    [doneButton setTitleTextAttributes:@{
                                         NSFontAttributeName: [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:20],
                                         NSForegroundColorAttributeName: [UIColor blackColor]
                                         } forState:UIControlStateNormal];
    doneButton.title = @"Submit";
    doneButton.target = self;
    doneButton.action = @selector(registerPhone:);
    [self.navigationItem setRightBarButtonItem:doneButton];
    
    
    

    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat navWidth = self.navigationController.navigationBar.frame.size.width;
    CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
    
    UIView *navBorder = [[UIView alloc] initWithFrame:CGRectMake(0,navHeight -2, navWidth, 2)];
    navBorder.tag = 1;
    //navBorder.backgroundColor = [UIColor grayColor];
    navBorder.backgroundColor = [UIColor colorWithRed:140.0/255.0 green:140.0/255.0 blue:140.0/255.0 alpha:1.0];
    [self.navigationController.navigationBar addSubview:navBorder];
    
    
    UIView *phoneBar = [[UIView alloc]initWithFrame:CGRectMake(0.0, navHeight + statusBarSize.height, screen.bounds.size.width, 80.0)];
    phoneBar.backgroundColor = [UIColor colorWithRed:210.0/255 green:78.0/255 blue:59.0/255 alpha:1.0];

    self.countryCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.countryCodeButton.backgroundColor = [UIColor colorWithRed:231.0/255 green:113.0/255 blue:85.0/255 alpha:1.0];
    self.countryCodeButton.frame = CGRectMake(0.0, 0.0, 80.0, 80.0);
    self.countryCode = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, 80, 24)];
    self.countryCode.text = appDelegate.user.country.dialingCode;
    self.countryCode.font = [self.countryCode.font fontWithSize:24];
    self.countryCode.textAlignment = NSTextAlignmentCenter;
    self.countryCode.textColor = [UIColor colorWithRed:237.0/255 green:184.0/255 blue:177.0/255 alpha:1.0];
    [self.countryCodeButton addSubview:self.countryCode];
    
    self.countryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 80, 10)];
    self.countryLabel.text = appDelegate.user.country.isoCode;
    self.countryLabel.font = [self.countryLabel.font fontWithSize:12];
    self.countryLabel.textAlignment = NSTextAlignmentCenter;
    self.countryLabel.textColor = [UIColor whiteColor]; //[UIColor colorWithRed:237.0/255 green:184.0/255 blue:177.0/255 alpha:1.0];
    [self.countryCodeButton addSubview:self.countryLabel];
    [self.countryCodeButton addTarget:self action:@selector(countryCode:) forControlEvents:UIControlEventTouchUpInside];
    [phoneBar addSubview:self.countryCodeButton];

    self.phoneNumber = [[UITextField alloc] initWithFrame:CGRectMake(100.0, 0, screen.bounds.size.width - 120, 80)];
    [self.phoneNumber setDefaultTextAttributes:@{
                                              NSFontAttributeName: [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:24],
                                              NSForegroundColorAttributeName: [UIColor colorWithRed:237.0/255 green:184.0/255 blue:177.0/255 alpha:1.0]
                                              }];
    self.phoneNumber.attributedPlaceholder =
        [[NSAttributedString alloc] initWithString:@"Phone Number" attributes:
        @{NSForegroundColorAttributeName:
        [UIColor colorWithRed:237.0/255 green:184.0/255 blue:177.0/255 alpha:1.0]}];
    self.phoneNumber.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneNumber.textColor = [UIColor colorWithRed:237.0/255 green:184.0/255 blue:177.0/255 alpha:1.0];
    [self.phoneNumber setDelegate:self];
    [self.phoneNumber becomeFirstResponder];
    [phoneBar addSubview:self.phoneNumber];
    
    self.registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.registerButton.frame = CGRectMake(screen.bounds.size.width - 80, 0, 80, 80);
    self.registerButton.titleLabel.font = [UIFont fontWithName:@"fontello" size:24];
    self.registerButton.titleLabel.textAlignment = NSTextAlignmentRight;
    [self.registerButton setTitle:@" \uE9FC" forState:UIControlStateNormal]; //   EA04
    [self.registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.registerButton.titleLabel.textColor = [UIColor whiteColor];
    [self.registerButton addTarget:self action:@selector(registerPhone:) forControlEvents:UIControlEventTouchUpInside];
    [phoneBar addSubview:self.registerButton];
    
    HeaderGradientView *dropShadow = [[HeaderGradientView alloc] initWithFrame:CGRectMake(0, 0, screen.bounds.size.width, 12.0)];
    [phoneBar addSubview:dropShadow];
    [self.view addSubview:phoneBar];
    CGFloat usedScreen = (kbSize.height + 80);

    UILabel *digitsTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0, (screen.bounds.size.height - usedScreen)/2 - 40, screen.bounds.size.width, 30)];
    digitsTitle.textAlignment = NSTextAlignmentCenter;
    digitsTitle.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:26];
    digitsTitle.text = @"Give us your digits.";
    digitsTitle.textColor = [UIColor grayColor];
    [self.view addSubview:digitsTitle];
    
    UILabel *digitsText1 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, (screen.bounds.size.height - usedScreen)/2 + 15, screen.bounds.size.width, 20)];
    digitsText1.textAlignment = NSTextAlignmentCenter;
    digitsText1.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:18];
    digitsText1.text = @"Enter your phone number so";
    digitsText1.textColor = [UIColor grayColor];
    [self.view addSubview:digitsText1];

    UILabel *digitsText2 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, (screen.bounds.size.height - usedScreen)/2 + 40, screen.bounds.size.width, 20)];
    digitsText2.textAlignment = NSTextAlignmentCenter;
    digitsText2.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:18];
    digitsText2.text = @"we know you're a real person";
    digitsText2.textColor = [UIColor grayColor];
    [self.view addSubview:digitsText2];
    
    confirmationError = [[PopupView alloc] init];
    confirmationError.gotIt.tag = 7;
    [confirmationError.gotIt setTitle:@"OK" forState:UIControlStateNormal];
    confirmationError.hideButton.tag = 7;
    [self.view addSubview:confirmationError];
    
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.countryCode.text = appDelegate.user.country.dialingCode;
    self.countryLabel.text = appDelegate.user.country.isoCode;
}

- (void)registerPhone:(id)sender
{
    if (self.phoneNumber.text.length > 5) {
        [self.phoneNumber resignFirstResponder];
        NSString *pnum = self.phoneNumber.text;
        if ([appDelegate.user.country.dialingCode isEqualToString:@"+1"] && [self.phoneNumber.text characterAtIndex:0] == '1') {
            pnum = [self.phoneNumber.text substringFromIndex:1];
        }
        
        appDelegate.user.phoneNumber = pnum;
        [HeyloConnection requestConfirmationCode];
        confirmationCode = [[UIAlertView alloc]initWithTitle:@"Confirmation Code"
                                                     message:@"Please enter the code from the message sent to your phone:"
                                                    delegate:self
                                           cancelButtonTitle:@"Resend" otherButtonTitles:nil];
        [confirmationCode addButtonWithTitle:@"OK"];
        confirmationCode.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *tf = [confirmationCode textFieldAtIndex:0];
        tf.keyboardType = UIKeyboardTypeNumberPad;
        [confirmationCode show];
    }
}


- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        // NSLog(@"Using the Textfield: %@",[[alertView textFieldAtIndex:0] text]);
        [confirmationCode dismissWithClickedButtonIndex:1 animated:YES];
        NSDictionary *resultsDoc = [HeyloConnection confirmationWithCode:[[alertView textFieldAtIndex:0] text]];
        if ([[resultsDoc objectForKey:@"success"] isEqualToString:@"true"]) {
            // Create contact for user
            NSNumber *ts = [HeyloData getTimestamp];
            appDelegate.myself = [[Contact alloc] initWithId:[NSNumber numberWithInt:1] abRecord:[NSNumber numberWithInt:1] heyloId:appDelegate.user.heyloId phoneNumber:appDelegate.user.phoneNumber firstName:appDelegate.user.firstName lastName:appDelegate.user.lastName avatar:@"default_avatar" activityDate:ts createdDate:ts];
            if ([HeyloData createContact:appDelegate.myself]) {
                appDelegate.selectedView = @"find_friends";
                [self.navigationController popToRootViewControllerAnimated:NO];
            } else {
                UIAlertView *appError = [[UIAlertView alloc] initWithTitle:@"App Error"
                                                                            message:@"Unable to save details for some reason (out of storage space?)."
                                                                           delegate:self
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                [appError show];
            }
        } else {
            [confirmationError showPopup:@"Confirmation Error" message:@"The confirmation code you entered does not match. Please try again." icon:@""];
            
        }
    } else {
        [self.phoneNumber becomeFirstResponder];
    }
}

- (void)countryCode:(id)sender
{
    CountryCodeViewController *countryView = [[CountryCodeViewController alloc] init];
    [self.navigationController pushViewController:countryView animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
