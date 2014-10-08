//
//  BDFLoginViewController.m
//  Buddyfied
//
//  Created by Tom Gilbert on 15/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFLoginViewController.h"
#import "BDFSettings.h"
#import "BDFAppDelegate.h"
#import "UIViewController+Helpers.h"
#import "BDFJoinBuddyfiedTableViewController.h"


@interface BDFLoginViewController () <BDFDismissModalViewControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *guestSignInButton;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;

@end

@implementation BDFLoginViewController


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //
    // Update the UI elements with the saved data
    self.userTextField.text = [BDFSettings sharedSettings].userName;
    self.userTextField.delegate = self;
    //
    self.passwordTextField.text = [BDFSettings sharedSettings].password;
    self.passwordTextField.delegate = self;
    //
    [self enableInputFields:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.joinRequested)
    {
        self.joinRequested = NO;
        [self joinAction:nil];
    }
}

-(BOOL)userAndPasswordFieldsHaveContent
{
    return (self.userTextField.text.length > 0) && (self.passwordTextField.text.length > 0);
}

-(void)enableInputFields:(BOOL)enable
{
    self.signInButton.enabled = enable && [self userAndPasswordFieldsHaveContent];
    self.guestSignInButton.enabled = enable;
    self.forgotPasswordButton.enabled = enable;
    self.joinButton.enabled = enable;
    self.userTextField.enabled = enable;
    self.passwordTextField.enabled = enable;
}

- (void)signInUser:(NSString *)userName withPassword:(NSString *)password
{
    if (![BDFSettings sharedSettings].loggedIn)
    {   // LOGIN ATTEMPT
        [self enableInputFields:NO];
        BDFLoginViewController __weak *weakSelf = self;
        BDFAppDelegate __weak *weakAppDelegate = (BDFAppDelegate*)[UIApplication sharedApplication].delegate;
        [weakAppDelegate.bdfClient verifyUser:userName
                      withPassword:password
                   completionBlock:^(id result, NSError *error) {
                       if (error)
                       {
                           NSLog(@"FAILURE verifyUser %@", error);
                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign In Failed"
                                                                           message:error.localizedDescription
                                                                          delegate:weakSelf
                                                                 cancelButtonTitle:@"OK"
                                                                 otherButtonTitles:nil];
                           [alert show];
                       }
                       else
                       {
                           // save the new username and password
                           [BDFSettings sharedSettings].userName = userName;
                           [BDFSettings sharedSettings].password = password;
                           // how to get user_id from result?
                           [BDFSettings sharedSettings].userId = [NSString stringWithFormat:@"%@", result[@"user_id"]];
                           // update logged in saved status
                           [BDFSettings sharedSettings].loggedIn = YES;
                           //
                           // we may need to load static data if (& when) data store just created
                           [weakAppDelegate initDocumentIfRequired];
                           [weakSelf close];
                       }
                   }
         ];
    }
}

- (IBAction)signInAction:(UIButton *)sender
{
    // LOGIN ATTEMPT using data from UI
    [self signInUser:self.userTextField.text
        withPassword:self.passwordTextField.text];
}

- (IBAction)guestSignInAction:(id)sender
{
    // LOGIN ATTEMPT using guest login
    [self signInUser:[BDFSettings sharedSettings].buddyGuest
        withPassword:[BDFSettings sharedSettings].buddyGuestPassword];
}

- (IBAction)joinAction:(UIButton *)sender
{
    // we may need to load static data if (& when) data store just created
    [(BDFAppDelegate*)[UIApplication sharedApplication].delegate initDocumentIfRequired];
    //
    [self performSegueWithIdentifier:@"JoinSegue" sender:self];
}

-(void)close
{
    if (self.delegate)
    {
        [self.delegate loginViewControllerDidFinish:self];
    }
    else
    {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)forgotPasswordAction:(UIButton *)sender
{
    NSString* url = [BDFSettings sharedSettings].buddyLostPassword;
    if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to reset password"
                                                        message:@"Safari may be disabled on this device."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self enableInputFields:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)textFieldChanged:(UITextField*)sender
{   // although clumsy, the idea is that the textFieldChanged event can never be fired
    // when a login attempt is in progress, because the text fields are disabled
    // during this login attempt.
    self.signInButton.enabled = [self userAndPasswordFieldsHaveContent];
}

-(void)dismissModalController:(id)sender animated:(BOOL)animated
{
    [(BDFAppDelegate*)[UIApplication sharedApplication].delegate clearPersonalData];
    [self dismissViewControllerAnimated:animated completion:nil];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //NSLog(@"About to show modal Message View");
    UIViewController* controller = ((UIViewController*)segue.destinationViewController).topViewController;
    if ([controller isKindOfClass:[BDFJoinBuddyfiedTableViewController class]])
    {
        BDFJoinBuddyfiedTableViewController* messageUserViewController = (BDFJoinBuddyfiedTableViewController*)controller;
        messageUserViewController.delegate = self;
    }
}

- (IBAction)unwindToLogin:(UIStoryboardSegue *)unwindSegue
{
}

@end
