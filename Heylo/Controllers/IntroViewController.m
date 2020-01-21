//
//  IntroViewController.m
//  notify
//
//  Created by Scott Parris on 4/17/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import "IntroViewController.h"
#import "RootViewController.h"
#import "UserDetailsViewController.h"
#import "AppDelegate.h"

@interface IntroViewController () {
    AppDelegate *appDelegate;
    UIImageView *logo;
}

@property (nonatomic, strong) UITextView *text1;
@property (nonatomic, strong) UITextView *text2;
@property (nonatomic, strong) UITextView *text3;

- (void)goToNextVeiw:(id)sender;

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBarHidden = YES;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIScreen *screen = [UIScreen mainScreen];
    UIImageView *introView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screen.bounds.size.width, screen.bounds.size.height)];
    [introView setContentMode:UIViewContentModeScaleAspectFill];
    [introView setClipsToBounds:YES];
    introView.image = [UIImage imageNamed:@"heylo_intro.png"];
    [self.view addSubview:introView];
}

- (void)viewDidAppear:(BOOL)animated
{
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat originY = screen.bounds.size.height * 0.6;
    CGFloat originX = 20.0;
    CGFloat logoW = screen.bounds.size.width * 0.47;
    CGFloat logoH = logoW * 0.42;
    logo = [[UIImageView alloc] initWithFrame:CGRectMake(originX + 20, originY, logoW, logoH)];
    logo.image = [UIImage imageNamed:@"heylo_logo.png"];
    [self.view addSubview:logo];
    UIColor *bgColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    UIColor *textColor = [UIColor whiteColor];
    UIFont *font = [UIFont fontWithName:@"AppleSDGothicNeo-Thin" size:24];
    CGFloat textX = 12;
    CGFloat textY = -5;
    self.text1 = [[UITextView alloc] init];
    self.text1.text = @"heylo lets you send";
    self.text1.font = font;
    self.text1.textColor = textColor;
    CGSize size = [self getStringSize:self.text1.text];
    originY = originY + logoH + 20;
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(originX, originY, size.width + 40, 32)];
    self.text1.frame = CGRectMake(textX, textY, size.width + 20, 32);
    self.text1.backgroundColor = [UIColor clearColor];
    self.text1.editable = NO;
    view1.backgroundColor = bgColor;
    [view1 addSubview:self.text1];
    [self.view addSubview:view1];
    
    self.text2 = [[UITextView alloc] init];
    self.text2.text = @"postcard messages";
    self.text2.font = font;
    self.text2.textColor = textColor;
    size = [self getStringSize:self.text2.text];
    originY = originY + 38;
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(originX, originY, size.width + 40, 32)];
    self.text2.frame = CGRectMake(textX, textY, size.width + 20, 32);
    self.text2.backgroundColor = [UIColor clearColor];
    self.text2.editable = NO;
    view2.backgroundColor = bgColor;
    [view2 addSubview:self.text2];
    [self.view addSubview:view2];
    
    self.text3 = [[UITextView alloc] init];
    self.text3.text = @"to your friends.";
    self.text3.font = font;
    self.text3.textColor = textColor;
    size = [self getStringSize:self.text3.text];
    originY = originY + 38;
    UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(originX, originY, size.width + 40, 32)];
    self.text3.frame = CGRectMake(textX, textY, size.width + 20, 32);
    self.text3.backgroundColor = [UIColor clearColor];
    self.text3.editable = NO;
    view3.backgroundColor = bgColor;
    [view3 addSubview:self.text3];
    [self.view addSubview:view3];
    UIButton *nextView = [UIButton buttonWithType:UIButtonTypeCustom];
    nextView.frame = screen.bounds;
    [nextView addTarget:self action:@selector(goToNextVeiw:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextView];
}


- (void)goToNextVeiw:(id)sender
{
    NSLog(@"===================== touched");
    CATransition *transition = [CATransition animation];
    transition.duration = 0;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    UserDetailsViewController *userDetail = [[UserDetailsViewController alloc] init];
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController pushViewController:userDetail animated:NO];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *tv = object;
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
}

- (CGSize)getStringSize:(NSString *)_string
{
    CGSize size = [_string sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:24]}];
    return size;
}


- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
