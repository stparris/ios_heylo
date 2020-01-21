//
//  CardSelectViewController.h
//  heylo
//
//  Created by Scott Parris on 3/1/15.
//  Copyright (c) 2015 TapIn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardCategoryViewController.h"

@protocol CardSelectViewControllerDelegate <NSObject>

@optional
- (void)movePanelRight;

@required
- (void)movePanelToOriginalPosition;

@end

@class AppDelegate;

@interface CardSelectViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    AppDelegate *appDelegate;
}

@property (nonatomic, assign) id<CardSelectViewControllerDelegate> delegate;
@property (nonatomic, strong) UIButton *categoriesButton;
@property (nonatomic, strong) UIButton *accountButton;
@property (nonatomic, strong) UIButton *allButton;
@property (nonatomic, strong) UIButton *popularButton;
@property (nonatomic, strong) UIButton *recentButton;
@property (nonatomic, strong) UIView *popularSelected;
@property (nonatomic, strong) UIView *recentSelected;
@property (nonatomic, strong) UIView *allSelected;
@property (nonatomic, strong) UILabel *inboxCountLabel;

@end
