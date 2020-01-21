//
//  CardCategoryCell.h
//  heylo
//
//  Created by Scott Parris on 3/3/15.
//  Copyright (c) 2015 TapIn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardCategoryCell : UITableViewCell


@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *categoryIcon;
@property (nonatomic, strong) UIView *selectedIndicator;

@end
