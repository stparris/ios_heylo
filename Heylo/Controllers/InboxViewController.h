//
//  TableViewController.h
//  notify
//
//  Created by Scott Parris on 4/3/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;

@protocol InboxViewControllerDelegate <NSObject>

@optional
- (void)movePanelRight;

@required
- (void)movePanelToOriginalPosition;

@end


@interface InboxViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    AppDelegate *appDelegate;
    NSArray *conversations;
}
@property (nonatomic, assign) id<InboxViewControllerDelegate> delegate;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *categoriesButton;

@end
