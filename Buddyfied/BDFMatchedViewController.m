//
//  BDFMatchedViewController.m
//  Buddyfied
//
//  Created by Tom Gilbert on 24/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFMatchedViewController.h"
#import "BDFMatchedCollectionViewCell.h"
#import "BDFBuddyViewController.h"
#import "BDFAppDelegate.h"
#import "BDFBuddy+Helpers.h"
#import "BDFSearchRequest+Calculated.h"
#import "BDFDataLoader.h"
#import "BDFSettings.h"
#import "BDFUIConfigurationAvailablity.h"
#import "BDFEntityNames.h"
#import "UIImageView+AFNetworking.h"
#import "BDFMatchedCollectionViewHeader.h"

@interface BDFMatchedViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong, readonly) BDFSearchRequest *searchRequest;
@property (nonatomic, strong) NSArray *buddies; // of BDFBuddy
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIColor *cellBackgroundColor;
@property (nonatomic, strong) UIColor *cellHighlightedColor;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, weak) BDFAppDelegate* appDelegate;

@property (nonatomic, strong) NSString* warnUserText;

@end

@implementation BDFMatchedViewController

static NSString* const BuddyDetailsSegue = @"BuddyDetailsSegue";
static NSString* const NoMatchesInfoHeader = @"NoMatchesInfoHeader";
static NSString* const MatchedCollectionViewCell = @"MatchedCollectionViewCell";

-(BDFAppDelegate*) appDelegate
{
    return (BDFAppDelegate*)[UIApplication sharedApplication].delegate;
}

-(BDFSearchRequest*) searchRequest
{
    return ((BDFAppDelegate*)[UIApplication sharedApplication].delegate).searchRequest;
}

-(NSArray*)buddies
{
    if (!_buddies)
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:BUDDY_ENTITY];
        request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES]];
        _buddies = [self.searchRequest.managedObjectContext executeFetchRequest:request
                                                                         error:NULL];
    }
    return _buddies;
}

- (void)awakeFromNib
{
    __weak BDFMatchedViewController* weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:BDFUIConfigurationAvailablityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [weakSelf getDataIfRequiredAndUpdateViewState];
         });
     }];
    [super awakeFromNib];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    //
    self.cellBackgroundColor = [UIColor colorWithRed:216.0f/255.0f
                                               green:216.0f/255.0f
                                                blue:216.0f/255.0f
                                               alpha:1.0];
    self.cellHighlightedColor = [UIColor orangeColor];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor orangeColor];
    // may as well set background colour here, was *required* with UITableViewController
    self.refreshControl.backgroundColor = [BDFSettings sharedSettings].backgroundColor;
    [self.refreshControl addTarget:self
                            action:@selector(refreshControlAction)
                  forControlEvents:UIControlEventValueChanged];
    
    [self.collectionView addSubview:self.refreshControl];
    // necessary to ensure collection view refresh works when items don't fill screen
    self.collectionView.alwaysBounceVertical = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.masterDetailController setScrollingEnabled:YES];
    //
    [self getDataIfRequiredAndUpdateViewState];
}

-(void)getDataIfRequiredAndUpdateViewState
{
    BDFSearchRequest* searchRequest = self.searchRequest;
    if (searchRequest)
    {
        if ((self.buddies.count > 0) ||
            !searchRequest.anyActiveSearchCriteria)
        {
            [self.activityIndicator stopAnimating];
            if (!searchRequest.anyActiveSearchCriteria)
            {
                [self showMessage:@"Search not specified"];
            }
            [self.collectionView reloadData];
        }
        else
        {
            // this goes off and requests the data from the server
            [self reloadData];
        }
    }
}


// Shows message for user in table header. Intended for cases where there is no
//  data.
// NOTE that any header must be removed|hidden once data arrives.
-(void) showMessage:(NSString*)message
{
    self.warnUserText = message;
}

- (void)refreshControlAction
{
    [self reloadData];
}

-(void)reloadData
{
    BDFMatchedViewController __weak *weakSelf = self;
    BDFAppDelegate __weak *weakAppDelegate = (BDFAppDelegate*)[UIApplication sharedApplication].delegate;
    weakAppDelegate.showNetworkActivity = YES;
    [weakAppDelegate.bdfClient getMatches:[BDFSettings sharedSettings].userName
                         withPassword:[BDFSettings sharedSettings].password
                     forSearchRequest:self.searchRequest
                      completionBlock:^(id result, NSError *error) {
                          dispatch_async(dispatch_get_main_queue(), ^ {
                              weakAppDelegate.showNetworkActivity = NO;
                              weakSelf.buddies = nil;
                              [weakSelf.refreshControl endRefreshing];
                              [weakSelf.activityIndicator stopAnimating];
                              if (0 == self.buddies.count)
                              {
                                  [self showMessage:@"No matches found"];
                              }
                              else
                              {
                                  [self showMessage:@""];
                              }
                              if (error)
                              {
                                  if (error.code == -999)
                                  {
                                      
                                      NSLog(@"User Cancelled Search");
                                  }
                                  else
                                  {
                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Search failed"
                                                                                      message:error.localizedDescription
                                                                                     delegate:nil
                                                                            cancelButtonTitle:@"OK"
                                                                            otherButtonTitles:nil];
                                      [alert show];
                                  }
                              }
                              [weakSelf.collectionView reloadData];
                          });
                      }];
}


#pragma mark - UICollectionView Datasource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return self.buddies.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BDFMatchedCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:MatchedCollectionViewCell
                                                                       forIndexPath:indexPath];
    cell.backgroundColor = self.cellBackgroundColor;
    
    BDFBuddy* buddy = self.buddies[indexPath.row];
    cell.unique = buddy.unique;
    cell.label.text = buddy.name;
    //
    // NOTE: design was to use thumbnailURL here but Buddyfied returns 50x50 image
    // which doesn't look great sized to 132x132 display
    // SO switched to using full image, where Buddyfied returns 232x232
    [cell.buddyImageView setImageWithURL:[NSURL URLWithString:buddy.imageURL]
                        placeholderImage:self.appDelegate.avatarPlaceholder];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateBackgroundColorForCellAtIndexPath:indexPath isSelected:YES force:NO];
}

-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateBackgroundColorForCellAtIndexPath:indexPath isSelected:NO force:NO];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateBackgroundColorForCellAtIndexPath:indexPath isSelected:YES force:NO];
    BDFMatchedViewController __weak *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf updateBackgroundColorForCellAtIndexPath:indexPath isSelected:NO force:YES];
        [weakSelf performSegueWithIdentifier:BuddyDetailsSegue sender:indexPath];
    });
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateBackgroundColorForCellAtIndexPath:indexPath isSelected:NO force:NO];
}

-(void)updateBackgroundColorForCellAtIndexPath:(NSIndexPath *)indexPath isSelected:(BOOL)isSelected force:(BOOL)force
{
    UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    [self updateBackgroundColorForCell:cell isSelected:isSelected force:force];
}

-(void)updateBackgroundColorForCell:(UICollectionViewCell *)cell isSelected:(BOOL)isSelected force:(BOOL)force
{
    // NOTE that || ensures that pressing on selected row then moving finger off doesn't
    // cause highlight / unhighlight cycle leaving text invisible, white on grey.
    cell.backgroundColor = (isSelected || (!force && cell.isSelected)) ?
                                self.cellHighlightedColor : self.cellBackgroundColor;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    BDFMatchedCollectionViewHeader* header = nil;
    if (UICollectionElementKindSectionHeader == kind)
    {
        header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                    withReuseIdentifier:NoMatchesInfoHeader
                                                           forIndexPath:indexPath];
        if (self.warnUserText.length)
        {
            header.hidden = NO;
            header.userInfoLabel.text = self.warnUserText;
        }
        else
        {
            header.hidden = YES;
        }
    }
    return header;
}

#pragma mark - UICollectionViewDelegateFlowLayout

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize retVal = CGSizeZero;
    if (self.warnUserText.length)
    {
        retVal = CGSizeMake(collectionView.bounds.size.width, 100);
    }
    return retVal;
}


#pragma mark - Navigation
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // ensure we diable top level scrolling since not applicable to subsequent screens
    // only this root view
    [self.masterDetailController setScrollingEnabled:NO];
    //
    if ([segue.identifier isEqualToString:BuddyDetailsSegue])
    {
        // based on segue id gonna assume types of sender, segue.destinationViewController
        NSIndexPath* indexPath = (NSIndexPath*)sender;
        //
        BDFMatchedCollectionViewCell* cell = (BDFMatchedCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
        BDFBuddyViewController* buddyViewController = segue.destinationViewController;
        buddyViewController.buddy = self.buddies[indexPath.row];
        buddyViewController.thumbnail = cell.buddyImageView.image;
    }
}

@end
