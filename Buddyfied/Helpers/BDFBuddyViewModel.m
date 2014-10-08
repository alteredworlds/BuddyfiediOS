//
//  BDFBuddyViewModel.m
//  Buddyfied
//
//  Created by Tom Gilbert on 24/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFBuddyViewModel.h"
#import "BDFEntityNames.h"
#import "BDFBuddy.h"
#import "BDFMyProfile.h"
#import "BDFFlatBuddyProfile.h"
#import "BDFProfileDataAdapter.h"

@implementation BDFBuddyViewModel

-(NSUInteger) commentRow
{
    return ((BDFProfileDataAdapter*)self.adapter).commentRow;
}


#pragma mark - overrides
-(BDFBuddyProfileDataAdapter*) adapter
{
    if (!_adapter)
    {
        _adapter = [[BDFProfileDataAdapter alloc] init];
    }
    return _adapter;
}

-(void)updateFromBuddyProfile:(BDFBuddyProfile*)buddyProfile
{
    [super updateFromBuddyProfile:buddyProfile];
    if ([buddyProfile isKindOfClass:[BDFMyProfile class]])
    {
        BDFMyProfile* myProfile = (BDFMyProfile*)buddyProfile;
        self.imageURL = myProfile.imageURL;
        self.comments = myProfile.comments;
        self.age = [self formattedTextForBuddyProfile:buddyProfile
                                                        propertyName:@"years"];
    }
}

#pragma mark - Build BDFBuddyViewModel

-(void)updateFromBuddy:(BDFFlatBuddyProfile*)buddy
{
    self.name = buddy.name;
    self.unique = buddy.unique;
    self.imageURL = buddy.imageURL;
    self.comments = buddy.comments;
    self.age = buddy.years;
    for (int idx=0; idx < self.adapter.flattenPropertyNames.count; idx++)
    {
        NSString* propertyName = self.adapter.flattenPropertyNames[idx];
        NSArray*  idList = [[buddy valueForKey:propertyName] componentsSeparatedByString:@","];
        NSString* formattedText = [self formattedTextFromIdList:idList
                                                  forEntityName:[self.adapter entityNameForProperty:propertyName]
                                         inManagedObjectContext:buddy.managedObjectContext];
        [self setValue:formattedText forKey:propertyName];
    }
}

-(NSString*)formattedTextFromIdList:(NSArray*)idList
                      forEntityName:(NSString*)entityName
             inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    NSMutableString* retVal = [[NSMutableString alloc] init];
    if (idList)
    {
        NSArray *matches = [self.adapter entitiesForIdList:idList
                                                entityName:entityName
                                    inManagedObjectContext:managedObjectContext];
        if (matches)
        {
            for (NSManagedObject* value in matches)
            {
                NSString* name = [value valueForKey:@"name"];
                if (0 == [retVal length])
                    [retVal appendString:name];
                else
                    [retVal appendFormat:@"\n%@", name];
            }
        }
    }
    return retVal;
}

@end
