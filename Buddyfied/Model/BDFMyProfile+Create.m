//
//  BDFMyProfile+Create.m
//  Buddyfied
//
//  Created by Tom Gilbert on 25/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFMyProfile+Create.h"
#import "BDFEntityNames.h"
#import "NSManagedObject+Helpers.h"
#import "BDFBuddyProfileDataAdapter.h"

#import "BDFBuddyProfileFieldMapper.h"
#import "BDFMyProfileDataAdapter.h"

@implementation BDFMyProfile (Create)

+ (BDFMyProfile *)myProfileFromBuddyfiedInfo:(NSDictionary *)buddyDictionary
                      inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    BDFMyProfile* retVal = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:MYPROFILE_ENTITY];
    request.fetchLimit = 1;
    
    NSError *error;
    NSArray *matches = [managedObjectContext executeFetchRequest:request error:&error];
    if (error)
    {
        NSLog(@"ERROR: failed to fetch %@ because %@", MYPROFILE_ENTITY, error);
    }
    else
    {
        if ([matches count])
        {
            retVal = [matches firstObject];
        }
        else
        {
            retVal = [NSEntityDescription insertNewObjectForEntityForName:MYPROFILE_ENTITY
                                                   inManagedObjectContext:managedObjectContext];
        }
        BDFBuddyProfileFieldMapper* fieldMapper = [[BDFBuddyProfileFieldMapper alloc] init];
        BDFMyProfileDataAdapter* dataAdapter = [[BDFMyProfileDataAdapter alloc] init];
        [retVal updateFromServerProfile:buddyDictionary
                       usingFieldMapper:fieldMapper
                         andDataAdapter:dataAdapter
               withManagedObjectContext:managedObjectContext];
    }
    
    return retVal;
}


-(void)updateFromServerProfile:(NSDictionary*)profile
              usingFieldMapper:(BDFBuddyProfileFieldMapper*)fieldMapper
                andDataAdapter:(BDFMyProfileDataAdapter*)adapter
      withManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    [BDFMyProfile changeStringValue:profile[@"display_name"] forKey:@"name" forManagedObject:self];
    [BDFMyProfile changeStringValue:profile[@"user_login"] forKey:@"unique" forManagedObject:self];
    [BDFMyProfile changeStringValue:[fieldMapper avatarFullImageUrl:profile] forKey:@"imageURL" forManagedObject:self];
    
    NSMutableArray* fieldsIncluded = [[NSMutableArray alloc] init];
    NSArray* profileGroups = profile[@"profile_groups"];
    for (NSDictionary* group in profileGroups)
    {
        NSString* groupLabel = group[@"label"];
        if ([groupLabel isEqualToString:@"Your games profile"] ||
            [groupLabel isEqualToString:@"Extra profile settings"])
        {
            for (NSDictionary* singleProperty in group[@"fields"])
            {
                NSString* serverId = singleProperty[@"id"];
                NSString* propertyName = [fieldMapper modelPropertyForServerId:serverId];
                if (propertyName)
                {   // local model handles this server supplied data
                    //
                    NSString* strValue = singleProperty[@"value"];
                    NSString* entityName = [adapter entityNameForModelProperty:propertyName];
                    if (!entityName)
                    {   // this property does NOT represent an entity relationship
                        [BDFMyProfile changeStringValue:strValue forKey:propertyName forManagedObject:self];
                        [fieldsIncluded addObject:propertyName];
                    }
                    else
                    {   // these properties consist of NSSet* entities
                        // make sure 1, 2, 3, 4 is treated as 1,2,3,4
                        strValue = [[strValue componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                         componentsJoinedByString:@""];
                        NSArray*  idList = [strValue componentsSeparatedByString:@","];
                        NSArray* matches = [adapter entitiesForIdList:idList
                                                           entityName:entityName
                                               inManagedObjectContext:managedObjectContext];
                        if (matches && matches.count)
                        {
                            NSSet* entitySet = [NSSet setWithArray:matches];
                            [self setValue:entitySet forKey:propertyName];
                            [fieldsIncluded addObject:propertyName];
                        }
                    }
                }
            }
        }
    }
    // now see if any fields were not included in the update, which means they should be
    // cleared out. This is not a partial update, it represents the full profile information
    // held by the server and the client must not hold anything more than it has been sent.
    [self clearNSSetPropertyIfNotIncluded:@"age" inArray:fieldsIncluded];
    [self clearNSSetPropertyIfNotIncluded:@"country" inArray:fieldsIncluded];
    [self clearNSSetPropertyIfNotIncluded:@"gameplay" inArray:fieldsIncluded];
    [self clearNSSetPropertyIfNotIncluded:@"language" inArray:fieldsIncluded];
    [self clearNSSetPropertyIfNotIncluded:@"platform" inArray:fieldsIncluded];
    [self clearNSSetPropertyIfNotIncluded:@"playing" inArray:fieldsIncluded];
    [self clearNSSetPropertyIfNotIncluded:@"skill" inArray:fieldsIncluded];
    [self clearNSSetPropertyIfNotIncluded:@"time" inArray:fieldsIncluded];
    [self clearNSSetPropertyIfNotIncluded:@"voice" inArray:fieldsIncluded];
    [self clearStringPropertyIfNotIncluded:@"comments" inArray:fieldsIncluded];
    [self clearNSSetPropertyIfNotIncluded:@"years" inArray:fieldsIncluded];
}

// this is no longer necessary, but is a very handy utlity function to keep around
-(NSString*)plainTextFromHtml:(NSString*)htmlString
{
    NSAttributedString* attribStr =
    [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding]
                                     options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                               NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]}
                          documentAttributes:nil error:nil];
    // we don't care about leading or trailing whitespace or return characters, so remove.
    return [[attribStr string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(void) clearNSSetPropertyIfNotIncluded:(NSString*)propertyName inArray:(NSArray*)fields
{
    if (![fields containsObject:propertyName])
    {
        [self setValue:[NSSet set] forKey:propertyName];
    }
}

-(void) clearStringPropertyIfNotIncluded:(NSString*)propertyName inArray:(NSArray*)fields
{
    if (![fields containsObject:propertyName])
    {
        [BDFMyProfile changeStringValue:nil forKey:propertyName forManagedObject:self];
    }
}

@end