//
//  CoreDataCollectionViewController.m
//
//

#import "CoreDataCollectionViewController.h"

@implementation CoreDataCollectionViewController

#pragma mark - Fetching

- (void)performFetch
{
    if (self.fetchedResultsController)
    {
        if (self.fetchedResultsController.fetchRequest.predicate)
        {
            if (self.debug)
                NSLog(@"[%@ %@] fetching %@ with predicate: %@",
                      NSStringFromClass([self class]),
                      NSStringFromSelector(_cmd),
                      self.fetchedResultsController.fetchRequest.entityName,
                      self.fetchedResultsController.fetchRequest.predicate);
        }
        else
        {
            if (self.debug)
                NSLog(@"[%@ %@] fetching all %@ (i.e., no predicate)",
                      NSStringFromClass([self class]),
                      NSStringFromSelector(_cmd),
                      self.fetchedResultsController.fetchRequest.entityName);
        }
        NSError *error;
        BOOL success = [self.fetchedResultsController performFetch:&error];
        if (!success)
            NSLog(@"[%@ %@] performFetch: failed", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        if (error)
            NSLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]),
                  NSStringFromSelector(_cmd), [error localizedDescription], [error localizedFailureReason]);
    }
    else
    {
        if (self.debug)
            NSLog(@"[%@ %@] no NSFetchedResultsController (yet?)", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }
    [self.collectionView reloadData];
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)newfrc
{
    NSFetchedResultsController *oldfrc = _fetchedResultsController;
    if (newfrc != oldfrc)
    {
        _fetchedResultsController = newfrc;
        newfrc.delegate = self;
        if ((!self.title || [self.title isEqualToString:oldfrc.fetchRequest.entity.name]) &&
            (!self.navigationController || !self.navigationItem.title))
        {
            self.title = newfrc.fetchRequest.entity.name;
        }
        if (newfrc)
        {
            if (self.debug)
                NSLog(@"[%@ %@] %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), oldfrc ? @"updated" : @"set");
            [self performFetch];
        }
        else
        {
            if (self.debug)
                NSLog(@"[%@ %@] reset to nil", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            [self.collectionView reloadData];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = [[self.fetchedResultsController sections] count];
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if ([[self.fetchedResultsController sections] count] > 0)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo =
            [[self.fetchedResultsController sections] objectAtIndex:section];
        rows = [sectionInfo numberOfObjects];
    }
    return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index
{
	return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.fetchedResultsController sectionIndexTitles];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    //[self.collectionView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type
{
//    switch(type)
//    {
//        case NSFetchedResultsChangeInsert:
//            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
//                          withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
//                          withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{		
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
//            [self.collectionView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
//                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
//            [self.collectionView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
//                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
        {
            
//            NSIndexPath* ip = [self.collectionView indexPathForSelectedRow];
//            [self.collectionView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
//                                  withRowAnimation:UITableViewRowAnimationNone];
//            if (0 == [ip compare:indexPath])
//            {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.collectionView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
//                });
//            }
        }
            break;
            
        case NSFetchedResultsChangeMove:
//            [self.collectionView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
//                                  withRowAnimation:UITableViewRowAnimationFade];
//            [self.collectionView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
//                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    //[self.collectionView endUpdates];
}

@end

