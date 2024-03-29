//
//  BDFDetailCollectionViewController.m
//  Buddyfied
//
//  Created by Tom Gilbert on 24/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFDetailCollectionViewController.h"

@interface BDFDetailCollectionViewController ()

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecogniser;

- (void)setToggleAction:(SEL)action withTarget:(id)target;

@end

@implementation BDFDetailCollectionViewController

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
            
            // now disable the collectionView from scrolling etc
            self.collectionView.userInteractionEnabled =  NO;
            //NSLog(@"ADDED toggleOnTouch gesture recogniser to CollectionView");
        }
    }
    else
    {
        if (nil != self.tapGestureRecogniser)
        {
            [self.view removeGestureRecognizer:self.tapGestureRecogniser];
            self.tapGestureRecogniser = nil;
            //
            // re-enable user interaction for collectionView
            self.collectionView.userInteractionEnabled =  YES;
            //NSLog(@"REMOVED toggleOnTouch gesture recogniser from CollectionView");
        }
    }
}

@end
