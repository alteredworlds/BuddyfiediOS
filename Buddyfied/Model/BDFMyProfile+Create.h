//
//  BDFMyProfile+Create.h
//  Buddyfied
//
//  Created by Tom Gilbert on 25/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFMyProfile.h"

extern const NSArray* BDFBuddyProfileViewModel_FlattenProperties;

@interface BDFMyProfile (Create)

+ (BDFMyProfile *)myProfileFromBuddyfiedInfo:(NSDictionary *)buddyDictionary
                      inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

@end
