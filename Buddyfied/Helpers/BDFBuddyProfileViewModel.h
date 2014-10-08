//
//  BDFBuddyProfileViewModel.h
//  Buddyfied
//
//  Created by Tom Gilbert on 23/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDFBuddyProfileDataAdapter.h"

@class BDFBuddyProfile;
@class BDFBuddy;

@interface BDFBuddyProfileViewModel : NSObject
{
    BDFBuddyProfileDataAdapter* _adapter;
}

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* unique;

@property (nonatomic, strong) NSString* country;
@property (nonatomic, strong) NSString* gameplay;
@property (nonatomic, strong) NSString* language;
@property (nonatomic, strong) NSString* platform;
@property (nonatomic, strong) NSString* playing;
@property (nonatomic, strong) NSString* skill;
@property (nonatomic, strong) NSString* time;
@property (nonatomic, strong) NSString* age;
@property (nonatomic, strong) NSString* voice;

@property (nonatomic, strong) BDFBuddyProfileDataAdapter* adapter;


-(void)updateFromBuddyProfile:(BDFBuddyProfile*)buddyProfile;

-(NSUInteger) numRows;

-(NSString*) nameForRow:(NSUInteger)row;
-(NSString*) valueForRow:(NSUInteger)row;
-(NSString*) valueForName:(NSString*)name;
- (BOOL)pickerShouldDisplayIndex:(NSString*)entityName;
- (BOOL)pickerShouldPreventRefresh:(NSString*)entityName;

// this would be protected
-(NSString*)formattedTextForBuddyProfile:(BDFBuddyProfile*)buddyProfile
                            propertyName:(NSString*)propertyName;

@end
