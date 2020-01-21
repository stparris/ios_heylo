//
//  CardCategoryViewController.m
//  heylo
//
//  Created by Scott Parris on 2/26/15.
//  Copyright (c) 2015 TapIn. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "CardCategoryViewController.h"
#import "CardCategoryCell.h"
#import "CardCategory.h"
#import "AppDelegate.h"

@interface CardCategoryViewController () {
    NSArray *categories;
    AppDelegate *appDelegate;
    UIView *topView;
    UIColor *heyloRed;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *inboxButton;
@property (nonatomic, strong) UIButton *settingsButton;

- (void)actionInbox:(id)sender;
- (void)actionAccount:(id)sender;
- (void)updateInboxCount:(id)sender;

@end


@implementation CardCategoryViewController

static NSString *kCellID = @"cellID";

- (void)loadView
{
    [super loadView];
    heyloRed = [[UIColor alloc] initWithRed:210.0/255 green:78.0/255 blue:59.0/255 alpha:1.0];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIScreen *screen = [UIScreen mainScreen];
    topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen.bounds.size.width, 60)];
    topView.backgroundColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    [self.view addSubview:topView];
    UIView *categoriesView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, screen.bounds.size.width, 22)];
    categoriesView.backgroundColor = [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0];
    UILabel *categoriesLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 2, screen.bounds.size.width, 18)];
    categoriesLabel.text = @"CATEGORIES";
    categoriesLabel.textColor = [UIColor lightGrayColor];
    //categoriesView.backgroundColor = [UIColor colorWithRed:102/255 green:102/255 blue:102/255 alpha:1.0];
    [categoriesView addSubview:categoriesLabel];
    [self.view addSubview:categoriesView];
    
    UITableView *tblView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 82.0, screen.bounds.size.width, screen.bounds.size.height - 82)
                                                        style:UITableViewStylePlain
                            ];
    tblView.autoresizingMask =
    UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight
    ;
    
    tblView.dataSource = self;
    tblView.delegate = self;
    tblView.backgroundColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    self.tableView = tblView;
    [self.view addSubview:self.tableView];

}

- (void)viewWillAppear:(BOOL)animated
{
    if ([appDelegate.selectedView isEqualToString:@"inbox"]) {
        UILabel *cogLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 25, 30, 30)];
        cogLabel.textAlignment = NSTextAlignmentCenter;
        cogLabel.font = [UIFont fontWithName:@"fontello" size:18];
        cogLabel.text = @"\uEA02";
        cogLabel.textColor = [UIColor whiteColor];
        
        UILabel *settingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(78, 27, 100, 30)];
        settingsLabel.textAlignment = NSTextAlignmentLeft;
        settingsLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:20];
        settingsLabel.text = @"Settings";
        settingsLabel.textColor = [UIColor whiteColor];
        
        self.settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 130, 60)];
        [self.settingsButton addTarget:self action:@selector(actionAccount:) forControlEvents:UIControlEventTouchUpInside];
        [self.settingsButton addSubview:cogLabel];
        [self.settingsButton addSubview:settingsLabel];
        [topView addSubview:self.settingsButton];
    } else {
        UILabel *folderLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 25, 30, 30)];
        folderLabel.textAlignment = NSTextAlignmentCenter;
        folderLabel.font = [UIFont fontWithName:@"fontello" size:18];
        folderLabel.text = @"\uEA14"; // EA10 EA0D
        folderLabel.textColor = [UIColor whiteColor];
        
        UILabel *inboxLabel = [[UILabel alloc] initWithFrame:CGRectMake(78, 27, 100, 30)];
        inboxLabel.textAlignment = NSTextAlignmentLeft;
        inboxLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:20];
        inboxLabel.text = @"Messages";
        inboxLabel.textColor = [UIColor whiteColor];
        
        self.inboxCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(168,  30, 24, 24)];
        self.inboxCountLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:14];
        self.inboxCountLabel.textAlignment = NSTextAlignmentCenter;
        self.inboxCountLabel.textColor = [UIColor whiteColor];
        if ([appDelegate.inboxCount intValue] > 0) {
            self.inboxCountLabel.text = [NSString stringWithFormat:@"%@",appDelegate.inboxCount];
            self.inboxCountLabel.hidden = NO;
        } else {
            self.inboxCountLabel.text = @"";
            self.inboxCountLabel.hidden = YES;
        }
        self.inboxCountLabel.backgroundColor = [UIColor colorWithRed:39.0/255 green:170.0/255 blue:255.0/255 alpha:1.0];
        CALayer *countLayer = self.inboxCountLabel.layer;
        // [imageLayer setBorderWidth:1.0];
        [countLayer setCornerRadius:12.0];
        [countLayer setMasksToBounds:YES];
        [topView addSubview:self.inboxCountLabel];
        
        self.inboxButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 130, 60)];
        self.inboxButton.backgroundColor = [UIColor clearColor];
        [self.inboxButton addTarget:self action:@selector(actionInbox:) forControlEvents:UIControlEventTouchUpInside];
        [self.inboxButton addSubview:folderLabel];
        [self.inboxButton addSubview:inboxLabel];
        [topView addSubview:self.inboxButton];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInboxCount:) name:@"categoryInboxCount" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable:) name:@"reloadCategories" object:nil];

    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)updateInboxCount:(id)sender
{
    self.inboxCountLabel.text = [NSString stringWithFormat:@"%@", appDelegate.inboxCount];
    self.inboxCountLabel.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"categoryInboxCount" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadCategories" object:nil];
}

- (void)actionInbox:(id)sender
{
/**    CATransition *transition = [CATransition animation];
    transition.duration = 0;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
*/
    appDelegate.selectedView = @"inbox";
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)actionAccount:(id)sender
{
    // NSLog(@"=============== settings touched");
    CATransition *transition = [CATransition animation];
    transition.duration = 0;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    appDelegate.selectedView = @"account";
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return appDelegate.categories.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CardCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if (cell == nil) {
        cell = [[CardCategoryCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellID];
    }
    CardCategory *cat = [appDelegate.categories objectAtIndex:indexPath.row];
    cell.nameLabel.text = cat.name;
    if ([cat.name isEqualToString:@"HOME"]) {
        cell.categoryIcon.text = @"";// home icon@"\uEA03";
        cell.nameLabel.text = @"ALL";
    } else if ([cat.name isEqualToString:@"MY FAVORITES"]) {
        cell.categoryIcon.text = @"\uE8A8"; //solid @"\uE821" outline @"\uE8A8"
        
        //cell.categoryIcon.textColor = heyloRed;
        //[UIColor colorWithRed:251.0/255 green:236.0/255 blue:233.0/255 alpha:1.0];
        //cell.categoryIcon.textColor = [UIColor colorWithRed:240.0/255 green:102.0/255 blue:102.0/255 alpha:1.0];
       // cell.nameLabel.textColor = [UIColor colorWithRed:235.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
    } else {
        cell.categoryIcon.text = @"";
    }
    // E820 heart
    if ([appDelegate.selectedCategory.name isEqualToString:cat.name]) {
        cell.selectedIndicator.backgroundColor = heyloRed;
    } else {
        cell.selectedIndicator.backgroundColor = [UIColor clearColor];
    }
   // [cell setSeparatorInset:UIEdgeInsetsZero];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    appDelegate.selectedView = @"home";
    appDelegate.selectedImage = nil;
    NSLog(@"Debug crash at category select");
    appDelegate.selectedCategory = [appDelegate.categories objectAtIndex:indexPath.row];
    CATransition *transition = [CATransition animation];
    transition.duration = 0;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)reloadTable:(NSNotification *)notification
{
    [self.tableView reloadData];
}

@end
