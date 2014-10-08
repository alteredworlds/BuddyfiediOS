//
//  BDFWebViewController.m
//  Buddyfied
//
//  Created by Tom Gilbert on 11/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFDetailTableViewController.h"

@interface BDFDetailTableViewController ()

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecogniser;

- (void)setToggleAction:(SEL)action withTarget:(id)target;

@end


@implementation BDFDetailTableViewController

@synthesize masterDetailController=_masterDetailController;


-(void)setMasterDetailController:(id<BDFMasterDetailController>)masterDetailController
{
    _masterDetailController = masterDetailController;
    [self setToggleAction:@selector(toggleMaster:) withTarget:_masterDetailController];
}

- (void)setToggleAction:(SEL)action withTarget:(id)target
{
    UIBarButtonItem* navButton = self.navigationItem.leftBarButtonItem;
    navButton.action = action;
    navButton.target = target;
}

-(void)enableToggleOnTouch:(BOOL)enable
{
    if (enable)
    {
        if (nil == self.tapGestureRecogniser)
        {
            // Create and initialize a tap gesture
            self.tapGestureRecogniser = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self.masterDetailController
                                         action:@selector(toggleMaster:)];
            
            // Specify that the gesture must be a single tap
            self.tapGestureRecogniser.numberOfTapsRequired = 1;
            
            // Add the tap gesture recognizer to the view
            [self.view addGestureRecognizer:self.tapGestureRecogniser];
            //NSLog(@"ADDED toggleOnTouch gesture recogniser to TableView");
        }
    }
    else
    {
        if (nil != self.tapGestureRecogniser)
        {
            [self.view removeGestureRecognizer:self.tapGestureRecogniser];
            self.tapGestureRecogniser = nil;
            //NSLog(@"REMOVED toggleOnTouch gesture recogniser from TableView");
        }
    }
}

@end
