//
//  BDFMyProfile+Calculated.m
//  Buddyfied
//
//  Created by Tom Gilbert on 07/07/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFMyProfile+Calculated.h"
#import "BDFPlayerAttribute.h"
#import "BDFBuddyProfileFieldMapper.h"
#import "BDFBuddyProfile+Calculated.h"

@implementation BDFMyProfile (Calculated)


+ (NSDictionary*) diffsDictionaryForTransmission:(NSDictionary*)dictionaryForTransmissionBefore
                                          andAfter:(NSDictionary*)dictionaryForTransmissionAfter
{
    NSMutableDictionary* retVal = [dictionaryForTransmissionAfter mutableCopy];
    // we should have keys for all fields in both dictionaries.
    if (dictionaryForTransmissionBefore.count != dictionaryForTransmissionAfter.count)
    {
        NSLog(@"Dictionary counts different (before: %lu after: %lu) how can these be profiles?",
              (unsigned long)dictionaryForTransmissionBefore.count,
              (unsigned long)dictionaryForTransmissionAfter.count);
    }
    else
    {
        for (NSString* key in dictionaryForTransmissionBefore)
        {
            NSString* beforeValue = dictionaryForTransmissionBefore[key];
            NSString* afterValue = dictionaryForTransmissionAfter[key];
            if ([afterValue isEqualToString:beforeValue])
            {   // we don't need this in the diff collection since value same
                [retVal removeObjectForKey:key];
            }
        }
    }
    return retVal;
}

-(NSDictionary*) dictionaryForTransmission
{
    BDFBuddyProfileFieldMapper* fieldMapper = [[BDFBuddyProfileFieldMapper alloc] init];
    NSMutableDictionary* retVal = [[NSMutableDictionary alloc] init];
    [self flattenAttributeIDsForSet:@"country" intoDictionary:retVal usingFieldMapper:fieldMapper];
    [self flattenAttributeIDsForSet:@"gameplay" intoDictionary:retVal usingFieldMapper:fieldMapper];
    [self flattenAttributeIDsForSet:@"language" intoDictionary:retVal usingFieldMapper:fieldMapper];
    [self flattenAttributeIDsForSet:@"platform" intoDictionary:retVal  usingFieldMapper:fieldMapper];
    [self flattenAttributeIDsForSet:@"playing" intoDictionary:retVal  usingFieldMapper:fieldMapper];
    [self flattenAttributeIDsForSet:@"skill" intoDictionary:retVal  usingFieldMapper:fieldMapper];
    [self flattenAttributeIDsForSet:@"time" intoDictionary:retVal  usingFieldMapper:fieldMapper];
    [self flattenAttributeIDsForSet:@"voice" intoDictionary:retVal  usingFieldMapper:fieldMapper];
    [self flattenAttributeIDsForSet:@"years" intoDictionary:retVal  usingFieldMapper:fieldMapper];
    [self addStringValueForProperty:@"comments" intoDictionary:retVal usingFieldMapper:fieldMapper];
    return retVal;
}

-(void) addStringValueForProperty:(NSString*)propertyName
                   intoDictionary:(NSMutableDictionary*)dictionary
                 usingFieldMapper:(BDFBuddyProfileFieldMapper*)fieldMapper
{
    NSString* transformedValue = [self valueForKey:propertyName];
    if (!transformedValue)
        transformedValue = @"";
    NSString* transformedKey = [fieldMapper serverIdForModelProperty:propertyName];
    dictionary[transformedKey] = transformedValue;
}


-(void) flattenAttributeIDsForSet:(NSString*)propertyName
                   intoDictionary:(NSMutableDictionary*)dictionary
                 usingFieldMapper:(BDFBuddyProfileFieldMapper*)fieldMapper
{
    NSString* flattenedValue = [self flattenedAttributeIDsForSet:propertyName];
    NSString* transformedKey = [fieldMapper serverIdForModelProperty:propertyName];
    dictionary[transformedKey] = flattenedValue;
}

@end
