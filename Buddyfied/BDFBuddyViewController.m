//
//  BDFBuddyViewController.m
//  Buddyfied
//
//  Created by Tom Gilbert on 24/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFBuddyViewController.h"
#import "BDFBuddy.h"
#import "BDFMessageUserViewController.h"
#import "UIViewController+Helpers.h"
#import "BDFAppDelegate.h"
#import "BDFSettings.h"
#import "BDFPlayerAttribute+Create.h"
#import "BDFEntityNames.h"
#import "UIImageView+Helpers.h"

#import "BDFBuddyViewModel.h"
#import "BDFBuddyAttributeTableViewCell.h"
#import "UIImageView+AFNetworking.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface BDFBuddyViewController () <BDFDismissModalViewControllerDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) NSMutableDictionary *prototypeCells;
@property (strong, nonatomic) BDFBuddyViewModel *viewModel;

@end


@implementation BDFBuddyViewController


-(void) setBuddy:(BDFBuddy*)buddy
{
    _buddy = buddy;
    _viewModel = [[BDFBuddyViewModel alloc] init];
    [_viewModel updateFromBuddy:_buddy];
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    //
    self.clearsSelectionOnViewWillAppear = YES;
    //
    [self registerNibsForBuddyViewModelCells];
    //
    self.userName.text = self.viewModel.name;
    //
    [self.imageView applyBorder:[UIColor whiteColor]];
    //
    // NOTE: thumbnail & full image same in current code, re-download
    // prevented thanks to AFNetworking image cache
    [self.imageView setImageWithURL:[NSURL URLWithString:self.viewModel.imageURL]
                   placeholderImage:self.thumbnail];
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


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)dismissModalController:(id)sender animated:(BOOL)animated
{
    //NSLog(@"About to close Message View");
    [self dismissViewControllerAnimated:animated completion:^{
        ;//NSLog(@"Just closed Message View");
    }];
}

- (IBAction)reportUserAction:(id)sender
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.navigationBar.tintColor = [UIColor orangeColor];
        mailCont.mailComposeDelegate = self;
        
        NSString* buddyReportUserEmail = [BDFSettings sharedSettings].buddyReportUserEmail;
        [mailCont setToRecipients:@[buddyReportUserEmail]];
        [mailCont setSubject:@"Report User"];
        NSString* messageBody = [NSString stringWithFormat:@"Please describe your concerns about user %@.\n\n from %@",
                                 self.viewModel.name,
                                 [BDFSettings sharedSettings].userName];
        [mailCont setMessageBody:messageBody isHTML:NO];
        [self presentViewController:mailCont animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // setting color here also takes care of accessory to RHS
    cell.backgroundColor = [BDFSettings sharedSettings].backgroundColor;
}

#pragma mark - Dynamic Cell Size Support

-(NSString*)cellIdentifierAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row == self.viewModel.commentRow)
        return @"BuddyCommentCell";
    else
        return @"BuddyCell";
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //NSLog(@"About to show modal Message View");
    UIViewController* controller = ((UIViewController*)segue.destinationViewController).topViewController;
    if ([controller isKindOfClass:[BDFMessageUserViewController class]])
    {
        BDFMessageUserViewController* messageUserViewController = (BDFMessageUserViewController*)controller;
        messageUserViewController.userName = self.viewModel.name;
        messageUserViewController.userId = self.viewModel.unique;
        messageUserViewController.delegate = self;
    }
}

@end
