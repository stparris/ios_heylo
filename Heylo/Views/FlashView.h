//
//  FlashView.h
//  Heylo
//
//  Created by Scott Parris on 6/5/15.
//  Copyright (c) 2015 Heylo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface FlashView : UIView {
    AVAudioPlayer *_audioPlayer;
}

@property (nonatomic, strong) UILabel *icon;
@property (nonatomic, strong) UILabel *message;

- (id)initWithScreenWidth:(CGFloat)width;
- (void)showMessage:(NSString *)message;

@end
