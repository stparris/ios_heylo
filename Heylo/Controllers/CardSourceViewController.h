//
//  CardSourceViewController.h
//  Heylo
//
//  Created by Scott Parris on 6/11/15.
//  Copyright (c) 2015 Heylo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardSourceViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSString *sourceURL;


@end
