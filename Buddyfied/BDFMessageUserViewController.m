//
//  BDFMessageUserViewController.m
//  Buddyfied
//
//  Created by Tom Gilbert on 25/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFMessageUserViewController.h"
#import "BDFMasterDetailController.h"
#import "BDFAppDelegate.h"
#import "BDFSettings.h"

@interface BDFMessageUserViewController ()
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendBarButtonItem;

@property (weak, nonatomic) UIResponder* activeInput;

@end

@implementation BDFMessageUserViewController

static NSString* const DoneButtonTitle = @"Done";
static NSString* const SendButtonTitle = @"Send";


-(void)viewDidLoad
{
    [super viewDidLoad];
    self.subjectTextField.delegate = self;
    self.messageTextView.delegate = self;
    self.userNameLabel.text = self.userName;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self registerForKeyboardNotifications];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}

- (IBAction)cancelAction:(id)sender
{
    [self.delegate dismissModalController:self animated:YES];
}

- (IBAction)sendAction:(UIBarButtonItem *)sender
{
    if ([sender.title isEqualToString:DoneButtonTitle])
    {
        [self.activeInput resignFirstResponder];
    }
    else
    {
        if ([BDFSettings sharedSettings].isGuestUser)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Guest User"
                                                            message:@"Please register with Buddified to message users!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            self.sendBarButtonItem.enabled = NO;
            BDFMessageUserViewController* __weak weakSelf = self;
            BDFAppDelegate* appDelegate = (BDFAppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate.bdfClient sendMessage:[BDFSettings sharedSettings].userName
                                  withPassword:[BDFSettings sharedSettings].password
                                    recipients:self.userId
                                       subject:self.subjectTextField.text
                                          body:self.messageTextView.text
                               completionBlock:^(id result, NSError *error) {
                                   if (error)
                                   {
                                       NSLog(@"FAILURE sendMessage %@", error);
                                       weakSelf.sendBarButtonItem.enabled = YES;
                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Send Message Failed"
                                                                                       message:error.localizedDescription
                                                                                      delegate:nil
                                                                             cancelButtonTitle:@"OK"
                                                                             otherButtonTitles:nil];
                                       [alert show];
                                   }
                                   else
                                   {
                                       [weakSelf.delegate dismissModalController:weakSelf animated:YES];
                                   }
                               }
             ];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.sendBarButtonItem.title = DoneButtonTitle;
    self.activeInput = textField;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.sendBarButtonItem.title = SendButtonTitle;
    self.activeInput = nil;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    self.sendBarButtonItem.title = DoneButtonTitle;
    self.activeInput = textView;
}

-(void)textViewDidEndEditing:(UITextView *)textField
{
    self.sendBarButtonItem.title = SendButtonTitle;
    self.activeInput = nil;
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.messageTextView.contentInset = contentInsets;
    self.messageTextView.scrollIndicatorInsets = contentInsets;
    
    [self.messageTextView scrollRangeToVisible:self.messageTextView.selectedRange];
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.messageTextView.contentInset = contentInsets;
    self.messageTextView.scrollIndicatorInsets = contentInsets;
}

@end
