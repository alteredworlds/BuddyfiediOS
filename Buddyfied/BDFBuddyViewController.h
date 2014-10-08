//
//  BDFBuddyViewController.h
//  Buddyfied
//
//  Created by Tom Gilbert on 24/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BDFBuddy;

@interface BDFBuddyViewController : UITableViewController

@property (nonatomic, strong) BDFBuddy *buddy;
@property (nonatomic, strong) UIImage *thumbnail;

@end
