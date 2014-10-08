//
//  BDFEditProfileViewController.m
//  Buddyfied
//
//  Created by Tom Gilbert on 24/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFEditProfileViewController.h"
#import "BDFBuddyViewModel.h"
#import "TLDynamicSizeView.h"
#import "BDFSettings.h"
#import "BDFAppDelegate.h"
#import "BDFBuddyAttributeTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "BDFUIConfigurationAvailablity.h"
#import "BDFCommentsTableViewCell.h"
#import "UIImageView+Helpers.h"
#import "UIViewController+Helpers.h"
#import "BDFGenericListPicker.h"
#import "BDFMyProfile+Calculated.h"
#import "BDFHasUITextViewDelegate.h"

@interface BDFEditProfileViewController () <UITextViewDelegate>

@property (weak, nonatomic, readonly) BDFAppDelegate *appDelegate;
@property (strong, nonatomic) NSMutableDictionary* prototypeCells;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButtonItem;

@property (weak, nonatomic) IBOutlet UILabel* displayNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView* avatarImageView;

@property (strong, nonatomic) UIView* overlayView;
@property (strong, nonatomic) UIActivityIndicatorView* activityIndicator;

@property (strong, nonatomic) BDFBuddyViewModel* viewModel;

@property (strong, nonatomic) NSDictionary* beforeProfile;
@property (weak, nonatomic) UITextView* editingTextView;

@property (strong, nonatomic) NSArray* requiredLabels;

@end

@implementation BDFEditProfileViewController

-(BDFAppDelegate *)appDelegate
{
    return (BDFAppDelegate*)[UIApplication sharedApplication].delegate;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.viewModel = [[BDFBuddyViewModel alloc] init];
    self.requiredLabels = @[@"Playing", @"Platform"];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //
    if (self.shownInJoinSequence)
    {
        self.navigationItem.leftBarButtonItems = @[];
        self.automaticallyAdjustsScrollViewInsets =YES;
        self.doneBarButtonItem.title = @"Join";
    }
    else
    {   // if this is an in-app profile amendment
        // we need to CANCEL ANY LONG RUNNING SEARCHES so we can make sane use of the undo
        // functionality
        [self.appDelegate.bdfClient cancelAll];
    }
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:17]};
    [self.doneBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    //
    self.clearsSelectionOnViewWillAppear = YES;
    //
    [self setupKeyboardDismissTaps];
    //
    [self registerNibsForBuddyViewModelCells];
    //
    self.displayNameLabel.text = [BDFSettings sharedSettings].userName;
    [self.avatarImageView applyBorder:[UIColor whiteColor]];
    self.avatarImageView.image = self.appDelegate.avatarPlaceholder;
    //
    self.profile.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
    [self.profile.managedObjectContext.undoManager beginUndoGrouping];
    //
    //NOTE: for this to work need to UNCHECK 'Adjust Scroll View Insets'
    self.tableView.contentInset = UIEdgeInsetsMake(self.verticalEdgeInset, 0, 0, 0);
    self.tableView.contentOffset = CGPointMake(0, self.verticalOffset);
    //
    // grab a copy of the serlialized form of starting profile to allow diff calculation
    self.beforeProfile = [self.profile dictionaryForTransmission];
}

-(void)showActivityIndicator
{
    // This matches the whole tableview from top to bottom, including all content
    CGRect overlayViewSize = CGRectMake(self.tableView.frame.origin.x,
                                        self.tableView.frame.origin.y,
                                        self.tableView.contentSize.width,
                                        self.tableView.contentSize.height);
    self.overlayView = [[UIView alloc] initWithFrame:overlayViewSize];
    self.overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self.tableView addSubview:self.overlayView];
    
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.color = [UIColor orangeColor];
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.overlayView addSubview:self.activityIndicator];
    
    
    // position the activityIndicator relative to the table's superview  (CenterX & Y)
    UIView* superview = self.tableView;
    NSLayoutConstraint* cn = [NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:superview
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0];
    [superview addConstraint:cn];
    cn = [NSLayoutConstraint constraintWithItem:self.activityIndicator
                                      attribute:NSLayoutAttributeCenterY
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:superview
                                      attribute:NSLayoutAttributeCenterY
                                     multiplier:1.0
                                       constant:0];
    [superview addConstraint:cn];
    //
    [self scrollViewDidScroll:self.tableView];
    
    [self.activityIndicator startAnimating];
}

-(void)hideActivityIndicator
{
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    [self.overlayView removeFromSuperview];
    self.activityIndicator = nil;
    self.overlayView = nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.activityIndicator.transform = CGAffineTransformMakeTranslation(0, scrollView.contentOffset.y);
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // we have a profile already available to us, just use it
    [self profileUpdated];
}

-(void) viewWillDisappear:(BOOL)animated
{
    if (self.shownInJoinSequence &&
        (NSNotFound==[self.navigationController.viewControllers indexOfObject:self]))
    {
        // BACK button was pressed
        // cancel any running JOIN request
        [self.appDelegate.userClient cancel];
    }
    [super viewWillDisappear:animated];
}

- (void)setupKeyboardDismissTaps
{
    UISwipeGestureRecognizer *swipeUpGestureRecognizer =
    [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(endEditingComments)];
    swipeUpGestureRecognizer.cancelsTouchesInView = NO;
    swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self.tableView addGestureRecognizer:swipeUpGestureRecognizer];
    
    UISwipeGestureRecognizer *swipeDownGestureRecognizer =
    [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(endEditingComments)];
    swipeDownGestureRecognizer.cancelsTouchesInView = NO;
    swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.tableView addGestureRecognizer:swipeDownGestureRecognizer];
    
    UISwipeGestureRecognizer *swipeLeftGestureRecognizer =
    [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(endEditingComments)];
    swipeLeftGestureRecognizer.cancelsTouchesInView = NO;
    swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.tableView addGestureRecognizer:swipeLeftGestureRecognizer];
    
    UISwipeGestureRecognizer *swipeRightGestureRecognizer =
    [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(endEditingComments)];
    swipeRightGestureRecognizer.cancelsTouchesInView = NO;
    swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.tableView addGestureRecognizer:swipeRightGestureRecognizer];
    
    
    UITapGestureRecognizer *tapGestureRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditingComments)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
}

-(void) registerNibsForBuddyViewModelCells
{
    NSString* cellId = [self cellIdentifierAtIndexPath:nil];
    UINib* cellNib = [UINib nibWithNibName:@"BDFBuddySearchAttributeTableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:cellId];
    
    NSIndexPath* commentPath = [NSIndexPath indexPathForRow:self.viewModel.commentRow
                                                  inSection:0];
    NSString* commentCellId = [self cellIdentifierAtIndexPath:commentPath];
    UINib* commentCellNib = [UINib nibWithNibName:@"BDFEditableCommentTableViewCell" bundle:nil];
    [self.tableView registerNib:commentCellNib forCellReuseIdentifier:commentCellId];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.viewModel numRows];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIdentifierAtIndexPath:indexPath]
                                                            forIndexPath:indexPath];
    if ([cell conformsToProtocol:@protocol(BDFBuddyTableViewCell)])
    {
        id <BDFBuddyTableViewCell> buddyCell = (id <BDFBuddyTableViewCell>)cell;
        buddyCell.name = [self.viewModel nameForRow:row];
        buddyCell.value = [self.viewModel valueForRow:row];
        if (row != self.viewModel.commentRow)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        // selection colour
        UIView *selectionColor = [[UIView alloc] init];
        selectionColor.backgroundColor = [BDFSettings sharedSettings].cellSelectionColor;
        cell.selectedBackgroundView = selectionColor;
    }
    if ([cell conformsToProtocol:@protocol(BDFHasUITextViewDelegate)])
    {
        ((id <BDFHasUITextViewDelegate>)cell).delegate = self;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // this next line shouldn't be necessary given self.clearsSelectionOnViewWillAppear = YES
    // but IS required in iOS7.0..1
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger row = indexPath.row;
    if (row == self.viewModel.commentRow)
    {
        ;
    }
    else
    {
        [self performSegueWithIdentifier:@"ProfileAttributesSegue" sender:indexPath];
    }
}


#pragma mark - Dynamic Cell Size Support

-(NSString*)cellIdentifierAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row == self.viewModel.commentRow)
        return @"EditProfileCommentTVC";
    else
        return @"EditProfileTableViewCell";
}


//
// Automatically calculate cell height by retrieving a prototype and either
//  a) returning the existing height or
//  b) if the cell supports it, returning the value of sizeWithData:
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat retVal = 0.0;
    UITableViewCell *cell = nil;
    id item = nil;
    NSString *cellId = [self cellIdentifierAtIndexPath:indexPath];
    if (cellId)
    {
        cell = [self tableView:tableView prototypeForCellIdentifier:cellId];
    }
    if (self.editingTextView && (indexPath.row == self.viewModel.commentRow))
    {
        item = self.editingTextView.text;
    }
    else
    {
        item = [self.viewModel valueForRow:indexPath.row];
    }
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
    if (retVal < BDF_MinCellHeight)
        retVal = BDF_MinCellHeight;

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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // setting color here also takes care of accessory to RHS
    NSUInteger row = indexPath.row;
    NSString* label = [self.viewModel nameForRow:row];
    if ([self isRequiredLabel:label] && ![[self.viewModel valueForRow:row] length])
    {
        cell.backgroundColor = [BDFSettings sharedSettings].requiredBackgroundColor;
    }
    else
    {
        cell.backgroundColor = [BDFSettings sharedSettings].backgroundColor;
    }
}

-(BOOL)isRequiredLabel:(NSString*)cellLabel
{
    return [self.requiredLabels containsObject:cellLabel];
}


#pragma mark - Update UI if Profile updated

-(void) profileUpdated
{
    // ensure view model reflects updated profile
    [self.viewModel updateFromBuddyProfile:self.profile];
    // now start using the view model to update the view
    self.displayNameLabel.text = self.viewModel.name;
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:self.viewModel.imageURL]
                         placeholderImage:self.appDelegate.avatarPlaceholder];
    [self.tableView reloadData];
    // set Done button state based on data for all required fields
    BOOL enableDone = YES;
    for (NSString* label in self.requiredLabels)
    {
        enableDone &= (0 != [[self.viewModel valueForName:label] length]);
        if (!enableDone)
            break;
    }
    self.doneBarButtonItem.enabled = enableDone;
}

#pragma mark - Edit

- (IBAction)doneAction:(UIBarButtonItem *)sender
{
    // ensure any 'Comments' edits are captured
    [self endEditingComments];
    // keep the 'Done' button disabled until we come to some resolution for action
    self.doneBarButtonItem.enabled = NO;
    //
    NSDictionary* args = [self getValuesToSendToServer];
    if (!args.count)
    {   // no changes, nothing to do, just close out.
        self.doneBarButtonItem.enabled = YES;
        [self closeDone];
    }
    else
    {   // we need to send these up to the server
        // exact form of action depends on whether this is a Join or a subsequent Amend
        [self showActivityIndicator];
        if (self.shownInJoinSequence)
        {   // NEW USER - JOIN BUDDYFIED with PROFILE INFORMATION
            [self registerNewUserWithProfile:args];
        }
        else
        {   // EXISTING USER - UPDATE PROFILE
            [self updateExistingUserProfileWithChanges:args];
        }
    }
}

-(NSDictionary*)getValuesToSendToServer
{
    NSDictionary* retVal = [self.profile dictionaryForTransmission];
    if (self.shownInJoinSequence)
    {   // JOIN - we need final state minus any blank valued items
        NSMutableDictionary* mutable = [retVal mutableCopy];
        for (NSString* key in retVal)
        {
            NSString* value = retVal[key];
            if (0 == value.length)
            {
                [mutable removeObjectForKey:key];
            }
        }
        retVal = mutable;
    }
    else
    {   // AMEND: we need the diffs between initial and final state
        retVal = [BDFMyProfile diffsDictionaryForTransmission:self.beforeProfile
                                                              andAfter:retVal];
    }
    return retVal;
}

- (void)registerNewUserWithProfile:(NSDictionary *)diffs
{
    id<BDFUserManagement> client = self.appDelegate.userClient;
    BDFEditProfileViewController* __weak weakSelf = self;
    [client registerNewUser:[BDFSettings sharedSettings].userName
               withPassword:[BDFSettings sharedSettings].password
            andEmailAddress:[BDFSettings sharedSettings].email
                  usingData:diffs
            completionBlock:^(id result, NSError *error) {
                [weakSelf hideActivityIndicator];
                if (error && (error.code == -999))
                {   // this is USER CANCELLATION (probably BACK button)
                    NSLog(@"User Cancelled Registration");
                }
                else
                {
                    NSString* title;
                    NSString* message;
                    if (error)
                    {
                        title = @"User registration failed";
                        message = error.localizedDescription;
                        weakSelf.doneBarButtonItem.enabled = YES;
                    }
                    else
                    {
                        title = [NSString stringWithFormat:@"Welcome to Buddyfied %@!", [BDFSettings sharedSettings].userName];
                        message = @"\nYou should receive an email containing a link to activate your account.\n\nYou'll need to tap on the link\nbefore you can sign in.\n ";
                    }
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                    message:message
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                    if (error)
                    {
                        // ERROR: we retain the changes to the profile
                        // but do not close this view, allowing another attempt
                        // for example if network connectivity restored
                    }
                    else
                    {
                        // SUCCESS: clear out the data changes and close.
                        // User is required to login and profile should be
                        // retrieved from server for whatever user logs in.
                        [weakSelf closeUndoManagerWithUndo:YES];
                        [weakSelf.appDelegate clearPersonalData];
                        if (weakSelf.delegate)
                        {
                            [weakSelf.delegate dismissModalController:weakSelf animated:YES];
                        }
                        else
                        {
                            [self performSegueWithIdentifier:@"UnwindToLoginSegue" sender:self];
                        }
                    }
                }
            }];
}

- (void)updateExistingUserProfileWithChanges:(NSDictionary *)diffs
{
    id<BDFUserManagement> client = self.appDelegate.userClient;
    BDFEditProfileViewController* __weak weakSelf = self;
    [client updateProfileForUser:[BDFSettings sharedSettings].userName
                    withPassword:[BDFSettings sharedSettings].password
                       usingData:diffs
                 completionBlock:^(id result, NSError *error) {
                     [weakSelf hideActivityIndicator];
                     if (error)
                     {
                         // ERROR: we retain the changes to the profile
                         // but do not close this view, allowing another attempt
                         // for example if network connectivity restored
                         if (error.code == -999)
                         {
                             // this is USER CANCELLATION
                             NSLog(@"User Cancelled Profile Amendment");
                         }
                         else
                         {
                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OOOPS - Error!"
                                                                             message:error.localizedDescription
                                                                            delegate:nil
                                                                   cancelButtonTitle:@"OK"
                                                                   otherButtonTitles:nil];
                             [alert show];
                         }
                         weakSelf.doneBarButtonItem.enabled = YES;
                     }
                     else
                     {
                         // SUCCESS: retain the data changes and close.
                         [weakSelf closeDone];
                     }
                 }];
}

-(void) closeDone
{
    [self closeUndoManagerWithUndo:NO];
    self.verticalOffset = self.tableView.contentOffset.y;
    [self.delegate dismissModalController:self animated:NO];
}

- (IBAction)cancelAction:(id)sender
{
    // cancel any running user management request (i.e. profile amendment)
    [self.appDelegate.userClient cancel];
    [self closeUndoManagerWithUndo:YES];
    self.verticalOffset = CGFLOAT_MAX;
    [self.delegate dismissModalController:self animated:NO];
}

-(void)closeUndoManagerWithUndo:(BOOL)shouldUndo
{
    [self.profile.managedObjectContext.undoManager endUndoGrouping];
    if (shouldUndo)
    {
        [self.profile.managedObjectContext.undoManager undo];
    }
    self.profile.managedObjectContext.undoManager = nil;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController* destinationVC = ((UIViewController*)segue.destinationViewController).topViewController;
    if ([destinationVC isKindOfClass:[BDFGenericListPicker class]])
    {
        NSIndexPath* indexPath = (NSIndexPath*)sender;
        NSString* entityName = [self.viewModel nameForRow:indexPath.row];
        if ([entityName isEqualToString:@"Age"])
        {
            entityName = @"Years";
        }
        destinationVC.title = entityName;
        //
        BDFGenericListPicker* genericListPickerVC = (BDFGenericListPicker*)destinationVC;
        genericListPickerVC.buddyProfile = self.profile;
        genericListPickerVC.entityName = entityName;
        genericListPickerVC.withIndex = [self.viewModel pickerShouldDisplayIndex:entityName];
        genericListPickerVC.withoutRefresh = [self.viewModel pickerShouldPreventRefresh:entityName];
        genericListPickerVC.singleSelection = genericListPickerVC.withoutRefresh;
    }
}

#pragma warn - Comment Editor
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self endEditingComments];
}

- (void) textViewDidBeginEditing:(UITextView*)textView
{
    self.editingTextView = textView;
}

- (void)textViewDidChange:(UITextView *)textView
{
    // Causes an animated update of height of UITableViewCell(s)
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

-  (void) endEditingComments
{
    if (self.editingTextView)
    {
        [self.editingTextView resignFirstResponder];
        self.profile.comments = self.editingTextView.text;
        self.editingTextView = nil;
        [self profileUpdated];
        // the following line also works, but by keeping track of the UITextView
        // I guess we are limiting number of calls to resignFirstResponder OR endEditing
        //[self.view endEditing:YES];
    }
}

@end
