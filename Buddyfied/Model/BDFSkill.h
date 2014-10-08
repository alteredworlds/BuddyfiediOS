//
//  BDFSkill.h
//  Buddyfied
//
//  Created by Tom Gilbert on 10/07/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BDFPlayerAttribute.h"

@class BDFBuddyProfile;

@interface BDFSkill : BDFPlayerAttribute

@property (nonatomic, retain) NSSet *buddyProfile;
@end

@interface BDFSkill (CoreDataGeneratedAccessors)

- (void)addBuddyProfileObject:(BDFBuddyProfile *)value;
- (void)removeBuddyProfileObject:(BDFBuddyProfile *)value;
- (void)addBuddyProfile:(NSSet *)values;
- (void)removeBuddyProfile:(NSSet *)values;

@end
