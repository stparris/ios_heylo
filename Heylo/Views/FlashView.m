 //
//  FlashView.m
//  Heylo
//
//  Created by Scott Parris on 6/5/15.
//  Copyright (c) 2015 Heylo. All rights reserved.
//

#import "FlashView.h"

@implementation FlashView

- (id)initWithScreenWidth:(CGFloat)width
{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, width, 60);
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
        self.icon = [[UILabel alloc] initWithFrame:CGRectMake(20, 11, 40, 40)];
        self.icon.textColor = [UIColor colorWithRed:210.0/255 green:78.0/255 blue:59.0/255 alpha:1.0];
        self.icon.textAlignment = NSTextAlignmentCenter;
        self.icon.font = [UIFont fontWithName:@"fontello" size:18];
        self.icon.text = @"\uE904";
        self.message = [[UILabel alloc] initWithFrame:CGRectMake(70, 13, width - 70, 40)];
        self.message.textColor = [UIColor whiteColor];
        self.message.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:14];
        [self addSubview:self.icon];
        [self addSubview:self.message];
        self.hidden = YES;
        // alert1.wav tap.aif
        NSString *path = [NSString stringWithFormat:@"%@/whistle.mp3", [[NSBundle mainBundle] resourcePath]];
        NSURL *soundUrl = [NSURL fileURLWithPath:path];
        
        // Create audio player object and initialize with URL to sound
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
        
    }
    return self;
}

- (void)showMessage:(NSString *)message
{
    [_audioPlayer play];
    self.message.text = message;
    self.hidden = NO;
    [self setAlpha:0.8f];
    [UIView animateWithDuration:2.0f animations:^{
        [self setAlpha:1.0f];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:4.0f animations:^{
            self.hidden = YES;
        } completion:nil];
    }];
}

@end
