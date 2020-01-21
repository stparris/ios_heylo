//
//  RootViewController.h
//  notify
//
//  Created by Scott Parris on 3/30/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface RootViewController : UIViewController <UINavigationControllerDelegate> {
    AppDelegate *appDelegate;
}

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

