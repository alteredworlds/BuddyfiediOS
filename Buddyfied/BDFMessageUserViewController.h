//
//  BDFMessageUserViewController.h
//  Buddyfied
//
//  Created by Tom Gilbert on 25/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDFDismissModalViewControllerDelegate.h"

@interface BDFMessageUserViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, weak) id<BDFDismissModalViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userId;

@end
