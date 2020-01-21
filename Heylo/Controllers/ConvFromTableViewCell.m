//
//  ConvFromTableViewCell.m
//  notify
//
//  Created by Scott Parris on 4/27/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import "ConvFromTableViewCell.h"

@implementation ConvFromTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.avatarView = [[UIView alloc] init];
        self.avatarView.translatesAutoresizingMaskIntoConstraints = NO;
        // self.avatarView.backgroundColor = [UIColor yellowColor];
        self.avatar = [[UIImageView alloc] init];
        // self.avatar.backgroundColor = [UIColor blueColor];
        self.avatar.translatesAutoresizingMaskIntoConstraints = NO;
        [self.avatarView addSubview:self.avatar];
        
        self.pointerView = [[UIImageView alloc] init];
        // self.avatar.backgroundColor = [UIColor blueColor];
        self.pointerView.translatesAutoresizingMaskIntoConstraints = NO;
        // self.pointerView.backgroundColor = [UIColor yellowColor];
        [self.avatarView addSubview:self.pointerView];
        
        self.messageView = [[UIView alloc] init];
        self.messageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.messageTop = [[UIView alloc] init];
        self.messageTop.translatesAutoresizingMaskIntoConstraints = NO;
        //  self.messageTop.backgroundColor = [UIColor purpleColor];
        
        self.contactLabel = [[UILabel alloc] init];
        //  self.contactLabel.backgroundColor = [UIColor greenColor];
        self.contactLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.contactLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:14];
        [self.messageTop addSubview:self.contactLabel];
        
        self.dateLabel = [[UILabel alloc] init];
        //  self.dateLabel.backgroundColor = [UIColor grayColor];
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.dateLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:12];
        self.dateLabel.textAlignment = NSTextAlignmentRight;
        [self.messageTop addSubview:self.dateLabel];
        [self.messageView addSubview:self.messageTop];
        
        self.messageText = [[UILabel alloc] init];
        //   self.messageText.backgroundColor = [UIColor redColor];
        self.messageText.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageText.numberOfLines = 0;
        self.messageText.translatesAutoresizingMaskIntoConstraints = NO;
        self.messageText.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:14];
        [self.messageView addSubview:self.messageText];
        
        [self.contentView addSubview:self.avatarView];
        [self.contentView addSubview:self.messageView];
        
        NSDictionary *viewsDictionary = @{@"avatar":self.avatar,
                                          @"pointer":self.pointerView,
                                          @"avatarView":self.avatarView,
                                          @"messageView":self.messageView,
                                          @"messageTop":self.messageTop,
                                          @"contactLabel":self.contactLabel,
                                          @"dateLabel":self.dateLabel,
                                          @"messageText":self.messageText
                                          };
        
        NSArray *avatarView_constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[avatarView(40)]"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:viewsDictionary];
        [self.avatarView addConstraints:avatarView_constraint_H];
        NSArray *avatarView_constraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[avatarView(40)]"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:viewsDictionary];
        [self.avatarView addConstraints:avatarView_constraint_V];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[messageView]-10-|" options:0 metrics:nil views:viewsDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[avatarView][messageView]-20-|" options:0 metrics:nil views:viewsDictionary]];
        
        [self.contentView addConstraint:[NSLayoutConstraint
                                         constraintWithItem:self.avatarView
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:self.messageView
                                         attribute:NSLayoutAttributeBottom
                                         multiplier:1.0
                                         constant:0.0]];
        
        [self.avatarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[pointer]|" options:0 metrics:nil views:viewsDictionary]];
        [self.avatarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[pointer]-5-|" options:0 metrics:nil views:viewsDictionary]];
        
        
        [self.avatarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[avatar(30)]-10-|" options:0 metrics:nil views:viewsDictionary]];
        [self.avatarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[avatar(30)]-10-|" options:0 metrics:nil views:viewsDictionary]];
        
        [self.messageTop addConstraint:[NSLayoutConstraint
                                        constraintWithItem:self.contactLabel
                                        attribute:NSLayoutAttributeTop
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:self.messageTop
                                        attribute:NSLayoutAttributeTop
                                        multiplier:1.0
                                        constant:3.0]];
        
        [self.messageTop addConstraint:[NSLayoutConstraint
                                        constraintWithItem:self.dateLabel
                                        attribute:NSLayoutAttributeTop
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:self.messageTop
                                        attribute:NSLayoutAttributeTop
                                        multiplier:1.0
                                        constant:3.0]];
        
        [self.messageTop addConstraint:[NSLayoutConstraint
                                        constraintWithItem:self.contactLabel
                                        attribute:NSLayoutAttributeBottom
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:self.messageTop
                                        attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                        constant:3.0]];
        
        [self.messageTop addConstraint:[NSLayoutConstraint
                                        constraintWithItem:self.dateLabel
                                        attribute:NSLayoutAttributeBottom
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:self.messageTop
                                        attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                        constant:3.0]];
        
        
        [self.messageTop addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[contactLabel]-6-[dateLabel]-10-|" options:0 metrics:nil views:viewsDictionary]];
        [self.messageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[messageText]-10-|" options:0 metrics:nil views:viewsDictionary]];
        
  
        NSArray *topConstraintH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[messageTop]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:viewsDictionary];
        [self.messageView addConstraints:topConstraintH];
        
        
        
        
        NSArray *topConstraintV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[messageTop]-5-[messageText]-10-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:viewsDictionary];
        [self.messageView addConstraints:topConstraintV];
 
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];

    self.messageText.preferredMaxLayoutWidth = CGRectGetWidth(self.messageText.frame);
    self.messageView.layer.cornerRadius = 5.0;
    self.messageView.backgroundColor = self.messageColor;
    
    self.avatar.layer.cornerRadius = 15;
    self.avatar.clipsToBounds = YES;
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(20, 20)];
    [path addLineToPoint:CGPointMake(10, 25)];
    [path addLineToPoint:CGPointMake(20, 30)];
    //apply path to shapelayer
    CAShapeLayer* pointerPath = [CAShapeLayer layer];
    pointerPath.path = path.CGPath;
    [pointerPath setFillColor:self.messageColor.CGColor];
    pointerPath.frame=CGRectMake(0, 0,15,15);
    [self.pointerView.layer addSublayer:pointerPath];
    
    
}



@end
