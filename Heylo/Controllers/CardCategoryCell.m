//
//  CardCategoryCell.m
//  heylo
//
//  Created by Scott Parris on 3/3/15.
//  Copyright (c) 2015 TapIn. All rights reserved.
//

#import "CardCategoryCell.h"

@implementation CardCategoryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
        self.categoryIcon = [[UILabel alloc] init];
        self.categoryIcon.font = [UIFont fontWithName:@"fontello" size:18];
        self.categoryIcon.textColor = [UIColor whiteColor];
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.font = [UIFont fontWithName:@"DIN Condensed" size:24];
        self.nameLabel.textColor = [UIColor whiteColor];
        self.selectedIndicator = [[UIView alloc] init];
        self.selectedIndicator.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.categoryIcon];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.selectedIndicator];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGRect frame;
    
    frame= CGRectMake(boundsX+20 ,12, 18, 18);
    self.categoryIcon.frame = frame;
    
    frame= CGRectMake(boundsX+50 ,12, 400, 25);
    self.nameLabel.frame = frame;

    frame= CGRectMake(0, 0, 5, contentRect.size.height);
    self.selectedIndicator.frame = frame;

    
}

@end
