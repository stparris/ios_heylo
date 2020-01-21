//
//  InboxTableViewCell.m
//  notify
//
//  Created by Scott Parris on 4/27/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import "InboxTableViewCell.h"

@implementation InboxTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.imagePlace = [[UIView alloc] init];
        self.imagePlace.translatesAutoresizingMaskIntoConstraints = NO;
        self.imagePlace.backgroundColor = [UIColor grayColor];
        self.thumbnail = [[UIImageView alloc] init];
        self.thumbnail.translatesAutoresizingMaskIntoConstraints = NO;
        self.unreadFlag = [[UIView alloc] init];
        self.unreadFlag.translatesAutoresizingMaskIntoConstraints = NO;
        self.contactsLabel = [[UILabel alloc] init];
        self.contactsLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.contactsLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.contactsLabel.numberOfLines = 0;
        [self.contactsLabel sizeToFit];
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.dateLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:12];
        self.dateLabel.textColor = [UIColor grayColor];
        self.messageText = [[UILabel alloc] init];
        self.messageText.translatesAutoresizingMaskIntoConstraints = NO;
        self.messageText.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageText.numberOfLines = 0;
        [self.messageText sizeToFit];
        self.messageIcon = [[UILabel alloc] init];
        self.messageIcon.translatesAutoresizingMaskIntoConstraints = NO;
        self.messageIcon.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:12];
        self.messageIcon.textColor = [UIColor grayColor];
        self.messageCount = [[UILabel alloc] init];
        self.messageCount.translatesAutoresizingMaskIntoConstraints = NO;
        self.messageCount.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:12];
        self.messageCount.textColor = [UIColor grayColor];
        
        [self.imagePlace addSubview:self.thumbnail];
        [self.contentView addSubview:self.imagePlace];
        [self.contentView addSubview:self.unreadFlag];
        [self.contentView addSubview:self.contactsLabel];
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.messageText];
        [self.contentView addSubview:self.messageIcon];
        [self.contentView addSubview:self.messageCount];
        
        NSDictionary *viewsDictionary = @{@"imagePlace":self.imagePlace,
                                          @"thumbnail":self.thumbnail,
                                          @"unreadFlag":self.unreadFlag,
                                          @"contactsLabel":self.contactsLabel,
                                          @"messageText":self.messageText,
                                          @"messageIcon":self.messageIcon,
                                          @"messageCount":self.messageCount,
                                          @"dateLabel":self.dateLabel
                                          };

        CGFloat imageSide = self.contentView.bounds.size.width/4 - 10;
 
        
        [self.imagePlace addConstraint:[NSLayoutConstraint constraintWithItem:self.imagePlace
                                        attribute:NSLayoutAttributeWidth
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                        attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                        constant:imageSide]];

        
        
        [self.imagePlace addConstraint:[NSLayoutConstraint constraintWithItem:self.imagePlace
                                        attribute:NSLayoutAttributeHeight
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                        attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                        constant:imageSide]];
        
        [self.thumbnail addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbnail
                                        attribute:NSLayoutAttributeWidth
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                        attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                        constant:imageSide - 2]];
        
        
        
        [self.thumbnail addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbnail
                                        attribute:NSLayoutAttributeHeight
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                        attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                        constant:imageSide - 2]];
        
        
        NSArray *constraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-1-[thumbnail]-1-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];

        NSArray *constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-1-[thumbnail]-1-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
        
        [self.imagePlace addConstraints:constraint_V];
        [self.imagePlace addConstraints:constraint_H];
        
        
        
        constraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[contactsLabel]-5-[messageText]-5-[messageIcon]-10-|"
                                                                options:0
                                                                metrics:nil
                                                                views:viewsDictionary];
        [self.contentView addConstraints:constraint_V];
        
        constraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[imagePlace]-5-[messageText]-5-[messageIcon]-10-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
        [self.contentView addConstraints:constraint_V];

        
        constraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[contactsLabel]-5-[messageText]-5-[messageCount]-10-|"
                                                               options:0
                                                               metrics:nil
                                                                 views:viewsDictionary];
        [self.contentView addConstraints:constraint_V];

        
        constraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[contactsLabel]-5-[messageText]-5-[dateLabel]-10-|"
                                                               options:0
                                                               metrics:nil
                                                                 views:viewsDictionary];
        [self.contentView addConstraints:constraint_V];

        constraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[imagePlace]-5-[messageText]-5-[messageIcon]-10-|"
                                                               options:0
                                                               metrics:nil
                                                                 views:viewsDictionary];
        [self.contentView addConstraints:constraint_V];
        
        constraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[unreadFlag(10)]"
                                                               options:0
                                                               metrics:nil
                                                                 views:viewsDictionary];
        [self.contentView addConstraints:constraint_V];
  
        

        
        
        
        constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[imagePlace]-5-[unreadFlag(10)]-5-[contactsLabel]-10-|"
                                                                options:0
                                                                metrics:nil
                                                                views:viewsDictionary];
        [self.contentView addConstraints:constraint_H];
        
        constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[messageText]-15-|"
                                                               options:0
                                                               metrics:nil
                                                                 views:viewsDictionary];
        [self.contentView addConstraints:constraint_H];



        
        
        constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[messageIcon]-5-[messageCount]|"
                                                                                options:0
                                                                                metrics:nil
                                                                                views:viewsDictionary];
        [self.contentView addConstraints:constraint_H];
        
        constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[dateLabel]-10-|"
                                                               options:0
                                                               metrics:nil
                                                                 views:viewsDictionary];
        [self.contentView addConstraints:constraint_H];
        
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    self.thumbnail.layer.borderColor = [UIColor whiteColor].CGColor;
    self.thumbnail.layer.borderWidth = 3;
    self.unreadFlag.layer.cornerRadius = 5;
    
}

/**
 
- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x + 10;
    CGFloat boundsY = contentRect.origin.y + 10;
//    CGFloat iconSize = contentRect.size.height - 20;
//    int fontSize = (int)(iconSize + 0.5) -2;
    CGFloat imageSide = contentRect.size.width/4 - boundsX;
    self.imagePlace.frame = CGRectMake(boundsX, boundsY, imageSide, imageSide);
    self.imagePlace.backgroundColor = [UIColor lightGrayColor];
    self.thumbnail.frame = CGRectMake(1, 1, imageSide -2, imageSide -2);
    self.thumbnail.layer.masksToBounds = YES;
    self.thumbnail.layer.borderColor = [UIColor whiteColor].CGColor;
    self.thumbnail.layer.borderWidth = 3;
    self.unreadFlag.frame = CGRectMake(imageSide + 18, boundsY +2, 10, 10);
    self.unreadFlag.layer.cornerRadius = 5;
    CGFloat marginT = boundsX + imageSide + 28;
    CGFloat textW = contentRect.size.width - (marginT + 10);

    self.contactsLabel.frame =  CGRectMake(marginT, boundsY, textW, 32);
    self.messageText.frame = CGRectMake(marginT, 45, textW, 20);
    self.messageIcon.frame = CGRectMake(marginT, imageSide, 16, 16);
    self.messageCount.frame = CGRectMake(marginT + 26, imageSide, 16, 16);
    self.dateLabel.frame = CGRectMake(marginT + 42, imageSide, contentRect.size.width - (marginT + 52), 16);
    

    self.contactsLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:14];
    self.contactsLabel.textAlignment = NSTextAlignmentLeft;
    self.messageText.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:14];
    self.messageText.textColor = [UIColor  grayColor];
    self.messageText.textAlignment = NSTextAlignmentLeft;
    self.messageIcon.font = [UIFont fontWithName:@"fontello" size:12];
    self.messageIcon.text = @"\uE904";
    self.messageIcon.textColor = [UIColor  grayColor];
    self.messageCount.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:12];
    self.messageCount.textColor = [UIColor  grayColor];
    self.dateLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:12];
    self.dateLabel.textColor = [UIColor  grayColor];
    self.dateLabel.textAlignment = NSTextAlignmentRight;

}
 */

@end

