//
//  BDFBuddy+Create.m
//  Buddyfied
//
//  Created by Tom Gilbert on 17/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFBuddy+Create.h"
#import "BDFEntityNames.h"
#import "NSManagedObject+Helpers.h"
#import "BDFBuddyProfileFieldMapper.h"

@implementation BDFBuddy (Create)

- (void) parseProperty:(NSString*)propertyName
     fromBuddyfiedInfo:(NSDictionary*)buddyDictionary
      usingFieldMapper:(BDFBuddyProfileFieldMapper*)fieldMapper
{
    NSString* serverField = [fieldMapper serverFieldForModelProperty:propertyName];
    [BDFBuddy changeStringValue:buddyDictionary[serverField]
                         forKey:propertyName
               forManagedObject:self];
}


+ (BDFBuddy *)buddyWithBuddyfiedInfo:(NSDictionary *)buddyDictionary
                    withDisplayOrder:(NSNumber*)displayOrder
                    usingFieldMapper:(BDFBuddyProfileFieldMapper*)fieldMapper
              inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    BDFBuddy* retVal = nil;
    
    NSString *unique = buddyDictionary[@"user_id"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:BUDDY_ENTITY];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    
    NSError *error;
    NSArray *matches = [managedObjectContext executeFetchRequest:request error:&error];
    if (!matches || error || ([matches count] > 1))
    {   // handle error
    }
    else
    {
        if ([matches count])
        {
            retVal = [matches firstObject];
        }
        else
        {
            retVal = [NSEntityDescription insertNewObjectForEntityForName:BUDDY_ENTITY
                                                   inManagedObjectContext:managedObjectContext];
            retVal.unique = unique;
        }
        [BDFBuddy changeNumberValue:displayOrder
                             forKey:@"displayOrder"
                   forManagedObject:retVal];
        
        [BDFBuddy changeStringValue:[fieldMapper avatarFullImageUrl:buddyDictionary]
                             forKey:@"imageURL"
                   forManagedObject:retVal];
        
        [retVal parseProperty:@"name" fromBuddyfiedInfo:buddyDictionary usingFieldMapper:fieldMapper];
        [retVal parseProperty:@"country" fromBuddyfiedInfo:buddyDictionary usingFieldMapper:fieldMapper];
        [retVal parseProperty:@"gameplay" fromBuddyfiedInfo:buddyDictionary usingFieldMapper:fieldMapper];
        [retVal parseProperty:@"language" fromBuddyfiedInfo:buddyDictionary usingFieldMapper:fieldMapper];
        [retVal parseProperty:@"platform" fromBuddyfiedInfo:buddyDictionary usingFieldMapper:fieldMapper];
        [retVal parseProperty:@"playing" fromBuddyfiedInfo:buddyDictionary usingFieldMapper:fieldMapper];
        [retVal parseProperty:@"skill" fromBuddyfiedInfo:buddyDictionary usingFieldMapper:fieldMapper];
        [retVal parseProperty:@"time" fromBuddyfiedInfo:buddyDictionary usingFieldMapper:fieldMapper];
        [retVal parseProperty:@"years" fromBuddyfiedInfo:buddyDictionary usingFieldMapper:fieldMapper];
        [retVal parseProperty:@"voice" fromBuddyfiedInfo:buddyDictionary usingFieldMapper:fieldMapper];
        [retVal parseProperty:@"comments" fromBuddyfiedInfo:buddyDictionary usingFieldMapper:fieldMapper];
    }
    
    return retVal;
}

+ (void)parseBuddiesFromBuddyfiedResponse:(NSDictionary *)buddyfiedResponse
               inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    id responseData = buddyfiedResponse[@"message"];
    if ([responseData isKindOfClass:[NSArray class]])
    {
        BDFBuddyProfileFieldMapper* fieldMapper = [[BDFBuddyProfileFieldMapper alloc] init];
        NSInteger displayOrder = 0;
        for (NSDictionary *buddy in (NSArray*)responseData)
        {
            [self buddyWithBuddyfiedInfo:buddy
                        withDisplayOrder:[NSNumber numberWithInteger:displayOrder++]
                        usingFieldMapper:fieldMapper
                  inManagedObjectContext:managedObjectContext];
        }
    }
}

@end
