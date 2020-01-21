//
//  FindFriendsTableViewCell.m
//  notify
//
//  Created by Scott Parris on 4/24/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import "FindFriendsTableViewCell.h"

@implementation FindFriendsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.thumbnail = [[UIImageView alloc] init];
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.font = [UIFont boldSystemFontOfSize:18];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.thumbnail];
        [self.contentView addSubview:self.nameLabel];
        
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    self.thumbnail.frame = CGRectMake(boundsX + 10, 10, 24, 24);
    CALayer *imageLayer = self.thumbnail.layer;
   // [imageLayer setBorderWidth:1.0];
    [imageLayer setCornerRadius:12.0];
    [imageLayer setMasksToBounds:YES];
    self.nameLabel.frame = CGRectMake(boundsX + 40 ,10,contentRect.size.width - (boundsX + 40), 25);
    
}


@end
