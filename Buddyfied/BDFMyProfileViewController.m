//
//  BDFMyProfileViewController.m
//  Buddyfied
//
//  Created by Tom Gilbert on 24/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFMyProfileViewController.h"
#import "BDFBuddyViewModel.h"
#import "TLDynamicSizeView.h"
#import "BDFSettings.h"
#import "BDFAppDelegate.h"
#import "BDFBuddyAttributeTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "BDFUIConfigurationAvailablity.h"
#import "BDFCommentsTableViewCell.h"
#import "BDFMyProfile+Create.h"
#import "UIImageView+Helpers.h"
#import "UIViewController+Helpers.h"
#import "BDFEditProfileViewController.h"

@interface BDFMyProfileViewController () <BDFDismissModalViewControllerDelegate>

@property (weak, nonatomic, readonly) BDFAppDelegate *appDelegate;
@property (strong, nonatomic) NSMutableDictionary* prototypeCells;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editBarButtonItem;

@property (weak, nonatomic) IBOutlet UILabel* displayNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView* avatarImageView;
@property (nonatomic) BOOL refreshInProgress;
@property (nonatomic) BOOL guestUser;

@property (strong, nonatomic) BDFBuddyViewModel* viewModel;

@end

@implementation BDFMyProfileViewController

-(BDFAppDelegate *)appDelegate
{
    return (BDFAppDelegate*)[UIApplication sharedApplication].delegate;
}

- (void)awakeFromNib
{
    self.viewModel = [[BDFBuddyViewModel alloc] init];
    
    __weak BDFMyProfileViewController* weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:BDFUIConfigurationAvailablityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [weakSelf getAndShowData];
         });
     }];
    [super awakeFromNib];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BDFMyProfile*) profile
{
    return ((BDFAppDelegate*)[UIApplication sharedApplication].delegate).profile;
}

-(void)setEditButtonEnabled:(BOOL)enabled
{
    self.editBarButtonItem.enabled = enabled && !self.guestUser;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //
    self.clearsSelectionOnViewWillAppear = YES;
    self.refreshInProgress = NO;
    self.guestUser = [BDFSettings sharedSettings].isGuestUser;
    [self setEditButtonEnabled:YES];
    //
    [self registerNibsForBuddyViewModelCells];
    //
    self.displayNameLabel.text = [BDFSettings sharedSettings].userName;
    [self.avatarImageView applyBorder:[UIColor whiteColor]];
    self.avatarImageView.image = self.appDelegate.avatarPlaceholder;
    //
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor orangeColor];
    [self.refreshControl addTarget:self action:@selector(refreshControlAction)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getAndShowData];
}

-(void) registerNibsForBuddyViewModelCells
{
    NSString* cellId = [self cellIdentifierAtIndexPath:nil];
    UINib* cellNib = [UINib nibWithNibName:@"BDFBuddyAttributeTableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:cellId];
    
    NSIndexPath* commentPath = [NSIndexPath indexPathForRow:self.viewModel.commentRow
                                                  inSection:0];
    NSString* commentCellId = [self cellIdentifierAtIndexPath:commentPath];
    UINib* commentCellNib = [UINib nibWithNibName:@"BDFCommentsTableViewCell" bundle:nil];
    [self.tableView registerNib:commentCellNib forCellReuseIdentifier:commentCellId];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.viewModel numRows];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIdentifierAtIndexPath:indexPath]
                                                            forIndexPath:indexPath];
    if ([cell conformsToProtocol:@protocol(BDFBuddyTableViewCell)])
    {
        id <BDFBuddyTableViewCell> buddyCell = (id <BDFBuddyTableViewCell>)cell;
        NSUInteger row = indexPath.row;
        buddyCell.name = [self.viewModel nameForRow:row];
        buddyCell.value = [self.viewModel valueForRow:row];
    }
    
    return cell;
}

#pragma mark - Dynamic Cell Size Support

-(NSString*)cellIdentifierAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row == self.viewModel.commentRow)
        return @"ProfileCommentTVC";
    else
        return @"MyProfileTableViewCell";
}

//
// Automatically calculate cell height by retrieving a prototype and either
//  a) returning the existing height or
//  b) if the cell supports it, returning the value of sizeWithData:
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat retVal = 0.0;
    id item = [self.viewModel valueForRow:indexPath.row];
    NSString *cellId = [self cellIdentifierAtIndexPath:indexPath];
    UITableViewCell *cell = nil;
    if (cellId)
    {
        cell = [self tableView:tableView prototypeForCellIdentifier:cellId];
        if ([cell conformsToProtocol:@protocol(TLDynamicSizeView)])
        {
            id <TLDynamicSizeView> searchCell = (id <TLDynamicSizeView>)cell;
            CGSize computedSize = [searchCell sizeWithData:item];
            retVal = computedSize.height;
        }
        else
        {
            retVal = cell.bounds.size.height;
        }
    }
    if (retVal < BDF_MinCellHeight)
        retVal = BDF_MinCellHeight;
    //
    // for GUEST user we want to hide all cells apart from COMMENT
    if (self.guestUser)
    {
        if (![cell isKindOfClass:[BDFCommentsTableViewCell class]])
            retVal = 0;
    }

    return retVal;
}

- (UITableViewCell *)tableView:(UITableView *)tableView prototypeForCellIdentifier:(NSString *)cellIdentifier
{
    UITableViewCell *cell;
    if (cellIdentifier) {
        cell = [self.prototypeCells objectForKey:cellIdentifier];
        if (!cell) {
            if (!self.prototypeCells) {
                self.prototypeCells = [[NSMutableDictionary alloc] init];
            }
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            [self.prototypeCells setObject:cell forKey:cellIdentifier];
        }
    }
    return cell;
}

// for GUEST user we want to hide all cells apart from COMMENT
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // setting color here also takes care of accessory to RHS
    cell.backgroundColor = [BDFSettings sharedSettings].backgroundColor;
    //
    if (self.guestUser)
    {
        if (![cell isKindOfClass:[BDFCommentsTableViewCell class]])
            cell.hidden = YES;
    }
}


#pragma mark - Load Profile from server

-(void) getAndShowData
{
    if (self.appDelegate.managedObjectContext)
    {
        // Core Data is now up and running, so we can look for an instance of MyProfile
        if (!self.profile || !self.profile.name.length)
        {
            // we don't have an instance in the database, so better get one
            // this is an async call and will explicitly cause view update once done
            [self loadMyProfile];
        }
        else
        {
            // we have a profile already available to us, just use it
            [self profileUpdated];
        }
    }
}

-(void) profileUpdated
{
    // ensure view model reflects updated profile
    [self.viewModel updateFromBuddyProfile:self.profile];
    // now start using the view model to update the view
    self.displayNameLabel.text = self.viewModel.name;
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:self.viewModel.imageURL]
                         placeholderImage:self.appDelegate.avatarPlaceholder];
    [self.tableView reloadData];
}

- (void)refreshControlAction
{
    // The user just pulled down the collection view. Start loading data.
    if (!self.refreshInProgress)
    {
        [self loadMyProfile];
    }
}

-(void) loadMyProfile
{
    __weak NSManagedObjectContext* context = self.appDelegate.managedObjectContext;
    if (context)
    {
        // update UI state to that appropriate for 'busy downloading'
        self.refreshInProgress = YES;
        [self setEditButtonEnabled:NO];
        //
        __weak BDFMyProfileViewController* weakSelf = self;
        [self.appDelegate.bdfClient getMemberInfo:[BDFSettings sharedSettings].userName
                         withPassword:[BDFSettings sharedSettings].password
                          forMemberId:[BDFSettings sharedSettings].userId
                      completionBlock:^(id result, NSError *error) {
                          //
                          // endRefreshing OK if refreshing or now
                          [weakSelf.refreshControl endRefreshing];
                          if (error)
                          {
                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to load profile"
                                                                              message:error.localizedDescription
                                                                             delegate:nil
                                                                    cancelButtonTitle:@"OK"
                                                                    otherButtonTitles:nil];
                              [alert show];
                          }
                          else
                          {
                              //
                              // should now have access to server-supplied data
                              [BDFMyProfile myProfileFromBuddyfiedInfo:result[@"message"]
                                                inManagedObjectContext:context];
                              [weakSelf.appDelegate.uiManagedDocument updateChangeCount:UIDocumentChangeDone];
                              [weakSelf profileUpdated];
                          }
                          //
                          // update UI state to that appropriate for 'not downloading'
                          self.refreshInProgress = NO;
                          [self setEditButtonEnabled:YES];
                      }
         ];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController* controller = ((UIViewController*)segue.destinationViewController).topViewController;
    if ([controller isKindOfClass:[BDFEditProfileViewController class]])
    {
        BDFEditProfileViewController* editProfileViewController = (BDFEditProfileViewController*)controller;
        editProfileViewController.delegate = self;
        editProfileViewController.profile = self.profile;
        editProfileViewController.verticalOffset = self.tableView.contentOffset.y;
        editProfileViewController.verticalEdgeInset = self.tableView.contentInset.top - self.tableView.contentInset.bottom;
    }
}

-(void)dismissModalController:(id)sender animated:(BOOL)animated
{
    [self dismissViewControllerAnimated:animated completion:nil];
    if ([sender isKindOfClass:[BDFEditProfileViewController class]])
    {
        CGFloat verticalOffset = ((BDFEditProfileViewController*)sender).verticalOffset;
        if (CGFLOAT_MAX != verticalOffset)
        {
            self.tableView.contentOffset = CGPointMake(0, verticalOffset);
        }
    }
}


@end
