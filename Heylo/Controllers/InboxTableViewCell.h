//
//  InboxTableViewCell.h
//  notify
//
//  Created by Scott Parris on 4/27/15.
//  Copyright (c) 2015 Peter Loh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InboxTableViewCell : UITableViewCell

@property (nonatomic, strong) UIView *imagePlace;
@property (nonatomic, strong) UIImageView *thumbnail;
@property (nonatomic, strong) UIView *unreadFlag;
@property (nonatomic, strong) UILabel *contactsLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *messageText;
@property (nonatomic, strong) UILabel *messageIcon;
@property (nonatomic, strong) UILabel *messageCount;

@end
