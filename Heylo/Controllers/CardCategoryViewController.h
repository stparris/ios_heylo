//
//  CardCategoryViewController.h
//  heylo
//
//  Created by Scott Parris on 2/26/15.
//  Copyright (c) 2015 TapIn. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CardCategoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UILabel *inboxCountLabel;

@end
