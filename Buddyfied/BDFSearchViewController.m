//
//  BDFSearchViewController.m
//  Buddyfied
//
//  Created by Tom Gilbert on 19/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFSearchViewController.h"
#import "BDFGenericListPicker.h"
#import "BDFSearchRequest+Calculated.h"
#import "BDFAppDelegate.h"
#import "BDFBuddyAttributeTableViewCell.h"
#import "BDFBuddy+Helpers.h"
#import "UIViewController+Helpers.h"
#import "BDFPlayerAttribute+Create.h"
#import "BDFUIConfigurationAvailablity.h"
#import "BDFEntityNames.h"
#import "BDFSettings.h"
//
// to handle switching to MATCHED
#import "BDFHasMasterDetailController.h"
//
#import "BDFBuddyProfileViewModel.h"

@interface BDFSearchViewController ()

@property (weak, nonatomic) IBOutlet UIButton *matchedButton;
@property (nonatomic, weak, readonly) BDFSearchRequest* searchRequest;

@property (strong, nonatomic) NSMutableDictionary *prototypeCells;

@property (strong, nonatomic) BDFBuddyProfileViewModel *viewModel;

@end


static NSString* const MatchedMenuItemName = @"Matched";


@implementation BDFSearchViewController


- (void)awakeFromNib
{
    self.viewModel = [[BDFBuddyProfileViewModel alloc] init];
    
    __weak BDFSearchViewController* weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:BDFUIConfigurationAvailablityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [weakSelf.viewModel updateFromBuddyProfile:weakSelf.searchRequest];
             [weakSelf.tableView reloadData];
             [weakSelf syncViewStateToModel];
         });
     }];
    [super awakeFromNib];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BDFSearchRequest*) searchRequest
{
    return ((BDFAppDelegate*)[UIApplication sharedApplication].delegate).searchRequest;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;
    //
    UINib* cellNib = [UINib nibWithNibName:@"BDFBuddySearchAttributeTableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:[self cellIdentifierAtIndexPath:nil]];
    //
    [self.viewModel updateFromBuddyProfile:self.searchRequest];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changes:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:nil];
    //
    // apply border around matched button to show it is as wide as the UITableView rows
    self.matchedButton.layer.cornerRadius = 4;
    self.matchedButton.layer.borderWidth = 1;
    self.matchedButton.layer.borderColor = self.matchedButton.tintColor.CGColor;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self syncViewStateToModel];
    [self.masterDetailController setScrollingEnabled:YES];
}

-(void)enableToggleOnTouch:(BOOL)enable
{
    [super enableToggleOnTouch:enable];
    //
    // we also need to hit the following additional control(s)...
    self.matchedButton.userInteractionEnabled = !enable;
}

-(void)syncViewStateToModel
{
    self.matchedButton.enabled = self.searchRequest.anyActiveSearchCriteria;
}

-(void)changes:(NSNotification*)notification
{
    NSSet* objects = [[notification userInfo] valueForKey:NSUpdatedObjectsKey];
    if ([objects containsObject:self.searchRequest])
    {
        //NSLog(@"BDFSearchController.searchRequest - change notification");
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
        
        __weak BDFSearchViewController* weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            //
            // all Buddies are result of the single search request - so if the request changes
            //  we need to get rid of all the Buddies...
            [BDFBuddy clearAllFromManagedObjectContext:weakSelf.searchRequest.managedObjectContext];
            //
            // we also need to CANCEL ANY RUNNING SEARCHES
            [((BDFAppDelegate*)[UIApplication sharedApplication].delegate).bdfClient cancelAll];
            //
            [[NSNotificationCenter defaultCenter] addObserver:weakSelf
                                                     selector:@selector(changes:)
                                                         name:NSManagedObjectContextObjectsDidChangeNotification
                                                       object:nil];
            [weakSelf.viewModel updateFromBuddyProfile:weakSelf.searchRequest];
            [weakSelf.tableView reloadData];
            [weakSelf syncViewStateToModel];
        });
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return @"MATCH";
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.viewModel numRows];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BDFBuddyAttributeTableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:[self cellIdentifierAtIndexPath:indexPath]
                                           forIndexPath:indexPath];
    //
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [BDFSettings sharedSettings].cellSelectionColor;
    cell.selectedBackgroundView = selectionColor;
    
    NSUInteger row = indexPath.row;
    cell.name = [self.viewModel nameForRow:row];
    cell.value = [self.viewModel valueForRow:row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // setting color here also takes care of accessory to RHS
    cell.backgroundColor = [BDFSettings sharedSettings].backgroundColor;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // this next line shouldn't be necessary given self.clearsSelectionOnViewWillAppear = YES
    // but IS required in iOS7.0..1
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"SearchAttributesSegue" sender:indexPath];
}


#pragma mark - Navigation

// so this current implementation works technically but sucks UI navigation-wize
// just push in UINavigationController, thus giving a 'back' to the search screen.
//
// then 'Matched' can show the same screen? Sort out later.
- (IBAction)findAction:(UIButton *)sender
{
    [self.masterDetailController setActiveMenuItemNamed:MatchedMenuItemName];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // ensure we diable top level scrolling since not applicable to subsequent screens
    // only this root view
    [self.masterDetailController setScrollingEnabled:NO];
    //
    UIViewController* destinationVC = ((UIViewController*)segue.destinationViewController).topViewController;
    if ([destinationVC isKindOfClass:[BDFGenericListPicker class]])
    {
        NSIndexPath* indexPath = (NSIndexPath*)sender;
        NSString* entityName = [self.viewModel nameForRow:indexPath.row];
        destinationVC.title = entityName;
        //
        BDFGenericListPicker* genericListPickerVC = (BDFGenericListPicker*)destinationVC;
        genericListPickerVC.buddyProfile = self.searchRequest;
        genericListPickerVC.entityName = entityName;
        genericListPickerVC.withIndex = [self.viewModel pickerShouldDisplayIndex:entityName];
        genericListPickerVC.withoutRefresh = [self.viewModel pickerShouldPreventRefresh:entityName];
        genericListPickerVC.singleSelection = genericListPickerVC.withoutRefresh;
    }
}


#pragma mark - Dynamic Cell Size Support

-(NSString*)cellIdentifierAtIndexPath:(NSIndexPath*)indexPath
{
    return @"SearchTableViewCell";
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
    if (cellId)
    {
        UITableViewCell *cell = [self tableView:tableView prototypeForCellIdentifier:cellId];
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

@end
