//
//  BDFConnectivityViewController.m
//  Buddyfied
//
//  Created by Tom Gilbert on 15/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFAboutViewController.h"
#import "BDFSettings.h"
#import "BDFLoginViewController.h"
#import "BDFAppDelegate.h"

@interface BDFAboutViewController () <UIAlertViewDelegate, BDFLoginViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;
@property (weak, nonatomic) IBOutlet UIButton *buddyfiedLinkButton;
@property (weak, nonatomic) IBOutlet UILabel *appVersionLabel;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;

@property (nonatomic) BOOL joinRequested;

@end

static NSString* const LogoutSegue = @"SignoutSegue";

@implementation BDFAboutViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    //
    // Update the UI elements with the saved data
    self.userLabel.text = [BDFSettings sharedSettings].userName;
    //
    self.joinButton.hidden = ![BDFSettings sharedSettings].isGuestUser;
    //
    // Version display built from VERSION and BUILD
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString* version = [NSString stringWithFormat:@"Version %@  build %@",
                         infoDictionary[@"CFBundleShortVersionString"],
                         infoDictionary[@"CFBundleVersion"]];
    self.appVersionLabel.text = version;
}

-(void)enableToggleOnTouch:(BOOL)enable
{
    [super enableToggleOnTouch:enable];
    //
    // we also need to hit the following additional control(s)...
    BOOL userInteractionEnabled = !enable;
    //
    self.signOutButton.userInteractionEnabled = userInteractionEnabled;
    self.buddyfiedLinkButton.userInteractionEnabled = userInteractionEnabled;
}

- (IBAction)signOutAction:(id)sender
{
    NSString* title = [NSString stringWithFormat:@"Sign Out '%@'", [BDFSettings sharedSettings].userName];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:@"Please confirm you want to sign out from Buddyfied."
                                                   delegate:self
                                          cancelButtonTitle:@"Sign Out"
                                          otherButtonTitles:@"Cancel", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (0 == buttonIndex)
    {   //
        // user has confirmed they want to Sign Out
        [self signOut];
    }
}

- (IBAction)buddyfiedLinkAction:(id)sender
{
    NSString* url = [BDFSettings sharedSettings].buddyHelp;
    if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to view Help"
                                                        message:@"Safari may be disabled on this device."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)joinAction:(id)sender
{
    self.joinRequested = YES;
    [self signOut];
}

-(void)signOut
{
    // ensure personal data cleared up first
    [(BDFAppDelegate*)[UIApplication sharedApplication].delegate clearPersonalData];
    //
    [self performSegueWithIdentifier:LogoutSegue sender:self];
}

#pragma warn - BDFLoginViewControllerDelegate

-(void)loginViewControllerDidFinish:(BDFLoginViewController *)loginViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.masterDetailController setActiveMenuItemAtRow:self.masterDetailController.homePage];
}

#pragma warn - Navigation

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:LogoutSegue] &&
        [segue.destinationViewController isKindOfClass:[BDFLoginViewController class]])
    {
        BDFLoginViewController* loginViewController = (BDFLoginViewController*)segue.destinationViewController;
        loginViewController.delegate = self;
        loginViewController.joinRequested = self.joinRequested;
    }
}

@end
