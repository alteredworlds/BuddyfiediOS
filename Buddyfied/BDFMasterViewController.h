//
//  BDFMasterViewController.h
//  Buddyfied
//
//  Created by Tom Gilbert on 11/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDFHasMasterDetailController.h"

@interface BDFMasterViewController : UITableViewController <BDFHasMasterDetailController>

-(void)setActiveMenuItemNamed:(NSString*)name;
-(void)setActiveMenuItemAtRow:(NSUInteger)row;

@end
