//
//  BDFPlayerAttribute+Create.m
//  Buddyfied
//
//  Created by Tom Gilbert on 07/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFPlayerAttribute+Create.h"
#import "BDFPlayerAttribute+Calculated.h"

@implementation BDFPlayerAttribute (Create)

+ (instancetype) attributeForEntity:(NSString*)entityName
                             withId:(NSString*)unique
                            andName:(NSString*)name
             inManagedObjectContext:(NSManagedObjectContext*)context
{
    return [BDFPlayerAttribute attributeForEntity:entityName
                                           withId:unique
                                          andName:name
                           inManagedObjectContext:context
                                   usingPredicate:nil];
}

+ (instancetype) attributeForEntity:(NSString*)entityName
                             withId:(NSString*)unique
                            andName:(NSString*)name
             inManagedObjectContext:(NSManagedObjectContext*)context
                     usingPredicate:(NSPredicate*)predicate

{
    BDFPlayerAttribute* retVal = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.fetchLimit = 1;
    if (predicate)
    {
        NSDictionary *variables = @{ @"id" : unique };
        request.predicate = [predicate predicateWithSubstitutionVariables:variables];
    }
    else
    {
        request.predicate = [NSPredicate predicateWithFormat:@"id = %@", unique];
    }
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error)
    {
        // handle error
    }
    else
    {
        if ([matches count])
        {
            retVal = [matches firstObject];
        }
        else
        {
            retVal = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                   inManagedObjectContext:context];
            retVal.id = unique;
        }
        if (![retVal.name isEqualToString:name])
        {
            retVal.name = name;
            retVal.sectionName = [retVal sectionNameForName];
        }
    }
    
    return retVal;
}


+ (void) loadEntitiesNamed:(NSString*)entityName
            fromDictionary:(NSDictionary*)dictionary
    inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
              removeExisting:(BOOL)removeExisting;

{
    NSMutableArray* existingItems = nil;    
    if (removeExisting)
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        request.includesPropertyValues = NO;
        //
        NSError *error;
        NSArray *matches = [managedObjectContext executeFetchRequest:request error:&error];
        if (matches && !error)
            existingItems = [matches mutableCopy];
    }

    NSUInteger      itemCount = 0;
    NSUInteger      removedCount = 0;
    NSString*       predicateString = [NSString stringWithFormat:@"id == $id"];
    NSPredicate*    predicate = [NSPredicate predicateWithFormat:predicateString];
    for (id item in dictionary)
    {
        NSString* unique = [item[@"id"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString* name = [item[@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        BDFPlayerAttribute* playerAttribute = [BDFPlayerAttribute attributeForEntity:entityName
                                                                              withId:unique
                                                                             andName:name
                                                              inManagedObjectContext:managedObjectContext
                                                                      usingPredicate:predicate];
        [existingItems removeObject:playerAttribute];
        itemCount++;
    }
    if (removeExisting && existingItems.count)
    {
        for (id item in existingItems)
        {
            [managedObjectContext deleteObject:item];
            removedCount++;
        }
        [existingItems removeAllObjects];
    }
    NSLog(@"%@ : updated %lu  deleted %lu", entityName, (unsigned long)itemCount, (unsigned long)removedCount);
}

@end
