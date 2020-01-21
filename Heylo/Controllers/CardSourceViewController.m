//
//  CardSourceViewController.m
//  Heylo
//
//  Created by Scott Parris on 6/11/15.
//  Copyright (c) 2015 Heylo. All rights reserved.
//

#import "CardSourceViewController.h"
#import "HeaderGradientView.h"
#import "AppDelegate.h"
#import "FlashView.h"

@interface CardSourceViewController () {
    AppDelegate *appDelegate;
}

@property (nonatomic, strong) FlashView *flashView;

- (void)actionCustomize;
- (void)showMessage;

@end

@implementation CardSourceViewController

@synthesize sourceURL, activityIndicator, webView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIScreen *screen = [UIScreen mainScreen];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.title = NSLocalizedString(@"CARD INFORMATION", @"CARD INFORMATION");
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
    backButton.action = @selector(actionCustomize);
    [self.navigationItem setLeftBarButtonItem:backButton];
    
   
    CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:frame];
    [self.activityIndicator sizeToFit];
    self.activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                                               UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    loadingView.target = self;
    self.navigationItem.rightBarButtonItem = loadingView;
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.scalesPageToFit = YES;
    [self.webView setDelegate:self];
    [self.view addSubview:self.webView];

    HeaderGradientView *dropShadow = [[HeaderGradientView alloc] initWithFrame:CGRectMake(0, 64, screen.bounds.size.width, 12.0)];
    [self.view addSubview:dropShadow];
    
    self.flashView = [[FlashView alloc] initWithScreenWidth:self.view.bounds.size.width];
    self.flashView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.sourceURL]]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"window.scrollTo(0.0, 50.0)"];
    [self.activityIndicator stopAnimating];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMessage) name:@"flashMessage" object:nil];
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

- (void)actionCustomize
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
