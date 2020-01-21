//
//  RootViewController.m
//  notify
//
//  Created by Scott Parris on 3/30/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import "RootViewController.h"
#import "AppDelegate.h"
#import "ImageCache.h"
#import "User.h"
#import "CardCategory.h"
#import "CardImage.h"
#import "IntroViewController.h"
#import "FindFriendsViewController.h"
#import "InviteFriendsViewController.h"
#import "MessagesViewController.h"
#import "AccountViewController.h"
#import "CardCustomizeViewController.h"
#import "HomeViewController.h"

@interface RootViewController () {

}

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.activityIndicator startAnimating];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:animated];
    if ([appDelegate.selectedView isEqualToString:@"customize"]) {
        appDelegate.selectedView = @"home";
        CardCustomizeViewController *cardView = [[CardCustomizeViewController alloc] init];
        [self.navigationController pushViewController:cardView animated:NO];
    } else if ([appDelegate.selectedView isEqualToString:@"backToHome"]) {
        HomeViewController *homeView = [[HomeViewController alloc] init];
        [self.navigationController pushViewController:homeView animated:NO];
    } else if ([appDelegate.selectedView isEqualToString:@"inbox"]) {
        MessagesViewController *messagesView = [[MessagesViewController alloc] init];
        [self.navigationController pushViewController:messagesView animated:NO];
    } else if ([appDelegate.selectedView isEqualToString:@"account"]) {
        AccountViewController *acctView = [[AccountViewController alloc] init];
        [self.navigationController pushViewController:acctView animated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([appDelegate.selectedView isEqualToString:@"home"]) {
        if (appDelegate.categories.count < 1) {
            [appDelegate.imageCache loadCache];
            if (appDelegate.selectedCategory == nil) {
                appDelegate.selectedCategory = appDelegate.defaultCategory;
            }
        
            HomeViewController *homeView = [[HomeViewController alloc] init];
            [self.navigationController pushViewController:homeView animated:NO];
        } else {
            if (appDelegate.selectedCategory == nil) {
                appDelegate.selectedCategory = appDelegate.defaultCategory;
            }
            HomeViewController *homeView = [[HomeViewController alloc] init];
            [self.navigationController pushViewController:homeView animated:NO];
        }
     
    } else {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.5;
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromRight;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [self.navigationController.view.layer addAnimation:transition forKey:nil];
    }
    if ([appDelegate.selectedView isEqualToString:@"intro"]) {
        IntroViewController *introView = [[IntroViewController alloc] init];
        [self.navigationController pushViewController:introView animated:YES];
    } else if ([appDelegate.selectedView isEqualToString:@"find_friends"]) {
        FindFriendsViewController *friendsView = [[FindFriendsViewController alloc] init];
        [self.navigationController pushViewController:friendsView animated:YES];
    } else if ([appDelegate.selectedView isEqualToString:@"invite_friends"]) {
        InviteFriendsViewController *friendsView = [[InviteFriendsViewController alloc] init];
        [self.navigationController pushViewController:friendsView animated:YES];
    }
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
