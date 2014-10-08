//
//  BDFMyProfileViewController.h
//  Buddyfied
//
//  Created by Tom Gilbert on 24/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFDetailTableViewController.h"
#import "BDFDismissModalViewControllerDelegate.h"
#import "BDFMyProfile.h"

@interface BDFEditProfileViewController : BDFDetailTableViewController

@property (nonatomic, strong) BDFMyProfile* profile;
@property (nonatomic, weak) id<BDFDismissModalViewControllerDelegate> delegate;
@property (nonatomic) CGFloat verticalOffset;
@property (nonatomic) CGFloat verticalEdgeInset;

@property (nonatomic) BOOL shownInJoinSequence;

@end
