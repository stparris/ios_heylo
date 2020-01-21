//
//  CardCustomizeViewController.m
//  heylo
//
//  Created by Scott Parris on 3/3/15.
//  Copyright (c) 2015 TapIn. All rights reserved.
//

#import "CardCustomizeViewController.h"
#import "RootViewController.h"
#import "AppDelegate.h"
#import "CardImage.h"
#import "HeaderGradientView.h"
#import "SendCardViewController.h"
#import "ImageCache.h"
#import "FlashView.h"
#import "CardSourceViewController.h"

#define kBorderWidth 8.0

@interface CardCustomizeViewController () {
    NSMutableArray *imageSets;
    int imageIndex;
}

@property (nonatomic, strong) UIScrollView *cardsView;
@property (nonatomic, strong) UIPageControl *pageController;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) FlashView *flashView;

- (void)popToRoot:(id)sender;
- (void)sendMessage:(id)sender;
- (void)changePage:(id)sender;
- (void)showMessage;
- (void)showSource:(id)sender;

@end


@implementation CardCustomizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBarHidden = NO;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.view.backgroundColor = [UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
    UIScreen *screen = [UIScreen mainScreen];
    HeaderGradientView *dropShadow = [[HeaderGradientView alloc] initWithFrame:CGRectMake(0, 64, screen.bounds.size.width, 12.0)];
    [self.view addSubview:dropShadow];
    self.cardsView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 84, screen.bounds.size.width, screen.bounds.size.width + 20)];
    self.cardsView.pagingEnabled = YES;
    self.cardsView.delegate = self;
    [self.cardsView setShowsHorizontalScrollIndicator:NO];
    CGFloat buttonX = 0.0;
    CGFloat buttonMargin = screen.bounds.size.width / 3;
    NSInteger numberOfViews = appDelegate.selectedImage.cardImages.count;
    imageSets = [[NSMutableArray alloc] init];
    for (int i = 0; i < numberOfViews; i++) {
        CGFloat xOrigin = i * self.view.frame.size.width + 20;
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin, 20, screen.bounds.size.width - 40, screen.bounds.size.width - 40)];
        NSString *urlString = [appDelegate.selectedImage.cardImages objectAtIndex:i];
        [imageSets addObject:urlString];

        UIImage *theImage;
        if ([appDelegate.imageCache doesExist:urlString]) {
            theImage = [appDelegate.imageCache getImageForURL:urlString];
        } else {
            NSURL *url = [NSURL URLWithString:urlString];
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            theImage = [UIImage imageWithData:imageData];
            [appDelegate.imageCache cacheImage:theImage withData:imageData forURL:urlString];
        }
        image.image = theImage;
        image.layer.masksToBounds = YES;
        image.layer.borderColor = [UIColor whiteColor].CGColor;
        image.layer.borderWidth = 4;
        [self.cardsView addSubview:image];
        buttonX = (i * self.view.frame.size.width) + buttonMargin;
        NSLog(@"button x %f", buttonX);
        UIButton *sourceButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, screen.bounds.size.width - 15, buttonMargin, 16.0)];
        NSString *source = [appDelegate.selectedImage.cardAttribs objectAtIndex:i];
        if (source.length > 0) {
            [sourceButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
            sourceButton.titleLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:10];
            [sourceButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [sourceButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
            [sourceButton setTitle:source forState:UIControlStateNormal];
            // [sourceButton setBackgroundColor:[UIColor whiteColor]];
            sourceButton.tag = i;
            [sourceButton addTarget:self action:@selector(showSource:) forControlEvents:UIControlEventTouchUpInside];
            [self.cardsView addSubview:sourceButton];
        }
    }
    self.cardsView.contentSize = CGSizeMake(self.view.frame.size.width * numberOfViews, screen.bounds.size.width);
    [self.view addSubview:self.cardsView];
    
    CGFloat originY = screen.bounds.size.width + 97;
    CGFloat controlYpos = (screen.bounds.size.height - originY)/4;
    self.pageController = [[UIPageControl alloc] initWithFrame:CGRectMake(40, originY, screen.bounds.size.width - 80, 30)];
    self.pageController.backgroundColor = [UIColor clearColor];
    self.pageController.pageIndicatorTintColor = [UIColor blackColor];
    self.pageController.currentPageIndicatorTintColor = [UIColor redColor];
    self.pageController.numberOfPages = numberOfViews;
    [self.pageController sizeForNumberOfPages:numberOfViews];
    self.pageController.userInteractionEnabled = YES;
    [self.pageController addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.pageController];
    originY = originY + controlYpos;
    self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(screen.bounds.size.width/2 - 32, originY, 64, 64)];
    self.sendButton.titleLabel.font = [UIFont fontWithName:@"fontello" size:48.0];
    [self.sendButton setTitleColor:[UIColor colorWithRed:57.0/255 green:181.0/255 blue:73.0/255 alpha:1.0] forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    
    [self.sendButton setTitle:@"\uE904" forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sendButton];
    
    self.title = NSLocalizedString(@"CUSTOMIZE", @"CUSTOMIZE");
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor], NSForegroundColorAttributeName,
      [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:24],
      NSFontAttributeName, nil]];
    
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    [backButton setTitleTextAttributes:@{
                                         NSFontAttributeName: [UIFont fontWithName:@"fontello" size:26.0],
                                         NSForegroundColorAttributeName: [UIColor blackColor]
                                         } forState:UIControlStateNormal];
    backButton.title = @"\uE9F8";
    backButton.target = self;
    backButton.action = @selector(popToRoot:);
    [self.navigationItem setLeftBarButtonItem:backButton];
    
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] init];
    [homeButton setTitleTextAttributes:@{
                                         NSFontAttributeName: [UIFont fontWithName:@"fontello" size:26],
                                         NSForegroundColorAttributeName: [UIColor blackColor]
                                         } forState:UIControlStateNormal];
    homeButton.title = @"\uEA03";
    homeButton.target = self;
    homeButton.action = @selector(goHome:);
    [self.navigationItem setRightBarButtonItem:homeButton];

    

    CGFloat navWidth = self.navigationController.navigationBar.frame.size.width;
    CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
    UIView *navBorder = [[UIView alloc] initWithFrame:CGRectMake(0,navHeight -2, navWidth, 2)];
    navBorder.tag = 1;
    //navBorder.backgroundColor = [UIColor grayColor];
    navBorder.backgroundColor = [UIColor colorWithRed:140.0/255.0 green:140.0/255.0 blue:140.0/255.0 alpha:1.0];
    [self.navigationController.navigationBar addSubview:navBorder];

    self.flashView = [[FlashView alloc] initWithScreenWidth:self.view.bounds.size.width];
    self.flashView.hidden = YES;
    [self.navigationController.navigationBar addSubview:self.flashView];
    
 /**   UIButton *test = [UIButton buttonWithType:UIButtonTypeCustom];
    test.frame = CGRectMake(50, 200, 40, 20);
    test.titleLabel.text = @"test";
    test.backgroundColor = [UIColor colorWithRed:231.0/255 green:113.0/255 blue:85.0/255 alpha:1.0];
    [test addTarget:self action:@selector(popToRoot:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:test];
*/
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"flashMessage" object:nil];
}

- (void)showMessage
{
    if (appDelegate.alert.length > 1)
        [self.flashView showMessage:appDelegate.alert];
    appDelegate.alert = @"";
}


- (void)viewDidAppear:(BOOL)animated
{
    [self.sendButton setTitleColor:[UIColor colorWithRed:57.0/255 green:181.0/255 blue:73.0/255 alpha:1.0] forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMessage) name:@"flashMessage" object:nil];

}

- (void)changePage:(id)sender
{
    CGRect frame;
    frame.origin.x = self.cardsView.frame.size.width * self.pageController.currentPage;
    frame.origin.y = 0;
    frame.size = self.cardsView.frame.size;
    [self.cardsView scrollRectToVisible:frame animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.cardsView.frame.size.width;
    imageIndex = floor((self.cardsView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageController.currentPage = imageIndex;
    // NSLog(@"page %i", imageIndex);
}

- (void)popToRoot:(id)sender
{
    appDelegate.selectedView = @"backToHome";
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)showSource:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSString *urlString = [appDelegate.selectedImage.cardAttribURLs objectAtIndex:button.tag];
    CardSourceViewController *sourceView = [[CardSourceViewController alloc] init];
    [sourceView.activityIndicator startAnimating];
    sourceView.sourceURL = urlString;
    [self.navigationController pushViewController:sourceView animated:YES];
}

- (void)sendMessage:(id)sender
{
    SendCardViewController *sendView = [[SendCardViewController alloc] init];
    sendView.cardImage = [appDelegate.imageCache getImageForURL:[imageSets objectAtIndex:imageIndex]];
    sendView.cardURL = [appDelegate.selectedImage.cardImages objectAtIndex:imageIndex];
    [self.navigationController pushViewController:sendView animated:YES];
}


- (void)goHome:(id)sender
{
    appDelegate.selectedView = @"home";
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
