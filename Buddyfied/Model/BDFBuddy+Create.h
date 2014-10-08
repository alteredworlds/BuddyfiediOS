//
//  BDFBuddy+Create.h
//  Buddyfied
//
//  Created by Tom Gilbert on 17/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFBuddy.h"

@interface BDFBuddy (Create)

+ (void)parseBuddiesFromBuddyfiedResponse:(NSDictionary *)buddyfiedResponse
                   inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

@end
