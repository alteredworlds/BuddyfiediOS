//
//  BDFGenericListPicker.h
//  Buddyfied
//
//  Created by Tom Gilbert on 19/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "BDFBuddyProfile.h"

@interface BDFGenericListPicker : CoreDataTableViewController

@property (nonatomic, strong) NSString* entityName;
@property (nonatomic, strong) BDFBuddyProfile* buddyProfile;
@property (nonatomic) BOOL withIndex;
@property (nonatomic) BOOL singleSelection;
@property (nonatomic) BOOL withoutRefresh;

@end
