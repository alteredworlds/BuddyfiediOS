//
//  BDFDismissModalViewController.h
//  Buddyfied
//
//  Created by Tom Gilbert on 26/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BDFDismissModalViewControllerDelegate <NSObject>

-(void)dismissModalController:(id)sender animated:(BOOL)animated;

@end
