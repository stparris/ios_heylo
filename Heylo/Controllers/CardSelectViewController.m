//
//  CardSelectViewController.m
//  heylo
//
//  Created by Scott Parris on 3/1/15.
//  Copyright (c) 2015 TapIn. All rights reserved.
//

#import "CardSelectViewController.h"
#import "HeaderGradientView.h"
#import "CardImageCell.h"
#import "CardImage.h"
#import "CardCategory.h"
#import "AppDelegate.h"
#import "CardCustomizeViewController.h"
#import "ImageCache.h"

#define kCustomRowCount 4

@import QuartzCore;

static NSString *CellIdentifier = @"TapTableCell";
static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";


@interface CardSelectViewController () {
    NSArray *cards;
    UIColor *redColor;
    NSString *selectedFilter;
    int inboxCount;
}

@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *selectedLabel;
@property (nonatomic, strong) UILabel *selectedCountLabel;
@property (nonatomic) UIEdgeInsets titleEdgeInsets;

- (void)showCategories:(id)sender;
- (void)setFavorite:(id)sender;
- (void)updateInboxCount:(id)sender;

@end



@implementation CardSelectViewController

- (void)loadView {
    [super loadView];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    redColor= [[UIColor alloc] initWithRed:210.0/255 green:78.0/255 blue:59.0/255 alpha:1.0];
    UIScreen *screen = [UIScreen mainScreen];
    UIView *controlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen.bounds.size.width, 64)];
    controlView.backgroundColor = redColor;

    UILabel *hashLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 30, 30)];
    hashLabel.font = [UIFont fontWithName:@"fontello" size:24];
    hashLabel.text = @" \uEA00";
    hashLabel.textColor = [UIColor whiteColor];
    [controlView addSubview:hashLabel];
    
    self.inboxCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(27, 25, 16, 16)];
    self.inboxCountLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:10];
    self.inboxCountLabel.textAlignment = NSTextAlignmentCenter;
    self.inboxCountLabel.textColor = [UIColor whiteColor];
    self.inboxCountLabel.text = @"";
    self.inboxCountLabel.hidden = YES;
    CALayer *countLayer = self.inboxCountLabel.layer;
    // [imageLayer setBorderWidth:1.0];
    [countLayer setCornerRadius:8.0];
    [countLayer setMasksToBounds:YES];
    
    self.inboxCountLabel.backgroundColor = [UIColor colorWithRed:39.0/255 green:170.0/255 blue:255.0/255 alpha:1.0];
    [controlView addSubview:self.inboxCountLabel];
    
    self.categoriesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.categoriesButton.frame = CGRectMake(0,0, 64, 64);
    UIEdgeInsets insets = { .left = 10, .right = 30, .top = 30, .bottom = 10 };
    self.categoriesButton.titleEdgeInsets = insets;
    self.categoriesButton.tag = 1;
    [self.categoriesButton addTarget:self action:@selector(showCategories:) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:self.categoriesButton];
    
    UIEdgeInsets navInsets = { .left = 0, .right = 0, .top = 30, .bottom = 10 };
    CGFloat navButtonWidth = (screen.bounds.size.width -128)/2;
    self.popularButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.popularButton.frame = CGRectMake(64, 0, navButtonWidth, 64);
    self.popularButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.popularButton.titleEdgeInsets = navInsets;
    [self.popularButton setTitle:@"Popular" forState:UIControlStateNormal];
    self.popularButton.titleLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:18]; //AppleSDGothicNeo-Medium
    self.popularButton.tag = 2;
    [self.popularButton addTarget:self action:@selector(showFiltered:) forControlEvents:UIControlEventTouchUpInside];
    CGSize size = [self getStringSize:@"Popular"];
    self.popularSelected = [[UIView alloc] initWithFrame:CGRectMake((navButtonWidth - size.width)/2, 56, size.width, 2)];
    [self.popularButton addSubview:self.popularSelected];
    [controlView addSubview:self.popularButton];
    
    self.recentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.recentButton.frame = CGRectMake(navButtonWidth + 64, 0, navButtonWidth, 64);
    self.recentButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.recentButton.titleEdgeInsets = navInsets;
    [self.recentButton setTitle:@"Recent" forState:UIControlStateNormal];
    self.recentButton.titleLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:18];
    self.recentButton.tag = 3;
    [self.recentButton addTarget:self action:@selector(showFiltered:) forControlEvents:UIControlEventTouchUpInside];
    size = [self getStringSize:@"Recent"];
    self.recentSelected = [[UIView alloc] initWithFrame:CGRectMake((navButtonWidth - size.width)/2, 56, size.width, 2)];
    [self.recentButton addSubview:self.recentSelected];
    [controlView addSubview:self.recentButton];
    
/**    self.allButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.allButton.frame = CGRectMake((navButtonWidth * 2) + 64, 0, navButtonWidth, 64);
    self.allButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.allButton.titleEdgeInsets = navInsets;
    [self.allButton setTitle:@"More" forState:UIControlStateNormal];
    self.allButton.titleLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:18];
    self.allButton.tag = 4;
    [self.allButton addTarget:self action:@selector(showFiltered:) forControlEvents:UIControlEventTouchUpInside];
    size = [self getStringSize:@"More"];
    self.allSelected = [[UIView alloc] initWithFrame:CGRectMake((navButtonWidth - size.width)/2, 56, size.width, 2)];
    [self.allButton addSubview:self.allSelected];
    [controlView addSubview:self.allButton];
*/
    
    
    self.accountButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.accountButton.frame = CGRectMake(screen.bounds.size.width - 64, 0, 64, 64);
    UIEdgeInsets acctinsets = { .left = 30, .right = 10, .top = 30, .bottom = 10 };
    self.accountButton.titleEdgeInsets = acctinsets;
    self.accountButton.titleLabel.font = [UIFont fontWithName:@"fontello" size:20];
    self.accountButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.accountButton setTitle:@" \uEA02" forState:UIControlStateNormal];
    [self.accountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.accountButton.tag = 5;
    [self.accountButton addTarget:self action:@selector(showAccount:) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:self.accountButton];

    
    [self.view addSubview:controlView];
    
    UITableView *tblView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 102.0, screen.bounds.size.width, screen.bounds.size.height - 102)
                            style:UITableViewStylePlain
    ];
    tblView.autoresizingMask =
        UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight
    ;
    
    tblView.dataSource = self;
    tblView.delegate = self;
    tblView.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
    tblView.rowHeight = screen.bounds.size.width *0.95;
    tblView.decelerationRate = UIScrollViewDecelerationRateNormal;
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    [tblView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView = tblView;
    [self.view addSubview:self.tableView];
    selectedFilter = @"Recent";

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInboxCount:) name:@"homeInboxCount" object:nil];

}

- (void)updateInboxCount:(id)sender
{
    self.inboxCountLabel.text = [NSString stringWithFormat:@"%@", appDelegate.inboxCount];
    self.inboxCountLabel.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"homeInboxCount" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    [self.tableView registerClass:[CardImageCell class] forCellReuseIdentifier:CellIdentifier];
    [self.tableView registerClass:[CardImageCell class] forCellReuseIdentifier:PlaceholderCellIdentifier];
   
}
 
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


- (void)viewWillAppear:(BOOL)animated
{
    [self preferredStatusBarStyle];
    self.recentSelected.backgroundColor = [UIColor whiteColor];
    self.allSelected.backgroundColor = redColor;
    self.popularSelected.backgroundColor = redColor;
    UIScreen *screen = [UIScreen mainScreen];
    UIView *selectedCategoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, screen.bounds.size.width, 42)];
    selectedCategoryView.backgroundColor = [UIColor colorWithRed:128.0/255 green:128.0/255 blue:128.0/255 alpha:1.0];
    
    self.selectedLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 4.0, screen.bounds.size.width - 40, 28)];
    if ([appDelegate.selectedCategory.name isEqualToString:@"HOME"]) {
        self.selectedLabel.text = @"ALL";
    } else {
        self.selectedLabel.text = appDelegate.selectedCategory.name;
    }
    self.selectedLabel.font = [UIFont fontWithName:@"DIN Condensed" size:20]; // DIN Condensed AvenirNextCondensed-Regular HelveticaNeue-Light
    self.selectedLabel.textColor = [UIColor whiteColor];
    [selectedCategoryView addSubview:self.selectedLabel];
    self.selectedCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 28.0, screen.bounds.size.width - 40, 10)];
    self.selectedCountLabel.text = [NSString stringWithFormat:@"%lu ITEMS", (unsigned long)appDelegate.selectedCategory.images.count];
    self.selectedCountLabel.font = [UIFont fontWithName:@"DIN Condensed" size:10]; //AppleSDGothicNeo-Medium
    self.selectedCountLabel.textColor = [UIColor whiteColor];
    [selectedCategoryView addSubview:self.selectedCountLabel];
    HeaderGradientView *dropShadow = [[HeaderGradientView alloc] initWithFrame:CGRectMake(0, 0, screen.bounds.size.width, 14.0)];
    [selectedCategoryView addSubview:dropShadow];
    
    [self.view addSubview:selectedCategoryView];
    if (appDelegate.selectedImage) {
        [self.tableView selectRowAtIndexPath:appDelegate.selectedImage.indexPath
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionMiddle];
        [self.tableView deselectRowAtIndexPath:appDelegate.selectedImage.indexPath animated:NO];
    }
    if ([appDelegate.inboxCount intValue] > 0) {
        self.inboxCountLabel.text = [NSString stringWithFormat:@"%@",appDelegate.inboxCount];
        self.inboxCountLabel.hidden = NO;
    } else {
        self.inboxCountLabel.text = @"";
        self.inboxCountLabel.hidden = YES;
    }
}

- (void)showFiltered:(id)sender
{
    UIButton *button = sender;
    
    // NSLog(@"Filter selected %li", (long)button.tag);
    switch (button.tag) {
        case 2: {
            selectedFilter = @"Popular";
            break;
        }
        case 3: {
            selectedFilter = @"Recent";
            break;
        }
        case 4: {
            selectedFilter = @"More";
            break;
        }
            
        default:
            break;
    }
    NSArray *unsorted_images = [[NSArray alloc] initWithArray:appDelegate.selectedCategory.images];
/**    for (CardImage *img in unsorted_images) {
        NSLog(@"name %@ date %@ fav %@", img.name, img.date, img.favorites);
    }
*/
    if ([selectedFilter isEqualToString:@"Recent"]) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        appDelegate.selectedCategory.images = [unsorted_images sortedArrayUsingDescriptors:sortDescriptors];
        self.recentSelected.backgroundColor = [UIColor whiteColor];
        self.popularSelected.backgroundColor = redColor;
        self.allSelected.backgroundColor = redColor;
    } else if ([selectedFilter isEqualToString:@"More"]) {
        self.allSelected.backgroundColor = [UIColor whiteColor];
        self.popularSelected.backgroundColor = redColor;
        self.recentSelected.backgroundColor = redColor;
    } else {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"favorites" ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        appDelegate.selectedCategory.images = [unsorted_images sortedArrayUsingDescriptors:sortDescriptors];
        self.popularSelected.backgroundColor = [UIColor whiteColor];
        self.allSelected.backgroundColor = redColor;
        self.recentSelected.backgroundColor = redColor;
    }
    unsorted_images = nil;
    [self.tableView reloadData];
}


- (void)showCategories:(id)sender
{
    UIButton *button = sender;
    switch (button.tag) {
        case 0: {
            [_delegate movePanelToOriginalPosition];
            break;
        }
            
        case 1: {
            [_delegate movePanelRight];
            break;
        }
            
        default:
            break;
    }

}

- (void)showAccount:(id)sender
{
    appDelegate.selectedView = @"account";
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (CGSize)getStringSize:(NSString *)_string
{
    CGSize size = [_string sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:18]}];
    return size;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count = appDelegate.selectedCategory.images.count;
    if (count == 0)
    {
        if ([appDelegate.selectedCategory.name isEqualToString:@"MY FAVORITES"]) 
            return 1;
        else
            return kCustomRowCount;
    }
    NSLog(@"what count %lu", count);
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    CardImageCell *cell = nil;
    NSUInteger nodeCount = appDelegate.selectedCategory.images.count;
    if (nodeCount == 0 && indexPath.row == 0)
    {
        // add a placeholder cell while waiting on table data
        cell = [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier forIndexPath:indexPath];
        cell.detailTextLabel.text = @"Loading…";
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (nodeCount > 0) {
            CardImage *image = (appDelegate.selectedCategory.images)[indexPath.row];
            if (!image.cardImage) {
                if ([appDelegate.imageCache doesExist:image.imageUrl]) {
                    cell.cardImageView.image = [appDelegate.imageCache getImageForURL:image.imageUrl];
                } else {
                    if (self.tableView.dragging == NO && self.tableView.decelerating == NO) {
                        [self startImageDownload:image forIndexPath:indexPath];
                    }
                    // if a download is deferred or in progress, return a placeholder image
                    cell.cardImageView.image = [UIImage imageNamed:@"image_loading.png"];
                }
            } else {
                cell.cardImageView.image = image.cardImage;
                // NSLog(@"id %@ fav %@", image.imageId, image.myFavorite);
            }
            if ([image.myFavorite isEqualToString:@"true"]) {
                [cell.favoriteButton setTitleColor:redColor forState:UIControlStateNormal];
            } else {
                [cell.favoriteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
            [cell.favoriteButton addTarget:self action:@selector(setFavorite:) forControlEvents:UIControlEventTouchUpInside];

        }
    }
    return cell;
}


- (void)startImageDownload:(CardImage *)cardImage forIndexPath:(NSIndexPath *)indexPath
{
    CardImage *downloadImage = (self.imageDownloadsInProgress)[indexPath];
    if (downloadImage == nil) {
        downloadImage = cardImage;
        
        [downloadImage setCompletionHandler:^{
            // NSLog(@"image %@ %@ %@", cardImage.imageId, cardImage.name, cardImage.cardImage);
            CardImageCell *cell = (CardImageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            
            // Display the newly loaded image
            cell.cardImageView.image = cardImage.cardImage;
            cell.favoriteButton.tag = indexPath.row;
            // NSLog(@"dl id %@ fav %@", cardImage.imageId, cardImage.myFavorite);
            if ([cardImage.myFavorite isEqualToString:@"true"]) {
                [cell.favoriteButton setTitleColor:redColor forState:UIControlStateNormal];
            } else {
                [cell.favoriteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
            [cell.favoriteButton addTarget:self action:@selector(setFavorite:) forControlEvents:UIControlEventTouchUpInside];
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
        }];
        (self.imageDownloadsInProgress)[indexPath] = downloadImage;
        [downloadImage getCardImage];
    }
}

- (void)loadImagesForOnscreenRows
{
    if (appDelegate.selectedCategory.images.count > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            CardImage *imageObj = (appDelegate.selectedCategory.images)[indexPath.row];
            if (!imageObj.cardImage) {
                [self startImageDownload:imageObj forIndexPath:indexPath];
                // [imageObj getTapImage];
            }
        }
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}


- (void)terminateAllDownloads
{
    // terminate all pending download connections
    //   NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    //   [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    [self.imageDownloadsInProgress removeAllObjects];
}

- (void)dealloc
{
    // terminate all pending download connections
    [self terminateAllDownloads];
}



- (void)setFavorite:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    CardImage *card = [appDelegate.selectedCategory.images objectAtIndex:indexPath.row];
    NSLog(@"selected %@ %@", card.imageId, card.imageUrl);
    if ([card.myFavorite isEqualToString:@"true"]) {
        card.myFavorite = @"false";
        [card setCardFavorite:NO];
    } else {
        card.myFavorite = @"true";
        [card setCardFavorite:YES];
    }
    if ([appDelegate.selectedCategory.name isEqualToString:@"MY FAVORITES"]) {
        if (appDelegate.selectedCategory.images.count < 1) {
            appDelegate.selectedCategory = appDelegate.defaultCategory;
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            [self.tableView reloadData];
        }
    } else {
        [self.tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    appDelegate.selectedView  = @"customize";
    appDelegate.selectedImage = [appDelegate.selectedCategory.images objectAtIndex:indexPath.row];
    appDelegate.selectedImage.indexPath = indexPath;
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    CardCustomizeViewController *customizeView = [[CardCustomizeViewController alloc] init];
    [self.navigationController pushViewController:customizeView animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
