//
//  NSManagedObject+Helpers.m
//  Buddyfied
//
//  Created by Tom Gilbert on 03/07/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "NSManagedObject+Helpers.h"

@implementation NSManagedObject (Helpers)

+ (void) changeNumberValue:(NSNumber*)value
                    forKey:(NSString*)key
          forManagedObject:(NSManagedObject*)managedObject
{
    NSNumber* tmp = [managedObject valueForKey:key];
    if (NSOrderedSame != [tmp compare:value])
        [managedObject setValue:value forKey:key];
}

+ (void) changeStringValue:(NSString*)value
                    forKey:(NSString*)key
          forManagedObject:(NSManagedObject*)managedObject
{
    NSString* tmp = [managedObject valueForKey:key];
    if (![tmp isEqualToString:value])
        [managedObject setValue:value forKey:key];
}

@end
