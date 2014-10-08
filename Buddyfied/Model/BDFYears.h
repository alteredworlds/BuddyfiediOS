//
//  BDFYears.h
//  Buddyfied
//
//  Created by Tom Gilbert on 10/07/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BDFPlayerAttribute.h"

@class BDFMyProfile;

@interface BDFYears : BDFPlayerAttribute

@property (nonatomic, retain) NSSet *buddyProfile;
@end

@interface BDFYears (CoreDataGeneratedAccessors)

- (void)addBuddyProfileObject:(BDFMyProfile *)value;
- (void)removeBuddyProfileObject:(BDFMyProfile *)value;
- (void)addBuddyProfile:(NSSet *)values;
- (void)removeBuddyProfile:(NSSet *)values;

@end
