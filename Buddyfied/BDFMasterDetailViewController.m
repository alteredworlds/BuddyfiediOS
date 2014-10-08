//
//  BDFViewController.m
//  Buddyfied
//
//  Created by Tom Gilbert on 10/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFMasterDetailViewController.h"
#import "BDFDetailController.h"
#import "UIViewController+Helpers.h"
#import "BDFMasterViewController.h"
#import "BDFSettings.h"

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


@interface BDFMasterDetailViewController ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, readonly) NSUInteger currentPage;
@property (nonatomic) SEL completionHandler;
@property (nonatomic) CGPoint contentOffset;
@property (nonatomic) BOOL swipeFromEdge;

// WARNING - this design is a HACK right now.
@property (nonatomic, strong) BDFMasterViewController* masterViewController;
@property (nonatomic, strong) UIViewController* detailViewController;
@property (nonatomic, strong) id<BDFDetailController> detailController;

@end

@implementation BDFMasterDetailViewController
{
    CGPoint lastScrollOffset;
    CGRect  lastFrame;
    CGFloat scrollContentOffsetXFactor;
}

@synthesize scrollingEnabled=_scrollingEnabled;
@synthesize homePage=_homePage;

const NSUInteger numberPages = 2;
const CGFloat BAR_WIDTH = 54;

const NSUInteger MASTER_PAGE = 0;
const NSUInteger DETAIL_PAGE = 1;
const bool ENABLE_SCROLL_DEBUG = false;

static NSString* const MasterViewControllerId = @"MasterPageViewController";

-(NSUInteger)homePage
{
    return 0;
}

-(id<BDFDetailController>) detailController
{
    id<BDFDetailController> retVal = nil;
    UIViewController* controller = self.detailViewController.topViewController;
    if ([controller conformsToProtocol:@protocol(BDFDetailController)])
    {
        retVal = (id <BDFDetailController>)controller;
    }
    return retVal;
}

-(void)setScrollingEnabled:(BOOL)scrollingEnabled
{
    _scrollingEnabled = scrollingEnabled;
    [self dumpScrollInfo:@"setScrollingEnabled"];
//    if (scrollingEnabled)
//    {
//        if (!CGRectIsEmpty(lastFrame))
//            self.scrollView.frame = lastFrame;
//    }
//    else
//    {
//        lastFrame = self.scrollView.frame;
//    }
}


-(NSUInteger)currentPage
{
//    NSLog(@"%@ contentOffset%@ contentInset%@ contentSize%@ bounds%@ frame%@ masterFrame%@ detailFrame%@",
//          @"currentPage",
//          NSStringFromCGPoint(self.scrollView.contentOffset),
//          NSStringFromUIEdgeInsets(self.scrollView.contentInset),
//          NSStringFromCGSize(self.scrollView.contentSize),
//          NSStringFromCGRect(self.scrollView.bounds),
//          NSStringFromCGRect(self.scrollView.frame),
//          self.masterViewController ? NSStringFromCGRect(self.masterViewController.view.frame) : nil,
//          self.detailViewController ? NSStringFromCGRect(self.detailViewController.view.frame) : nil);
    
    CGFloat masterWidth = self.scrollView.frame.size.width - BAR_WIDTH;
    NSUInteger retVal = (self.scrollView.contentOffset.x < masterWidth) ? 0 : 1;

//    NSLog(@"masterWidth: %f  pageCalc returns %lu", masterWidth, (unsigned long)retVal);
    return retVal;
}

- (void)viewDidLoad
{
    //NSLog(@"viewDidLoad");
    [super viewDidLoad];
	//
    // use the parent view size here, since the scrollView itself sizes to match
    // content, while parent view sizes to match device
    CGFloat contentWidth = CGRectGetWidth(self.view.frame) * numberPages - BAR_WIDTH;
    CGFloat contentHeight = CGRectGetHeight(self.view.frame);
    CGSize contentSize = CGSizeMake(contentWidth, contentHeight);
    //
    // DON'T change contentView's translatesAutoresizingMaskIntoConstraints, which defaults to YES;
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentWidth, contentHeight)];
    self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
    [self.scrollView addSubview:self.contentView];
    //
    // Set the content size of the scroll view to match the size of the content view:
    self.scrollView.contentSize  = contentSize;
    //
    // a page is the width of the scroll view
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    self.scrollView.delaysContentTouches = NO;
    self.scrollView.bounces = NO;
    self.scrollingEnabled = YES;
    //
    // this shouldn't be necessary, but iOS 8.0 has fixed odd
    scrollContentOffsetXFactor = SYSTEM_VERSION_LESS_THAN(@"8.0") ? 2.0 : 1.0;
    //
    // starting point is the DETAIL page
    [self showDetail:NO];
    //
    [self loadMaster];
    //
    NSUInteger row = [[BDFSettings sharedSettings].activeMenuIndex integerValue];
    [self.masterViewController setActiveMenuItemAtRow:row];
    //
    [self dumpScrollInfo:@"viewDidLoad"];
}

-(void)viewWillAppear:(BOOL)animated
{
    //NSLog(@"viewWillAppear");
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    //NSLog(@"viewWillDisappear");
    [super viewWillDisappear:animated];
}

//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//                                duration:(NSTimeInterval)duration
//{
//    CGFloat contentWidth = CGRectGetWidth(self.view.frame) * numberPages - BAR_WIDTH;
//    CGFloat contentHeight = CGRectGetHeight(self.view.frame);
//    
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    CGFloat screenWidth = screenRect.size.width;
//    CGFloat screenHeight = screenRect.size.height;
//    
//    NSLog(@"willRotateToInterfaceOrientation %d from %d w view.frame.width %f height %f",
//          toInterfaceOrientation,
//          [UIDevice currentDevice].orientation,
//          screenWidth,
//          screenHeight);
//    if (UIDeviceOrientationIsLandscape(toInterfaceOrientation))
//    {
//        ;
//    }
//    else if (UIDeviceOrientationIsPortrait(toInterfaceOrientation))
//    {
//        ;
//    }
//}
//
//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    UIDeviceOrientation toInterfaceOrientation = [UIDevice currentDevice].orientation;
//    CGFloat contentWidth = CGRectGetWidth(self.view.frame) * numberPages - BAR_WIDTH;
//    CGFloat contentHeight = CGRectGetHeight(self.view.frame);
//    
//    NSLog(@"didRotateFromInterfaceOrientation %d to %d w view.frame.width %f height %f",
//          fromInterfaceOrientation,
//          [UIDevice currentDevice].orientation,
//          contentWidth,
//          contentHeight);
//    if (UIDeviceOrientationIsLandscape(toInterfaceOrientation))
//    {
//        ;
//    }
//    else if (UIDeviceOrientationIsPortrait(toInterfaceOrientation))
//    {
//        ;
//    }
//
//}

- (void)loadMaster
{
    UIViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:MasterViewControllerId];
    controller.view.translatesAutoresizingMaskIntoConstraints  = NO;
    //
    UIViewController* topVC = controller.topViewController;
    if ([topVC isKindOfClass:[BDFMasterViewController class]])
    {
        self.masterViewController = (BDFMasterViewController*)topVC;
        self.masterViewController.masterDetailController = self;
    }
    //
    [self addChildViewController:controller];
    [self.contentView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
    //
    NSNumber* masterWidth = [NSNumber numberWithFloat:(self.scrollView.frame.size.width - BAR_WIDTH)];
    NSDictionary* viewsDictionary = @{@"contentView": self.contentView, @"masterView": controller.view};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[masterView(width)]"
                                                                             options:0
                                                                             metrics:@{@"width" : masterWidth}
                                                                               views:viewsDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[masterView]|"
                                                                             options:0 metrics: 0 views:viewsDictionary]];
}

- (void)loadDetailWithViewControllerId:(NSString*)viewControllerId
{
    UIViewController *controller = self.detailViewController;
    if (controller)
    {   //
        // detailController already exists, which means we are swapping in a new one
        // to replace it. So must cleanly remove IFF not the one we want.
        if ([controller.restorationIdentifier isEqualToString:viewControllerId])
            return;
        // ensure toggleOnTouch OFF for existing detail
        [self.detailController enableToggleOnTouch:NO];
        [controller willMoveToParentViewController:nil];
        [controller.view removeFromSuperview];
        [controller removeFromParentViewController];
        self.detailViewController = nil;
        controller = nil;
    }
    //
    // go ahead and load the requested view controller (from identifier)
    controller = [self.storyboard instantiateViewControllerWithIdentifier:viewControllerId];
    controller.view.translatesAutoresizingMaskIntoConstraints  = NO;
    self.detailViewController = controller;
    //
    UIViewController* topVC = controller.topViewController;
    if ([topVC conformsToProtocol:@protocol(BDFHasMasterDetailController)])
    {
        id <BDFHasMasterDetailController> useIt = (id <BDFHasMasterDetailController>)topVC;
        useIt.masterDetailController = self;
    }
    //
    [self addChildViewController:controller];
    [self.contentView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
    
    NSNumber* masterWidth = [NSNumber numberWithFloat:(self.scrollView.frame.size.width - BAR_WIDTH)];
    NSNumber* detailWidth = [NSNumber numberWithFloat:self.scrollView.frame.size.width];
    NSDictionary* viewsDictionary = @{@"contentView": self.contentView, @"detailView": controller.view};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-offset-[detailView(width)]"
                                                                             options:0
                                                                             metrics:@{@"offset" : masterWidth,
                                                                                       @"width" : detailWidth}
                                                                               views:viewsDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[detailView]|"
                                                                             options:0 metrics: 0 views:viewsDictionary]];
}

#pragma mark UIScrollViewDelegate logging helpers
-(void)dumpScrollInfo:(NSString*)name
{
    if (ENABLE_SCROLL_DEBUG)
    {
        NSLog(@"%@ contentOffset%@ contentInset%@ contentSize%@ bounds%@ frame%@ masterFrame%@ detailFrame%@",
              name,
              NSStringFromCGPoint(self.scrollView.contentOffset),
              NSStringFromUIEdgeInsets(self.scrollView.contentInset),
              NSStringFromCGSize(self.scrollView.contentSize),
              NSStringFromCGRect(self.scrollView.bounds),
              NSStringFromCGRect(self.scrollView.frame),
              self.masterViewController ? NSStringFromCGRect(self.masterViewController.view.frame) : nil,
              self.detailViewController ? NSStringFromCGRect(self.detailViewController.view.frame) : nil);
    }
}

-(void)dumpScrollInfoWithLocation:(NSString*)name scrollView:(UIScrollView *)scrollView
{
    if (ENABLE_SCROLL_DEBUG)
    {
        CGPoint location = [scrollView.panGestureRecognizer locationInView:scrollView];
        NSLog(@"%@ location%@ contentOffset%@ contentInset%@ contentSize%@ bounds%@ frame%@ masterFrame%@ detailFrame%@",
              name,
              NSStringFromCGPoint(location),
              NSStringFromCGPoint(scrollView.contentOffset),
              NSStringFromUIEdgeInsets(scrollView.contentInset),
              NSStringFromCGSize(scrollView.contentSize),
              NSStringFromCGRect(scrollView.bounds),
              NSStringFromCGRect(scrollView.frame),
              self.masterViewController ? NSStringFromCGRect(self.masterViewController.view.frame) : nil,
              self.detailViewController ? NSStringFromCGRect(self.detailViewController.view.frame) : nil);
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self dumpScrollInfoWithLocation:@"scrollViewWillBeginDragging" scrollView:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self dumpScrollInfo:@"scrollViewDidScroll"];
    if (self.scrollingEnabled)
    {
        lastScrollOffset = scrollView.contentOffset;
        self.masterViewController.view.transform = CGAffineTransformMakeTranslation(scrollContentOffsetXFactor * scrollView.contentOffset.x, 0);
    }
    else
        scrollView.contentOffset = lastScrollOffset;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self dumpScrollInfo:@"scrollViewDidEndDragging"];
        //NSLog(@"scrollViewDidEndDragging");
        [self updateDetailToggleOnTouch];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidEndDecelerating");
    [self dumpScrollInfo:@"scrollViewDidEndDecelerating"];
    [self updateDetailToggleOnTouch];
}

#pragma mark BDFShowAppMenuDelegate
-(void)toggleMaster:(id)sender
{
    BOOL animated = YES;
    if (MASTER_PAGE == self.currentPage)
        [self showDetail:animated];
    else
        [self showMaster:animated];
}

-(void)updateDetailToggleOnTouch
{
    //NSLog(@"updateDetailToggleOnTouch currentPage %lu", (unsigned long)self.currentPage);
    [self.detailController enableToggleOnTouch:(MASTER_PAGE == self.currentPage) ? YES : NO];
}

-(void)showMaster:(BOOL)animated
{
    [self scrollToPage:MASTER_PAGE animated:animated];
}

-(void)showDetail:(BOOL)animated
{
    [self scrollToPage:DETAIL_PAGE animated:animated];
}

-(void)switchToDetail:(NSString*)detailViewControllerId
{
    [self loadDetailWithViewControllerId:detailViewControllerId];
}

-(void)setActiveMenuItemNamed:(NSString*)name
{
    [self.masterViewController setActiveMenuItemNamed:name];
}

-(void)setActiveMenuItemAtRow:(NSUInteger)row
{
    [self.masterViewController setActiveMenuItemAtRow:row];
}


#pragma mark - Page Navigation
-(void)scrollToPage:(NSUInteger)page animated:(BOOL)animated
{
    //NSLog(@"MasterDetailViewController scrollToPage:%lu", (unsigned long)page);
    // update the scroll view to the appropriate page
    //
    CGPoint point = CGPointMake(MAX(0, CGRectGetWidth(self.scrollView.bounds) * page - BAR_WIDTH),
                                0);
    [self.scrollView setContentOffset:point animated: animated];
    [self dumpScrollInfo:@"scrollToPage"];
    [self.detailController enableToggleOnTouch:(MASTER_PAGE == page) ? YES : NO];
}

@end
