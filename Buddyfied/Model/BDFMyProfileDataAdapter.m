//
//  BDFMyProfileDataAdapter.m
//  Buddyfied
//
//  Created by Tom Gilbert on 10/07/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFMyProfileDataAdapter.h"
#import "BDFEntityNames.h"
#import "NSManagedObject+Helpers.h"

@interface BDFMyProfileDataAdapter()

@property (nonatomic, strong) NSDictionary* entityForProperty;

@end


@implementation BDFMyProfileDataAdapter

-(instancetype)init
{
    if (self = [super init])
    {
        // mapping between property name and core data entity
        self.entityForProperty = @{@"platform" : PLATFORM_ENTITY,
                                   @"playing" : PLAYING_ENTITY,
                                   @"gameplay" : GAMEPLAY_ENTITY,
                                   @"country" : COUNTRY_ENTITY,
                                   @"skill" : SKILL_ENTITY,
                                   @"years" : YEARS_ENTITY,
                                   @"age" : AGE_ENTITY,
                                   @"voice" : VOICE_ENTITY,
                                   @"time" : TIME_ENTITY,
                                   @"language" : LANGUAGE_ENTITY};
    }
    return self;
}

- (NSString*) entityNameForModelProperty:(NSString*)propertyName
{
    return self.entityForProperty[propertyName];
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
