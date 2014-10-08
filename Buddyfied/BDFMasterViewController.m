//
//  BDFMasterViewController.m
//  Buddyfied
//
//  Created by Tom Gilbert on 11/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFMasterViewController.h"
#import "BDFUIConfigurationAvailablity.h"
#import "BDFAppDelegate.h"
#import "BDFMasterMenuItem.h"
#import "BDFSettings.h"

@interface BDFMasterViewController ()

@property (nonatomic, strong) NSIndexPath* activeMenuIndexPath;
@property (nonatomic, strong) NSMutableArray* menu;

@end

@implementation BDFMasterViewController

@synthesize masterDetailController=_masterDetailController;
@synthesize activeMenuIndexPath=_activeMenuIndexPath;

static NSString* const AboutMainMenuItemIcon = @"About";
static NSString* const MatchedMainMenuItemIcon = @"Matched";
static NSString* const ProfileMainMenuItemIcon = @"Profile";
static NSString* const SearchMainMenuItemIcon = @"Search";


- (NSIndexPath*) activeMenuIndexPath
{
    if (!_activeMenuIndexPath)
    {
        NSInteger row = [[BDFSettings sharedSettings].activeMenuIndex integerValue];
        _activeMenuIndexPath = [NSIndexPath indexPathForRow:row inSection:0];

    }
   return _activeMenuIndexPath;
}

-(void)setActiveMenuIndexPath:(NSIndexPath*)activeMenuIndex
{
    _activeMenuIndexPath = activeMenuIndex;
    [BDFSettings sharedSettings].activeMenuIndex = [NSNumber numberWithInteger:activeMenuIndex.row];
}

-(void)setActiveMenuItemNamed:(NSString*)name
{
    // Find the menu item, if it exists
    NSUInteger row = [self.menu indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
    {
        if ([((BDFMasterMenuItem*)obj).name isEqualToString:name])
        {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    if (row != NSNotFound)
    {
        [self setActiveMenuItemAtRow:row];
    }
}

-(void)setActiveMenuItemAtRow:(NSUInteger)row
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self switchActiveMenuItemIndexFrom:self.activeMenuIndexPath
                             toNewIndex:indexPath];
    
}

-(void)switchActiveMenuItemIndexFrom:(NSIndexPath*)activeIndex toNewIndex:(NSIndexPath*)newActiveIndex
{
    // need to ensure previous active row (if any) restored to normal text colour etc
    if (activeIndex && (0 != [activeIndex compare:newActiveIndex]))
    {
        [self unselectActiveMenuItemAtIndex:activeIndex];
    }
    // if this is the first visit to this screen, need to drive selection
    // for subsequent visits the last selected row remains highlighted
    [self.tableView selectRowAtIndexPath:newActiveIndex
                                animated:NO
                          scrollPosition:UITableViewScrollPositionNone];
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:newActiveIndex];
    cell.highlighted = YES;
    cell.selected = YES;
    [self updateTextColorForCellAtIndexPath:newActiveIndex isSelected:YES force:NO];
    
    self.activeMenuIndexPath = newActiveIndex;
    
    BDFMasterMenuItem* menuItem = self.menu[newActiveIndex.row];
    [self.masterDetailController switchToDetail:menuItem.viewControllerIdentifier];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    //
    [self setupBasicConfig];
}

-(void)viewWillAppear:(BOOL)animated
{
    //NSLog(@"MasterViewController: viewWillAppear");
    [super viewWillAppear:animated];
    //[self setActiveMenuItem:self.mainMenu.activeItem];
}

-(void)viewWillDisappear:(BOOL)animated
{
    //NSLog(@"MasterViewController: viewWillDisappear");
    [super viewWillDisappear:animated];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menu.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MasterTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    BDFMasterMenuItem* menuItem = self.menu[indexPath.row];
    cell.textLabel.text = menuItem.name;
    cell.imageView.image = [UIImage imageNamed:menuItem.iconName];
    
    return cell;
}

-(void)unselectActiveMenuItemAtIndex:(NSIndexPath*)indexPath
{
    if (index)
    {
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.highlighted = NO;
        cell.selected = NO;
        [self updateTextColorForCell:cell isSelected:NO force:YES];
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // ensure any previously selected row is unselected - yes this should happen
    // automagically
    if (0 != [self.activeMenuIndexPath compare:indexPath])
    {
        [self unselectActiveMenuItemAtIndex:self.activeMenuIndexPath];
        [self updateTextColorForCellAtIndexPath:indexPath isSelected:YES force:NO];
        self.activeMenuIndexPath = indexPath;
    }
    //
    // dispatch_async not stictly neccessary, but doesn't hurt either
    // we want a smooth switch to alternate menu option, switching in new
    // view but without causing jerk / stutter in the menu transition
    __weak BDFMasterViewController* weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        BDFMasterMenuItem* menuItem = weakSelf.menu[indexPath.row];
        [weakSelf.masterDetailController switchToDetail:menuItem.viewControllerIdentifier];
        [weakSelf.masterDetailController toggleMaster:weakSelf];
    });
}

// when UITableViewCell highlighted, update state to match selected appearance
-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateTextColorForCellAtIndexPath:indexPath isSelected:YES force:NO];
}

// when UITableViewCell UNhighlighted, update state to match UNselected appearance
-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateTextColorForCellAtIndexPath:indexPath isSelected:NO force:NO];
}

// when UITableViewCell DESELECTED revert the text colour back
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateTextColorForCellAtIndexPath:indexPath isSelected:NO force:NO];
}

-(void)updateTextColorForCellAtIndexPath:(NSIndexPath *)indexPath isSelected:(BOOL)isSelected force:(BOOL)force
{
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self updateTextColorForCell:cell isSelected:isSelected force:force];
}

-(void)updateTextColorForCell:(UITableViewCell *)cell isSelected:(BOOL)isSelected force:(BOOL)force
{
    // NOTE that || ensures that pressing on selected row then moving finger off doesn't
    // cause highlight / unhighlight cycle leaving text invisible, white on grey.
    BOOL shouldForceSelected = isSelected || (!force && cell.isSelected);
    cell.textLabel.textColor = shouldForceSelected ? [UIColor blackColor] : [UIColor whiteColor];
}


-(void) setupBasicConfig
{
    self.menu = [[NSMutableArray alloc] init];
    
    [self.menu addObject:[[BDFMasterMenuItem alloc] initWithName:@"Search"
                                        viewControllerIdentifier:@"SearchViewController"
                                                        iconName:SearchMainMenuItemIcon]];
    
    [self.menu addObject:[[BDFMasterMenuItem alloc] initWithName:@"Matched"
                                        viewControllerIdentifier:@"MatchedViewController"
                                                        iconName:MatchedMainMenuItemIcon]];
    
    [self.menu addObject:[[BDFMasterMenuItem alloc] initWithName:@"Profile"
                                        viewControllerIdentifier:@"MyProfileViewController"
                                                        iconName:ProfileMainMenuItemIcon]];
    
    [self.menu addObject:[[BDFMasterMenuItem alloc] initWithName:@"About"
                                        viewControllerIdentifier:@"LogonViewController"
                                                        iconName:AboutMainMenuItemIcon]];
}

@end
