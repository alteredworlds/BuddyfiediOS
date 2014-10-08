//
//  BDFEntityDataAdapter.m
//  Buddyfied
//
//  Created by Tom Gilbert on 03/07/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFBuddyProfileDataAdapter.h"
#import "BDFEntityNames.h"
#import "NSManagedObject+Helpers.h"

@implementation BDFBuddyProfileDataAdapter

NSArray* flattenProperties;

-(instancetype)init
{
    if (self = [super init])
    {
        self.entityNames = [@[PLATFORM_ENTITY,
                              PLAYING_ENTITY,
                              GAMEPLAY_ENTITY,
                              COUNTRY_ENTITY,
                              LANGUAGE_ENTITY,
                              SKILL_ENTITY,
                              TIME_ENTITY,
                              AGE_ENTITY,
                              VOICE_ENTITY] mutableCopy];
        //
        self.propertyNames = [[NSMutableArray alloc] initWithCapacity:self.entityNames.count];
        //
        // CONVENTION: BDFBuddyProfile properties for entity relationships
        //  are ALL lower-case versions of the entity name
        // e.g. set of Platform => profile.platform
        for (NSString* entityName in self.entityNames)
        {
            [self.propertyNames addObject:[entityName lowercaseString]];
        }
        //
        // by default all properties are to be flattened. can be altered by derived classes
        // always a subset of propertyNames
        self.flattenPropertyNames = [[NSMutableArray alloc] initWithArray:self.propertyNames];
    }
    return self;
}

- (NSString*) entityNameForProperty:(NSString*)propertyName
{
    NSString* retVal = nil;
    NSUInteger idx = [self.propertyNames indexOfObject:propertyName];
    if (NSNotFound != idx)
    {
        retVal = self.entityNames[idx];
    }
    return retVal;
}

- (NSArray*) entitiesForIdList:(NSArray*)idList
                    entityName:(NSString*)entityName
        inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    NSArray* retVal = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.predicate = [NSPredicate predicateWithFormat:@"id IN %@", idList];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)]];
    NSError *error;
    NSArray *matches = [managedObjectContext executeFetchRequest:request error:&error];
    if (!error && matches)
    {
        retVal = matches;
    }
    return matches;
}

@end
