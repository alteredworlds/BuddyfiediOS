//
//  BDFBuddyViewModel.h
//  Buddyfied
//
//  Created by Tom Gilbert on 24/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFBuddyProfileViewModel.h"

@class BDFFlatBuddyProfile;

@interface BDFBuddyViewModel : BDFBuddyProfileViewModel

@property (nonatomic, strong) NSString * imageURL;
@property (nonatomic, strong) NSString * comments;
@property (nonatomic, readonly) NSUInteger commentRow;

-(void)updateFromBuddy:(BDFFlatBuddyProfile*)buddy;

@end
