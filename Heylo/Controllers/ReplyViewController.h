//
//  ReplyViewController.h
//  Heylo
//
//  Created by Scott Parris on 6/15/15.
//  Copyright (c) 2015 Heylo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Conversation;

@interface ReplyViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) Conversation *conversation;

@end
