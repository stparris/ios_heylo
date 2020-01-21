//
//  AccountViewController.m
//  Heylo
//
//  Created by Scott Parris on 6/14/15.
//  Copyright (c) 2015 Heylo. All rights reserved.
//

#import "AccountViewController.h"
#import "CardCategoryViewController.h"
#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "FlashView.h"



@interface AccountViewController () <SettingsViewControllerDelegate> {
    AppDelegate *appDelegate;
}

@property (nonatomic, strong) SettingsViewController *settingsViewController;
@property (nonatomic, strong) CardCategoryViewController *cardCategoryViewController;
@property (nonatomic, assign) BOOL showingCategories;
@property (nonatomic, strong) UIBarButtonItem *categoriesButton;
@property (nonatomic, strong) FlashView *flashView;

- (void)showMessage;

@end

#define CATEGORY_PANEL_TAG 2
#define SELECT_TAG 1
#define CORNER_RADIUS 4
#define SLIDE_TIMING .25
#define PANEL_WIDTH 60

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self setupCardSelect];
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

- (void)setupCardSelect
{
    self.settingsViewController = [[SettingsViewController alloc] init];
    self.settingsViewController.view.tag = SELECT_TAG;
    self.settingsViewController.delegate = self;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    [self.view addSubview:self.settingsViewController.view];
    [self addChildViewController:self.settingsViewController];
    self.flashView = [[FlashView alloc] initWithScreenWidth:self.view.bounds.size.width];
    self.flashView.hidden = YES;
    [self.view addSubview:self.flashView];
    [self.settingsViewController didMoveToParentViewController:self];
}


- (void)showCategoriesWithShadow:(BOOL)value withOffset:(double)offset
{
    if (value) {
        [_settingsViewController.view.layer setCornerRadius:CORNER_RADIUS];
        [_settingsViewController.view.layer setShadowColor:[UIColor blackColor].CGColor];
        [_settingsViewController.view.layer setShadowOpacity:0.8];
        [_settingsViewController.view.layer setShadowOffset:CGSizeMake(offset, offset)];
    } else {
        [_settingsViewController.view.layer setCornerRadius:0.0f];
        [_settingsViewController.view.layer setShadowOffset:CGSizeMake(offset, offset)];
    }
}

- (void)resetCardSelectView
{
    // remove left view and reset variables, if needed
    if (_cardCategoryViewController != nil)
    {
        [self.cardCategoryViewController.view removeFromSuperview];
        self.cardCategoryViewController = nil;
        
        _settingsViewController.categoriesButton.tag = 1;
        self.showingCategories = NO;
    }
    
    // remove view shadows
    [self showCategoriesWithShadow:NO withOffset:0];
}

- (UIView *)getCategoryView
{
    if (_cardCategoryViewController == nil) {
        self.cardCategoryViewController = [[CardCategoryViewController alloc] init];
        self.cardCategoryViewController.view.tag = CATEGORY_PANEL_TAG;
        
        [self.view addSubview:self.cardCategoryViewController.view];
        [self addChildViewController:_cardCategoryViewController];
        [_cardCategoryViewController didMoveToParentViewController:self];
        
        _cardCategoryViewController.view.frame =  CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    self.navigationController.navigationBarHidden = YES;
    self.showingCategories = YES;
    
    [self showCategoriesWithShadow:YES withOffset:-2];
    
    UIView *view = self.cardCategoryViewController.view;
    
    return view;
}

- (void)movePanelRight // to show left panel
{
    UIView *childView = [self getCategoryView];
    [self.view sendSubviewToBack:childView];
    
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _settingsViewController.view.frame = CGRectMake(self.view.frame.size.width - PANEL_WIDTH, 0, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                             _settingsViewController.categoriesButton.tag = 0;
                         }
                     }];
    
}

- (void)movePanelToOriginalPosition
{
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _settingsViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                             [self resetCardSelectView];
                         }
                     }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
