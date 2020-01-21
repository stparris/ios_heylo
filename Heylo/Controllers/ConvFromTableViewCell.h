//
//  ConvFromTableViewCell.h
//  notify
//
//  Created by Scott Parris on 4/27/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConvFromTableViewCell : UITableViewCell

@property (nonatomic, strong) UIView *avatarView;
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UIView *pointerView;
@property (nonatomic, strong) UIView *messageView;
@property (nonatomic, strong) UIView *messageTop;
@property (nonatomic, strong) UILabel *contactLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *messageText;
@property (nonatomic, strong) UIColor *messageColor;


@end
