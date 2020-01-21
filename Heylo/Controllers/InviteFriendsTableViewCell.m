//
//  InviteFriendsTableViewCell.m
//  notify
//
//  Created by Scott Parris on 4/23/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import "InviteFriendsTableViewCell.h"

@implementation InviteFriendsTableViewCell

@synthesize addLabel, nameLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.addLabel = [[UILabel alloc] init];
        self.addLabel.textAlignment = NSTextAlignmentLeft;
        self.addLabel.font = [UIFont fontWithName:@"fontello" size:24];
        self.addLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.font = [UIFont boldSystemFontOfSize:14];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.phoneLabel = [[UILabel alloc] init];
        self.phoneLabel.textAlignment = NSTextAlignmentLeft;
        self.phoneLabel.font = [UIFont boldSystemFontOfSize:12];
        self.phoneLabel.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.addLabel];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.phoneLabel];
        
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat midHeight = contentRect.size.height/2;
    CGFloat boundsX = contentRect.origin.x;
    self.nameLabel.frame = CGRectMake(boundsX+10 ,midHeight - 20,contentRect.size.width - (boundsX + 40), 25);
    self.phoneLabel.frame = CGRectMake(boundsX+10,midHeight -2,contentRect.size.width - (boundsX + 40), 25);
    self.addLabel.frame = CGRectMake(contentRect.size.width - (boundsX + 30), 10, 25, 25);
}


@end
