//
//  HeaderGradientView.m
//  heylo
//
//  Created by Scott Parris on 2/27/15.
//  Copyright (c) 2015 TapIn. All rights reserved.
//

#import "HeaderGradientView.h"

@implementation HeaderGradientView

+ (Class)layerClass
{
    return [CAGradientLayer class];
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self initGradientLayer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self initGradientLayer];
    }
    return self;
}

// Make custom configuration of your gradient here
- (void)initGradientLayer {
    CAGradientLayer *gLayer = (CAGradientLayer *)self.layer;
    UIColor *topColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    UIColor *bottomColor = [UIColor clearColor];
    gLayer.colors = [NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil];
}


@end
