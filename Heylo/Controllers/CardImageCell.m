//
//  TapImageCell.m
//  TapToMe
//
//  Created by Scott Parris on 2/10/15.
//  Copyright (c) 2015 TapIn. All rights reserved.
//

#import <QuartzCore/CALayer.h>
#import "CardImageCell.h"
#define kBorderWidth 4.0

@interface CardImageCell ()




@end

@implementation CardImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIScreen *screen = [UIScreen mainScreen];
     //   self.frame = CGRectMake(0, 0, screen.bounds.size.width, screen.bounds.size.width);
        CGFloat imageSide = screen.bounds.size.width * 0.7;
        CGFloat margin = screen.bounds.size.width * 0.15;
        self.cardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(margin, margin/2.0, imageSide, imageSide)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.cardImageView.image = [UIImage imageNamed:@"test_card.png"];
        
        CALayer *borderLayer = [CALayer layer];
        CGRect borderFrame = CGRectMake(0, 0, self.cardImageView.frame.size.width, self.cardImageView.frame.size.height);
        [borderLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
        [borderLayer setFrame:borderFrame];
        [borderLayer setBorderWidth:kBorderWidth];
        [borderLayer setBorderColor:[[UIColor whiteColor] CGColor]];
        [self.cardImageView.layer addSublayer:borderLayer];
        
        
        self.cardImageView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.cardImageView.layer.shadowOffset = CGSizeMake(0, 2);
        self.cardImageView.layer.shadowOpacity = .4;
        self.cardImageView.clipsToBounds = NO;
        
        self.favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.favoriteButton.frame = CGRectMake(margin, borderFrame.size.height +30, imageSide, 30);
        self.favoriteButton.backgroundColor = [UIColor whiteColor];
        self.favoriteButton.titleLabel.font = [UIFont fontWithName:@"fontello" size:16];
        self.favoriteButton.titleLabel.textAlignment = NSTextAlignmentRight;
        [self.favoriteButton setTitle:@"\uE821" forState:UIControlStateNormal]; //   EA04
        [self.favoriteButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
        [self.favoriteButton setTitle:@"\uE821" forState:UIControlStateHighlighted]; //   EA04
        [self.favoriteButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        
        [self.favoriteButton setTitle:@"\uE821" forState:UIControlStateSelected]; //   EA04
        [self.favoriteButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];


        CGSize size = self.favoriteButton.bounds.size;
        CGFloat curlFactor = 12.0f;
        CGFloat shadowDepth = imageSide + 18.0f;
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0.0f, 0.0f)];
        [path addLineToPoint:CGPointMake(size.width, 0.0f)];
        [path addLineToPoint:CGPointMake(size.width, size.height + shadowDepth)];
        [path addCurveToPoint:CGPointMake(0.0f, size.height + shadowDepth)
                controlPoint1:CGPointMake(size.width - curlFactor, size.height + shadowDepth - curlFactor)
                controlPoint2:CGPointMake(curlFactor, size.height + shadowDepth - curlFactor)];

        self.cardImageView.layer.shadowPath = path.CGPath;
        
        [self.contentView addSubview:self.cardImageView];
        [self.contentView addSubview:self.favoriteButton];
        self.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
        
    }
    return self;
}


- (void) layoutSubviews {
    [super layoutSubviews];
/**    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = (contentRect.origin.x + 10.0);
    CGFloat height = ((0.667 * contentRect.size.width) - 20.0);
    CGRect frame = CGRectMake(boundsX, 10, contentRect.size.width - 20.0, height);
*/
}


@end
