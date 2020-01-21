//
//  UserDetailsViewController.m
//  notify
//
//  Created by Scott Parris on 4/17/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import "UserDetailsViewController.h"
#import "RegistrationViewController.h"
#import "AppDelegate.h"
#import "User.h"
#import "HeyloData.h"
#import "HeaderGradientView.h"
#import <QuartzCore/QuartzCore.h>

@interface UserDetailsViewController () {
    AppDelegate *appDelegate;
    CGFloat animatedDistance;
    CGFloat keyboardHeight;
}

@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UITextField *firstName;
@property (nonatomic, strong) UITextField *lastName;
@property (nonatomic, strong) UITextField *email;
@property (nonatomic, strong) UIButton *saveButton;

- (void)saveDetail:(id)sender;

@end

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;


@implementation UserDetailsViewController



- (void)loadView {
    [super loadView];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
    self.navigationController.navigationBarHidden = NO;
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
    doneButton.title = @"Done";
    doneButton.target = self;
    doneButton.action = @selector(saveDetail:);
    [self.navigationItem setRightBarButtonItem:doneButton];
    
    UIScreen *screen = [UIScreen mainScreen];
    HeaderGradientView *dropShadow = [[HeaderGradientView alloc] initWithFrame:CGRectMake(0, 64, screen.bounds.size.width, 12.0)];
    [self.view addSubview:dropShadow];
    self.mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 12.0, screen.bounds.size.width, screen.bounds.size.height -72.0)];
    self.mainView.backgroundColor = [UIColor clearColor];
    float originY = (self.mainView.bounds.size.height * 0.36)/2 + 35.0;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, originY, screen.bounds.size.width, 30.0)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:26];
    titleLabel.text = @"Lets get started!";
    titleLabel.textColor = [UIColor grayColor];
    [self.mainView addSubview:titleLabel];
    
    originY = originY + 48.0;
    UILabel *instructionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, originY, screen.bounds.size.width, 20.0)];
    instructionLabel.textAlignment = NSTextAlignmentCenter;
    instructionLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:18];
    instructionLabel.text = @"Sign up to start using Heylo";
    instructionLabel.textColor = [UIColor grayColor];
    [self.mainView addSubview:instructionLabel];

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
    [self.mainView addSubview:self.firstName];

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
    [self.mainView addSubview:self.lastName];
 
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
    [self.mainView addSubview:self.email];


    [self.view addSubview:self.mainView];
    
    self.saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, screen.bounds.size.height - 60, screen.bounds.size.width, 60.0)];
    [self.saveButton setTitle:@"SUBMIT" forState:UIControlStateNormal];
    self.saveButton.titleLabel.font = [UIFont fontWithName:@"DIN Condensed" size:24];
    [self.saveButton setBackgroundColor:[UIColor colorWithRed:57.0/255 green:181.0/255 blue:73.0/255 alpha:1.0]];
    [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.saveButton addTarget:self action:@selector(saveDetail:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveButton];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    keyboardHeight = keyboardFrameBeginRect.size.height;
}

// Useful artiicle
// http://www.cocoawithlove.com/2008/10/sliding-uitextfields-around-to-avoid.html
// Getting keyboard heignt from notification
//
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



- (void)saveDetail:(id)sender
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
            CATransition *transition = [CATransition animation];
            transition.duration = 0.5;
            transition.type = kCATransitionMoveIn;
            transition.subtype = kCATransitionFromRight;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [self.navigationController.view.layer addAnimation:transition forKey:nil];
            RegistrationViewController *regView = [[RegistrationViewController alloc] init];
            [self.navigationController pushViewController:regView animated:YES];
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

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
