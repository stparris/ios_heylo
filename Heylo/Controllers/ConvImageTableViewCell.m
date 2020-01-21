//
//  ConvImageTableViewCell.m
//  notify
//
//  Created by Scott Parris on 4/27/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import "ConvImageTableViewCell.h"

@implementation ConvImageTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.cardPlace = [[UIView alloc] init];
        self.cardPlace.translatesAutoresizingMaskIntoConstraints = NO;
        self.cardPlace.backgroundColor = [UIColor whiteColor];
        self.cardPlace.layer.borderWidth = 1.0f;
        self.cardPlace.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.cardImage = [[UIImageView alloc] init];
        self.cardImage.translatesAutoresizingMaskIntoConstraints = NO;
        [self.cardPlace addSubview:self.cardImage];
        [self.contentView addSubview:self.cardPlace];
        
        
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[place]-20-|" options:0 metrics:nil views:@{ @"place": self.cardPlace }]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[place]-10-|" options:0 metrics:nil views:@{ @"place": self.cardPlace }]];
        
        NSNumber *side = [NSNumber numberWithFloat:self.contentView.bounds.size.width - 46];
        NSDictionary *metrics = @{@"width": side,@"height":side};
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[image(width)]-3-|" options:0 metrics:metrics views:@{ @"image": self.cardImage }]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[image(height)]-3-|" options:0 metrics:metrics views:@{ @"image": self.cardImage }]];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
}


@end
