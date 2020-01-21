//
//  MessagesViewController.m
//  notify
//
//  Created by Scott Parris on 4/26/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import "MessagesViewController.h"
#import "CardCategoryViewController.h"
#import "InboxViewController.h"
#import "AppDelegate.h"
#import "FlashView.h"

@interface MessagesViewController () <InboxViewControllerDelegate> {
    AppDelegate *appDelegate;
}

@property (nonatomic, strong) InboxViewController *inboxViewController;
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

@implementation MessagesViewController

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
    self.inboxViewController = [[InboxViewController alloc] init];
    self.inboxViewController.view.tag = SELECT_TAG;
    self.inboxViewController.delegate = self;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    [self.view addSubview:self.inboxViewController.view];
    [self addChildViewController:self.inboxViewController];
    self.flashView = [[FlashView alloc] initWithScreenWidth:self.view.bounds.size.width];
    self.flashView.hidden = YES;
    [self.view addSubview:self.flashView];
    [self.inboxViewController didMoveToParentViewController:self];
}


- (void)showCategoriesWithShadow:(BOOL)value withOffset:(double)offset
{
    if (value) {
        [_inboxViewController.view.layer setCornerRadius:CORNER_RADIUS];
        [_inboxViewController.view.layer setShadowColor:[UIColor blackColor].CGColor];
        [_inboxViewController.view.layer setShadowOpacity:0.8];
        [_inboxViewController.view.layer setShadowOffset:CGSizeMake(offset, offset)];
    } else {
        [_inboxViewController.view.layer setCornerRadius:0.0f];
        [_inboxViewController.view.layer setShadowOffset:CGSizeMake(offset, offset)];
    }
}

- (void)resetCardSelectView
{
    // remove left view and reset variables, if needed
    if (_cardCategoryViewController != nil)
    {
        [self.cardCategoryViewController.view removeFromSuperview];
        self.cardCategoryViewController = nil;
        
        _inboxViewController.categoriesButton.tag = 1;
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
                         _inboxViewController.view.frame = CGRectMake(self.view.frame.size.width - PANEL_WIDTH, 0, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                             _inboxViewController.categoriesButton.tag = 0;
                         }
                     }];
    
}

- (void)movePanelToOriginalPosition
{
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _inboxViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
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
