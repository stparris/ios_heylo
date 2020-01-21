//
//  SendCardTableViewCell.m
//  notify
//
//  Created by Scott Parris on 4/26/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import "SendCardTableViewCell.h"

@implementation SendCardTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.thumbnail = [[UIImageView alloc] init];
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.selectLabel = [[UILabel alloc] init];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.thumbnail];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.selectLabel];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGFloat iconSize = contentRect.size.height - 20;
    int fontSize = (int)(iconSize + 0.5) -2;
    self.thumbnail.frame = CGRectMake(boundsX + 10, 10, iconSize, iconSize);
    CALayer *imageLayer = self.thumbnail.layer;
    //[imageLayer setBorderWidth:1.0];
    [imageLayer setCornerRadius:iconSize/2];
    [imageLayer setMasksToBounds:YES];
    self.nameLabel.frame = CGRectMake(boundsX + iconSize + 20,15,contentRect.size.width - (iconSize*2 + boundsX + 10), 25);
    self.nameLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:20];
    self.selectLabel.frame = CGRectMake(contentRect.size.width - (iconSize + 10), 10, iconSize, iconSize);
    self.selectLabel.font = [UIFont fontWithName:@"fontello" size:fontSize];
}

@end
