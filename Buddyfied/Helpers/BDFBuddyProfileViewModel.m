//
//  BDFBuddyProfileViewModel.m
//  Buddyfied
//
//  Created by Tom Gilbert on 23/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFBuddyProfileViewModel.h"
#import "BDFBuddyProfile.h"
#import "BDFEntityNames.h"
#import "BDFBuddy.h"

@interface BDFBuddyProfileViewModel ()

@end

@implementation BDFBuddyProfileViewModel

-(BDFBuddyProfileDataAdapter*) adapter
{
    if (!_adapter)
    {
        _adapter = [[BDFBuddyProfileDataAdapter alloc] init];
    }
    return _adapter;
}

-(NSUInteger) numRows
{
    return self.adapter.entityNames.count;
}

-(NSString*) nameForRow:(NSUInteger)row
{
    return self.adapter.entityNames[row];
}

-(NSString*) valueForName:(NSString*)name
{
    NSString* retVal = nil;
    NSUInteger idx = [self.adapter.entityNames indexOfObject:name];
    if (NSNotFound != idx)
    {
        retVal = [self valueForRow:idx];
    }
    return retVal;
}

-(NSString*) valueForRow:(NSUInteger)row
{
    NSString* propertyNameForRow = self.adapter.propertyNames[row];
    return [self valueForKey:propertyNameForRow];
}

- (BOOL)pickerShouldDisplayIndex:(NSString*)entityName
{
    BOOL retVal = NO;
    if ([entityName isEqualToString:PLAYING_ENTITY] ||
        [entityName isEqualToString:COUNTRY_ENTITY] ||
        [entityName isEqualToString:LANGUAGE_ENTITY])
    {
        retVal = YES;
    }
    return retVal;
}

- (BOOL)pickerShouldPreventRefresh:(NSString*)entityName
{
    BOOL retVal = NO;
    if ([entityName isEqualToString:AGE_ENTITY] ||
        [entityName isEqualToString:YEARS_ENTITY] ||
        [entityName isEqualToString:VOICE_ENTITY])
    {
        retVal = YES;
    }
    return retVal;
}

-(void)updateFromBuddyProfile:(BDFBuddyProfile*)buddyProfile
{
    // transfer data from simple properties
    self.name = buddyProfile.name;
    self.unique = buddyProfile.unique;
    //
    // flatten each property of type NSSet* into single string value for display
    for (NSString* propertyName in self.adapter.flattenPropertyNames)
    {
        NSString* formattedText = [self formattedTextForBuddyProfile:buddyProfile
                                                        propertyName:propertyName];
        [self setValue:formattedText forKey:propertyName];
    }
}

-(NSString*)formattedTextForBuddyProfile:(BDFBuddyProfile*)buddyProfile
                            propertyName:(NSString*)propertyName
{
    NSMutableString* retVal = [[NSMutableString alloc] init];
    NSSet* values = [buddyProfile valueForKey:propertyName];
    NSArray* sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                               ascending:YES
                                                                selector:@selector(localizedStandardCompare:)]];
    NSArray* sortedValues = [values sortedArrayUsingDescriptors:sortDescriptors];
    for (NSManagedObject* value in sortedValues)
    {
        NSString* name = [value valueForKey:@"name"];
        if (0 == [retVal length])
            [retVal appendString:name];
        else
            [retVal appendFormat:@"\n%@", name];
    }
    return retVal;
}

@end
