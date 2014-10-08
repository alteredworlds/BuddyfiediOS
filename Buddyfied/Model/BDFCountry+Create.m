//
//  BDFCountry+Create.m
//  Buddyfied
//
//  Created by Tom Gilbert on 20/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFCountry+Create.h"
#import "BDFPlayerAttribute+Create.h"
#import "BDFEntityNames.h"

@implementation BDFCountry (Create)

+ (BDFCountry*) countryWithId:(NSString*)unique
                      andName:(NSString*)name
       inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    return (BDFCountry*)[BDFPlayerAttribute attributeForEntity:COUNTRY_ENTITY
                                                         withId:unique
                                                        andName:name
                                         inManagedObjectContext:managedObjectContext];
}

@end
