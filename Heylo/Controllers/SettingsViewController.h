//
//  MyViewController.h
//  notify
//
//  Created by Scott Parris on 4/23/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsViewControllerDelegate <NSObject>

@optional
- (void)movePanelRight;

@required
- (void)movePanelToOriginalPosition;

@end

@interface SettingsViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, assign) id<SettingsViewControllerDelegate> delegate;
@property (nonatomic, strong) UIButton *categoriesButton;

@end
