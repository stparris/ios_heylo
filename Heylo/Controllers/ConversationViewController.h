//
//  ChatViewController.h
//  notify
//
//  Created by Scott Parris on 3/30/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;
@class Conversation;

@interface ConversationViewController : UIViewController <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    AppDelegate *appDelegate;
    NSMutableArray *messages;
}

@property (nonatomic,strong) Conversation *conversation;
@property (nonatomic, strong) UIButton *accountButton;
@property (nonatomic, strong) UITableView *tableView;
- (void)showAccount:(id)sender;

@end
