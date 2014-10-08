//
//  BDFBuddy+Cached.m
//  Buddyfied
//
//  Created by Tom Gilbert on 27/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFBuddy+Helpers.h"
#import "BDFEntityNames.h"


@implementation BDFBuddy (Helpers)


+ (void) clearAllFromManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:BUDDY_ENTITY];
    request.includesPropertyValues = NO;
    //
    NSArray *matches = [managedObjectContext executeFetchRequest:request error:&error];
    if (matches && !error)
    {
        for (BDFBuddy* buddy in matches)
        {
            [managedObjectContext deleteObject:buddy];
        }
    }
}

@end
