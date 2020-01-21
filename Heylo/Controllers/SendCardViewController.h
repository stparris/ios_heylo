//
//  SendCardViewController.h
//  notify
//
//  Created by Scott Parris on 4/26/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendCardViewController : UIViewController <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIImage *cardImage;
@property (nonatomic, strong) NSString *cardURL;

@end
