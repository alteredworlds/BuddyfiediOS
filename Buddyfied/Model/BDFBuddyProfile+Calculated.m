//
//  BDFBuddyProfile+Calculated.m
//  Buddyfied
//
//  Created by Tom Gilbert on 14/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFBuddyProfile+Calculated.h"
#import "BDFPlayerAttribute.h"

@implementation BDFBuddyProfile (Calculated)

-(NSDictionary*) dictionaryForTransmission
{
    NSMutableDictionary* retVal = [[NSMutableDictionary alloc]
                                   initWithDictionary:[self dictionaryWithValuesForKeys:@[@"unique", @"name"]]];
    [self flattenAttributeIDsForSet:@"country" intoDictionary:retVal];
    [self flattenAttributeIDsForSet:@"gameplay" intoDictionary:retVal];
    [self flattenAttributeIDsForSet:@"language" intoDictionary:retVal];
    [self flattenAttributeIDsForSet:@"platform" intoDictionary:retVal];
    [self flattenAttributeIDsForSet:@"playing" intoDictionary:retVal];
    [self flattenAttributeIDsForSet:@"skill" intoDictionary:retVal];
    [self flattenAttributeIDsForSet:@"time" intoDictionary:retVal];
    [self flattenAttributeIDsForSet:@"age" intoDictionary:retVal];
    [self flattenAttributeIDsForSet:@"voice" intoDictionary:retVal withKey:@"mic"];
    return retVal;
}

-(void) flattenAttributeIDsForSet:(NSString*)propertyName intoDictionary:(NSMutableDictionary*)dictionary
{
    [self flattenAttributeIDsForSet:propertyName
                     intoDictionary:dictionary
                            withKey:propertyName];
}

-(void) flattenAttributeIDsForSet:(NSString*)propertyName
                   intoDictionary:(NSMutableDictionary*)dictionary
                          withKey:(NSString*)key
{
    NSString* strValue = [self flattenedAttributeIDsForSet:propertyName];
    if (strValue.length)
    {
        [dictionary setValue:strValue forKey:key];
    }
}

-(NSString*) flattenedAttributeIDsForSet:(NSString*)propertyName
{
    NSMutableString* strValue = [[NSMutableString alloc] init];
    NSSet* set = [self valueForKey:propertyName];
    for (BDFPlayerAttribute* attribute in set)
    {
        if (strValue.length)
            [strValue appendFormat:@",%@", attribute.id];
        else
            [strValue appendFormat:@"%@", attribute.id];
    }
    return strValue;
}

@end
