//
//  BDFLoginViewController.h
//  Buddyfied
//
//  Created by Tom Gilbert on 15/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BDFLoginViewControllerDelegate;

@interface BDFLoginViewController : UIViewController

@property (nonatomic, weak) id <BDFLoginViewControllerDelegate> delegate;
@property (nonatomic) BOOL joinRequested;

@end

@protocol BDFLoginViewControllerDelegate

-(void)loginViewControllerDidFinish:(BDFLoginViewController *)loginViewController;

@end
