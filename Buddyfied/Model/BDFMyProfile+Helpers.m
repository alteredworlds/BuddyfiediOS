//
//  BDFMyProfile+Helpers.m
//  Buddyfied
//
//  Created by Tom Gilbert on 27/05/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFMyProfile+Helpers.h"
#import "BDFEntityNames.h"

@implementation BDFMyProfile (Helpers)

+ (void) clearAllFromManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:MYPROFILE_ENTITY];
    request.includesPropertyValues = NO;
    //
    NSArray *matches = [managedObjectContext executeFetchRequest:request error:&error];
    if (matches && !error)
    {
        for (NSManagedObject* match in matches)
        {
            [managedObjectContext deleteObject:match];
        }
    }
}

@end
