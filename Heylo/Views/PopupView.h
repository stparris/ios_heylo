//
//  PopupView.h
//  Heylo
//
//  Created by Scott Parris on 6/27/15.
//  Copyright (c) 2015 Heylo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface PopupView : UIView {
    UIView *backgroundView;
    UIView *popupView;
    UIView *titleView;
    UIView *messageView;
    UIView *topBorder;
    UIScreen *screen;
    AppDelegate *appDelegate;
}

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *message;
@property (nonatomic, strong) UILabel *icon;
@property (nonatomic, strong) UIButton *hideButton;
@property (nonatomic, strong) UIButton *gotIt;

- (id)init;
- (void)showPopup:(NSString *)title message:(NSString *)message icon:(NSString *)icon;
- (void)hidePopup:(id)sender;

@end
