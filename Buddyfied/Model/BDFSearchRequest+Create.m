//
//  BDFSearchRequest+Create.m
//  Buddyfied
//
//  Created by Tom Gilbert on 20/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFSearchRequest+Create.h"
#import "BDFEntityNames.h"


@implementation BDFSearchRequest (Create)

+ (BDFSearchRequest*) searchRequestWithName:(NSString*)name
                     inManagedObjectContext:(NSManagedObjectContext*)context
{
    BDFSearchRequest* retVal = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:SearchRequestEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1))
    {
        // handle error
    }
    else if ([matches count])
    {
        retVal = [matches firstObject];
    }
    else
    {
        retVal = [NSEntityDescription insertNewObjectForEntityForName:SearchRequestEntityName
                                               inManagedObjectContext:context];
        retVal.unique = [[NSUUID UUID] UUIDString];
    }
    if (![retVal.name isEqualToString:name])
        retVal.name = name;

    
    return retVal;
}

@end
