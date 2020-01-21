//
//  HomeViewController.m
//  notify
//
//  Created by Scott Parris on 4/17/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import "HomeViewController.h"
#import "CardCategoryViewController.h"
#import "CardSelectViewController.h"
#import "AppDelegate.h"
#import "FlashView.h"
#import "PopupView.h"
#import "User.h"

@interface HomeViewController () <CardSelectViewControllerDelegate> {
    AppDelegate *appDelegate;
}

@property (nonatomic, strong) CardSelectViewController *cardSelectViewController;
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

@implementation HomeViewController

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
    self.cardSelectViewController = [[CardSelectViewController alloc] init];
    self.cardSelectViewController.view.tag = SELECT_TAG;
    self.cardSelectViewController.delegate = self;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:self.cardSelectViewController.view];
    [self addChildViewController:_cardSelectViewController];
    self.flashView = [[FlashView alloc] initWithScreenWidth:self.view.bounds.size.width];
    self.flashView.hidden = YES;
    [self.view addSubview:self.flashView];
    
    if ([appDelegate.user.status isEqualToString:@"beginer"] ||
        [appDelegate.user.status isEqualToString:@"novice"]  ||
        [appDelegate.user.status isEqualToString:@"racer"]) {
        PopupView *favoritePopup = [[PopupView alloc] init];
        favoritePopup.gotIt.tag = 3;
        favoritePopup.hideButton.tag = 3;
        [self.view addSubview:favoritePopup];
        NSString *title = @"MY FAVORITES";
        NSString *message = @"Mark your favorite cards by tapping the heart buttons:";
        [favoritePopup showPopup:title message:message icon:@"\uE821"];
    }

    
    
    [_cardSelectViewController didMoveToParentViewController:self];
}


- (void)showCategoriesWithShadow:(BOOL)value withOffset:(double)offset
{
    if (value) {
        [_cardSelectViewController.view.layer setCornerRadius:CORNER_RADIUS];
        [_cardSelectViewController.view.layer setShadowColor:[UIColor blackColor].CGColor];
        [_cardSelectViewController.view.layer setShadowOpacity:0.8];
        [_cardSelectViewController.view.layer setShadowOffset:CGSizeMake(offset, offset)];
    } else {
        [_cardSelectViewController.view.layer setCornerRadius:0.0f];
        [_cardSelectViewController.view.layer setShadowOffset:CGSizeMake(offset, offset)];
    }
}

- (void)resetCardSelectView
{
    // remove left view and reset variables, if needed
    if (_cardCategoryViewController != nil)
    {
        [self.cardCategoryViewController.view removeFromSuperview];
        self.cardCategoryViewController = nil;
        
        _cardSelectViewController.categoriesButton.tag = 1;
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
                         _cardSelectViewController.view.frame = CGRectMake(self.view.frame.size.width - PANEL_WIDTH, 0, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                             _cardSelectViewController.categoriesButton.tag = 0;
                         }
                     }];
    
}

- (void)movePanelToOriginalPosition
{
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _cardSelectViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
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



@end
