//
//  BDFJoinBuddyfiedViewControllerTableViewController.m
//  Buddyfied
//
//  Created by Tom Gilbert on 01/07/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFJoinBuddyfiedTableViewController.h"
#import "BDFError.h"
#import "BDFSettings.h"
#import "BDFAppDelegate.h"
#import "BDFEditProfileViewController.h"
#import "UIViewController+Helpers.h"

@interface BDFJoinBuddyfiedTableViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *verifyPasswordTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextBarButtonItem;

@property (nonatomic) BOOL cancelled;

@end

@implementation BDFJoinBuddyfiedTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.userTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.verifyPasswordTextField.delegate = self;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    [self updateButtonState];
}

#pragma mark - Button Actions
- (IBAction)cancelAction:(id)sender
{
    self.cancelled = YES;
    [self cleanup];
    [self.delegate dismissModalController:self animated:YES];
}

- (IBAction)nextAction:(id)sender
{
    if ([self validateUserInput])
    {
        [self performSegueWithIdentifier:@"CollectProfileInfoSegue" sender:self];
    }
}

-(void)cleanup
{
    // cleanup any partially built profile
    [(BDFAppDelegate*)[UIApplication sharedApplication].delegate clearPersonalData];
}

-(void)updateButtonState
{
    self.nextBarButtonItem.enabled = [self validateAllFieldsIndividually];
}


-(BOOL)validateUserInput
{
    BOOL retVal = [self validateAllFieldsIndividually];
    if (retVal)
    {
        retVal = [self.passwordTextField.text isEqualToString:self.verifyPasswordTextField.text];
        if (!retVal)
        {
            // clear the passwords that were incorrectly entered
            self.passwordTextField.text = @"";
            self.verifyPasswordTextField.text = @"";
            [self.passwordTextField becomeFirstResponder];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Passwords don't match"
                                                            message:@"Please enter your password twice"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    return retVal;
}


-(BOOL)validateAllFieldsIndividually
{
    return
    [self validateTextField:self.userTextField error:nil] &&
    [self validateTextField:self.emailTextField error:nil] &&
    [self validateTextField:self.passwordTextField error:nil] &&
    [self validateTextField:self.verifyPasswordTextField error:nil];
}


#pragma mark - UITextFieldDelegate

// each time the contents of a field changes due to user interaction
// run the validation routine to see if the 'Next' button should
// be enabled.
//
- (IBAction)textFieldEditingChanged:(UITextField *)sender
{
    [self updateButtonState];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    BOOL retVal = YES;
    //
    // we don't want to flag an error when leaving an empty field, placeholder text
    // is sufficient
    if (!self.cancelled && (textField.text.length > 0))
    {
        NSError* error;
        retVal = [self validateTextField:textField error:&error];
        if (retVal)
        {
            [self updateButtonState];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid"
                                                            message:error?error.localizedDescription:@""
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    return retVal;
}

-(BOOL)validateTextField:(UITextField *)textField error:(NSError**)error
{
    BOOL retVal = NO;
    if (textField == self.userTextField)
    {
        retVal = textField.text.length >= 4;
        if (!retVal && error)
        {
            *error = [NSError errorWithDomain:BDFErrorDomain
                                         code:BDFUsernameTooShortError
                                     userInfo:@{NSLocalizedDescriptionKey: @"Username must be at least 4 characters"}];
        }
    }
    else if (textField == self.emailTextField)
    {
        NSError* detectorError;
        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                                   error:&detectorError];
        NSArray* matches = [detector matchesInString:textField.text
                                             options:kNilOptions
                                               range:NSMakeRange(0, [textField.text length])];
        for (NSTextCheckingResult *match in matches)
        {
            if([match.URL.absoluteString rangeOfString:@"mailto:"].location != NSNotFound)
            {
                retVal = YES;
                break;
            }
        };
        if (!retVal && error)
        {
            *error = [NSError errorWithDomain:BDFErrorDomain
                                         code:BDFUsernameTooShortError
                                     userInfo:@{NSLocalizedDescriptionKey: @"Please enter a valid email address"}];
        }
    }
    else if ((textField == self.passwordTextField) || (textField = self.verifyPasswordTextField))
    {
        retVal = textField.text.length >= 6;
        if (!retVal && error)
        {
            *error = [NSError errorWithDomain:BDFErrorDomain
                                         code:BDFUsernameTooShortError
                                     userInfo:@{NSLocalizedDescriptionKey: @"Password must be at least 6 characters"}];
        }
    }
    return retVal;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController* controller = ((UIViewController*)segue.destinationViewController).topViewController;
    if ([controller isKindOfClass:[BDFEditProfileViewController class]])
    {
        BDFEditProfileViewController* editVC=(BDFEditProfileViewController*)controller;
        editVC.profile = ((BDFAppDelegate*)[UIApplication sharedApplication].delegate).profile;
        editVC.profile.name = self.userTextField.text;
        editVC.shownInJoinSequence = YES;
        //
        [BDFSettings sharedSettings].userName = self.userTextField.text;
        [BDFSettings sharedSettings].password = self.passwordTextField.text;
        [BDFSettings sharedSettings].email = self.emailTextField.text;
    }
}


@end
