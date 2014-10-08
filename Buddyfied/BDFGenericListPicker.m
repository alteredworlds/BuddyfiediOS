//
//  BDFGenericListPicker.m
//  Buddyfied
//
//  Created by Tom Gilbert on 19/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFGenericListPicker.h"
#import "BDFStaticDataManger.h"
#import "BDFPlayerAttribute+Calculated.h"
#import "BDFAppDelegate.h"
#import "BDFSettings.h"

@interface BDFGenericListPicker ()

@property (weak, nonatomic, readonly) BDFAppDelegate *appDelegate;
@property (nonatomic) BOOL filter;
@property (nonatomic, strong) NSString* searchText;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end


@implementation BDFGenericListPicker

static NSString* const  BuddyProfilePropertyName = @"buddyProfile";


-(BDFAppDelegate *)appDelegate
{
    return (BDFAppDelegate*)[UIApplication sharedApplication].delegate;
}

-(NSString*)sectionKeyPathName
{
    return self.withIndex ? @"sectionName" : nil;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    //
    // what is the default value for a BOOL property?
    self.filter = NO;
    //
    self.fetchedResultsController = [self filteredFetchedResultsController];
    //
    if (!self.withoutRefresh)
    {
        self.refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl.tintColor = [UIColor orangeColor];
        // need to explicitly set the background colour here
        self.refreshControl.backgroundColor = [BDFSettings sharedSettings].backgroundColor;
        [self.refreshControl addTarget:self action:@selector(refreshControlAction)
                      forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:self.refreshControl];
    }
    // do we need to hide the search bar?
    if (!self.withIndex)
    {
        self.tableView.tableHeaderView.frame = CGRectMake(self.tableView.tableHeaderView.frame.origin.x,
                                                          self.tableView.tableHeaderView.frame.origin.y,
                                                          self.tableView.tableHeaderView.frame.size.width, 0.0);
        // following call is necessary to force an update
        self.tableView.tableHeaderView = self.tableView.tableHeaderView;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self shouldTryAutoRefresh])
    {
        // no rows - try auto-load
        [self.refreshControl beginRefreshing];
        CGPoint newOffset = CGPointMake(0, -[self.tableView contentInset].top);
        [self.tableView setContentOffset:newOffset animated:YES];
        [self refreshControlAction];
    }
}

-(BOOL)shouldTryAutoRefresh
{
    return  !self.withoutRefresh &&
            (0 == [self tableView:self.tableView numberOfRowsInSection:0]) &&
            ![[BDFStaticDataManger shared] isRequestInProgressForEntityNamed:self.entityName];
}

-(NSFetchedResultsController*) filteredFetchedResultsController
{
    NSFetchedResultsController* retVal = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
    //
    // FILTERING results...
    NSMutableArray* subPredicates = [[NSMutableArray alloc] init];
    if (self.filter)
    {   // NOTE that dynamic property names require %K
        // %@ for object values in predicates so surrounded by quotes
        [subPredicates addObject:[NSPredicate predicateWithFormat:@"ANY %K.name = %@",
                                  BuddyProfilePropertyName,
                                  self.buddyProfile.name]];
    }
    if (self.searchText.length)
    {
        [subPredicates addObject:[NSPredicate predicateWithFormat:@"name contains[cd] %@", self.searchText]];
    }
    if (subPredicates.count)
    {
        request.predicate = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:subPredicates];
    }
    //
    // SORTING results...
    BOOL indexEnabled = self.withIndex && !subPredicates.count;
    if (indexEnabled)
    {
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sectionName"
                                                                  ascending:YES
                                                                   selector:@selector(localizedCompare:)],
                                    [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                  ascending:YES
                                                                   selector:@selector(localizedCompare:)]];
    }
    else
    {
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                  ascending:YES
                                                                   selector:@selector(localizedCompare:)]];
        
    }
    
    retVal = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                 managedObjectContext:self.buddyProfile.managedObjectContext
                                                   sectionNameKeyPath:indexEnabled ? @"sectionName" : nil
                                                            cacheName:nil];
    return retVal;
}


- (void)refreshControlAction
{
    // The user just pulled down the list - try & start loading data.
    BDFGenericListPicker __weak *weakSelf = self;
    [[BDFStaticDataManger shared] loadStaticForEntityNamed:self.entityName
                                    inManagedObjectContext:self.appDelegate.managedObjectContext
                                            removeExisting:YES
                                           completionBlock:^(NSString *results, NSError *error) {
                                               [weakSelf.refreshControl endRefreshing];
                                               if (error)
                                               {                                                   
                                                   NSString* title = [NSString stringWithFormat:@"Failed to load %@", weakSelf.entityName];
                                                   NSLog(@"%@ %@", title, error);
                                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                                                   message:error.localizedDescription
                                                                                                  delegate:nil
                                                                                         cancelButtonTitle:@"OK"
                                                                                         otherButtonTitles:nil];
                                                   [alert show];
                                               }
                                           }];
}

- (IBAction)filterAction:(UIBarButtonItem *)sender
{
    self.filter = !self.filter;
    self.fetchedResultsController = [self filteredFetchedResultsController];
}

#pragma mark - UISearchDisplayDelegate

// called when the table is created destroyed, shown or hidden. configure as necessary.
- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    tableView.backgroundColor = [BDFSettings sharedSettings].backgroundColor;
    tableView.bounces = NO;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    self.searchText = searchString;
    self.fetchedResultsController = [self filteredFetchedResultsController];
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
{
    self.searchText = nil;
    self.fetchedResultsController = [self filteredFetchedResultsController];
}


#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"GenericListPickerTVC"
                                                            forIndexPath:indexPath];
    
    NSManagedObject* obj = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [obj valueForKey:@"name"];
    
    BOOL cellRepresentsSelectedAttribute = [self isPartOfBuddyProfile:obj];
    cell.accessoryType = cellRepresentsSelectedAttribute ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    //
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [BDFSettings sharedSettings].cellSelectionColor;
    cell.selectedBackgroundView = selectionColor;

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // setting color here also takes care of accessory to RHS
    cell.backgroundColor = [BDFSettings sharedSettings].backgroundColor;
}

-(BOOL)isPartOfBuddyProfile:(NSManagedObject*)obj
{
    BOOL retVal = NO;
    id buddyProfiles = [obj valueForKey: BuddyProfilePropertyName];
    if ([buddyProfiles isKindOfClass:[NSSet class]])
    {
        NSSet* buddySet = (NSSet*)buddyProfiles;
        retVal = (buddySet.count > 0) && [buddySet containsObject:self.buddyProfile];
    }
    return retVal;
}

-(void)addBuddyProfileObject:(NSManagedObject*)obj
{
    NSMutableSet* mutableSet = [obj mutableSetValueForKey:BuddyProfilePropertyName];
    if (![mutableSet containsObject:self.buddyProfile])
    {
        [mutableSet addObject:self.buddyProfile];
        [self.appDelegate.uiManagedDocument updateChangeCount:UIDocumentChangeDone];
    }
}

-(void)removeBuddyProfileObject:(NSManagedObject*)obj
{
    NSMutableSet* mutableSet = [obj mutableSetValueForKey:BuddyProfilePropertyName];
    if ([mutableSet containsObject:self.buddyProfile])
    {
        [mutableSet removeObject:self.buddyProfile];
        [self.appDelegate.uiManagedDocument updateChangeCount:UIDocumentChangeDone];
    }
}

-(void) removeLastCheckedIfRequired:(NSManagedObject*)newCheckedObject
{
    if (self.singleSelection)
    {
        int idx=0;
        NSManagedObject* checkedObject = nil;
        NSArray* fetchedObjects = self.fetchedResultsController.fetchedObjects;
        for (idx=0; idx < fetchedObjects.count; idx++)
        {
            NSManagedObject* nextObjectToTest = fetchedObjects[idx];
            if ([self isPartOfBuddyProfile:nextObjectToTest])
            {
                checkedObject = nextObjectToTest;
                break;
            }
        }
        if (checkedObject && !(checkedObject == newCheckedObject))
        {
            [self removeBuddyProfileObject:checkedObject];
            NSIndexPath* checkedObjectIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[checkedObjectIndexPath]
                                  withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject* obj = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self removeLastCheckedIfRequired:obj];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if (UITableViewCellAccessoryNone == cell.accessoryType)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self addBuddyProfileObject:obj];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self removeBuddyProfileObject:obj];
    }
}

@end
