//
//  PopupView.m
//  Heylo
//
//  Created by Scott Parris on 6/27/15.
//  Copyright (c) 2015 Heylo. All rights reserved.
//

#import "PopupView.h"
#import "User.h"
#import "HeyloData.h"

@implementation PopupView

- (id)init
{
    screen = [UIScreen mainScreen];
    if (self = [super init]) {
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.frame = CGRectMake(0, 0, screen.bounds.size.width, screen.bounds.size.height);
        backgroundView = [[UIView alloc] init];
        backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        backgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        
        popupView = [[UIView alloc] init];
        popupView.translatesAutoresizingMaskIntoConstraints = NO;
        popupView.backgroundColor = [UIColor whiteColor];
        popupView.layer.cornerRadius = 10.0;
        
        titleView = [[UIView alloc] init];
        titleView.translatesAutoresizingMaskIntoConstraints = NO;

        self.hideButton = [[UIButton alloc] init];
        self.hideButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.hideButton setBackgroundColor:[UIColor clearColor]];
        self.hideButton.tag = 1;
        self.hideButton.titleLabel.font = [UIFont fontWithName:@"fontello" size:14];
        [self.hideButton setTitle:@"\uEA08" forState:UIControlStateNormal];
        [self.hideButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.hideButton addTarget:self action:@selector(hidePopup:) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:self.hideButton];

        self.title = [[UILabel alloc] init];
        self.title.translatesAutoresizingMaskIntoConstraints = NO;
        self.title.textAlignment = NSTextAlignmentCenter;
        self.title.font = [UIFont fontWithName:@"fontello" size:20];
        self.title.textColor = [UIColor darkGrayColor];
        [titleView addSubview:self.title];
        
        topBorder = [[UIView alloc] init];
        topBorder.translatesAutoresizingMaskIntoConstraints = NO;
        topBorder.backgroundColor = [UIColor lightGrayColor];
        
        messageView = [[UIView alloc] init];
        messageView.translatesAutoresizingMaskIntoConstraints = NO;

        self.message = [[UILabel alloc] init];
        self.message.translatesAutoresizingMaskIntoConstraints = NO;
        self.message.textColor = [UIColor darkGrayColor];
        self.message.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:18];
        self.message.lineBreakMode = NSLineBreakByWordWrapping;
        self.message.numberOfLines = 0;
        [self.message sizeToFit];
        self.message.textAlignment = NSTextAlignmentCenter;
        [messageView addSubview:self.message];
        
        self.icon = [[UILabel alloc] init];
        self.icon.translatesAutoresizingMaskIntoConstraints = NO;
        self.icon.textColor = [UIColor darkGrayColor];
        self.icon.font = [UIFont fontWithName:@"fontello" size:24];
        self.icon.textAlignment = NSTextAlignmentCenter;
        [messageView addSubview:self.icon];
        
        self.gotIt = [[UIButton alloc] init];
        self.gotIt.translatesAutoresizingMaskIntoConstraints = NO;
        [self.gotIt setTitle:@"GOT IT" forState:UIControlStateNormal];
        [self.gotIt setBackgroundColor:[UIColor clearColor]];
        self.gotIt.tag = 1;
        self.gotIt.titleLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:20];
        [self.gotIt setTitleColor:[UIColor colorWithRed:39.0/255 green:170.0/255 blue:255.0/255 alpha:1.0] forState:UIControlStateNormal];
        [self.gotIt addTarget:self action:@selector(hidePopup:) forControlEvents:UIControlEventTouchUpInside];
        [messageView addSubview:self.gotIt];
        
        [popupView addSubview:titleView];
        [popupView addSubview:topBorder];
        [popupView addSubview:messageView];
        [backgroundView addSubview:popupView];
        [self addSubview:backgroundView];
        self.hidden = YES;
   
    }
    return self;
}



- (void)showPopup:(NSString *)title message:(NSString *)message icon:(NSString *)icon
{
    CGFloat popupWidth = screen.bounds.size.width - 80;
    CGFloat pHeight = 250;
    NSDictionary *metrics = @{
                              @"titleWidth":[NSNumber numberWithFloat:popupWidth - 24],
                              @"height":[NSNumber numberWithFloat:screen.bounds.size.height + 60],
                              @"pHeight":[NSNumber numberWithFloat:pHeight]
                              };
    
    self.title.text = title;
    self.message.text = message;
    if (icon.length > 0) {
        self.icon.text = icon;
    }
    NSDictionary *viewsDictionary = @{@"gotIt":self.gotIt,
                                      @"message":self.message,
                                      @"icon":self.icon,
                                      @"title":self.title,
                                      @"hideButton":self.hideButton,
                                      @"titleView":titleView,
                                      @"topBorder":topBorder,
                                      @"messageView":messageView,
                                      @"popupView":popupView,
                                      @"backgroundView":backgroundView
                                      };
    [self.hideButton addConstraint:[NSLayoutConstraint constraintWithItem:self.hideButton
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0
                                                          constant:18.0]];
    [self.hideButton addConstraint:[NSLayoutConstraint constraintWithItem:self.hideButton
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0
                                                            constant:18.0]];
    
    NSArray *titleH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[hideButton]-5-[title]-|"
                                                              options:0
                                                              metrics:metrics
                                                                views:viewsDictionary];
    
    [titleView addConstraints:titleH];
    
    NSArray *hideV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[hideButton]-|"
                                                             options:0
                                                             metrics:nil
                                                               views:viewsDictionary];
    
    [titleView addConstraints:hideV];
    
    NSArray *titleTextV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[title]-|"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:viewsDictionary];
    
    [titleView addConstraints:titleTextV];
 
    NSArray *titleViewH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[titleView]-|"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:viewsDictionary];
    
    [popupView addConstraints:titleViewH];
    
    
    NSArray *messageH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[message]-20-|"
                                                                options:0
                                                                metrics:nil
                                                                  views:viewsDictionary];
    
    [messageView addConstraints:messageH];
    
    NSArray *iconH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[icon]|"
                                                              options:0
                                                              metrics:nil
                                                                views:viewsDictionary];
    
    [messageView addConstraints:iconH];
    
    NSArray *gotItH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[gotIt]|"
                                                              options:0
                                                              metrics:nil
                                                                views:viewsDictionary];
    
    [messageView addConstraints:gotItH];
    
    NSArray *messageV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[message]-10-[icon(18)]-20-[gotIt(32)]-10-|"
                                                                options:0
                                                                metrics:nil
                                                                  views:viewsDictionary];
    
    [messageView addConstraints:messageV];

    
    NSArray *messageViewH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[messageView]|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewsDictionary];
    
    [popupView addConstraints:messageViewH];
    
    [topBorder addConstraint:[NSLayoutConstraint
                              constraintWithItem:topBorder
                              attribute:NSLayoutAttributeHeight
                              relatedBy:NSLayoutRelationEqual
                              toItem:nil
                              attribute:NSLayoutAttributeNotAnAttribute
                              multiplier:1.0
                              constant:1.0]];
    NSArray *topBorderH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topBorder]|"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:viewsDictionary];
    
    [popupView addConstraints:topBorderH];
    
    NSArray *contentV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleView][topBorder][messageView]|"
                                                                options:0
                                                                metrics:nil
                                                                  views:viewsDictionary];
    
    [popupView addConstraints:contentV];
    
    
    

    NSArray *mainV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundView]|"
                                                             options:0
                                                             metrics:metrics
                                                               views:viewsDictionary];
    [self addConstraints:mainV];
    
    NSArray *mainH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundView]|"
                                                             options:0
                                                             metrics:metrics
                                                               views:viewsDictionary];
    [self addConstraints:mainH];

    
    NSArray *popupH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[popupView]-40-|"
                                                              options:0
                                                              metrics:metrics
                                                                views:viewsDictionary];
    [backgroundView addConstraints:popupH];
    NSArray *popupV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-100-[popupView(pHeight)]"
                                                              options:0
                                                              metrics:metrics
                                                                views:viewsDictionary];
    [backgroundView addConstraints:popupV];
    
    
    
    
    self.hidden = NO;
}

- (void)hidePopup:(id)sender
{
    UIButton *button = sender;
    if (button.tag == 1) {
        if ([appDelegate.user.status isEqualToString:@"beginer"]) {
            appDelegate.user.status = @"novice";
        } else if ([appDelegate.user.status isEqualToString:@"peewee"]) {
            appDelegate.user.status = @"intermediate";
        }
        [HeyloData updateUser:appDelegate.user];
    }
    if (button.tag == 2) {
        if ([appDelegate.user.status isEqualToString:@"novice"]) {
            appDelegate.user.status = @"racer";
        } else if ([appDelegate.user.status isEqualToString:@"intermediate"]) {
            appDelegate.user.status = @"expert";
        }
        [HeyloData updateUser:appDelegate.user];
    }
    if (button.tag == 3) {
        if ([appDelegate.user.status isEqualToString:@"beginer"]) {
            appDelegate.user.status = @"peewee";
        } else if ([appDelegate.user.status isEqualToString:@"novice"]) {
            appDelegate.user.status = @"intermediate";
        } else if ([appDelegate.user.status isEqualToString:@"racer"]) {
            appDelegate.user.status = @"expert";
        }
        [HeyloData updateUser:appDelegate.user];
    }
    self.hidden = YES;
}

@end
