//
//  BDFJoinBuddyfiedViewControllerTableViewController.h
//  Buddyfied
//
//  Created by Tom Gilbert on 01/07/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDFDismissModalViewControllerDelegate.h"

@interface BDFJoinBuddyfiedTableViewController : UIViewController

@property (nonatomic, weak) id<BDFDismissModalViewControllerDelegate> delegate;

@end
