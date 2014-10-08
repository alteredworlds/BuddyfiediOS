//
//  BDFLanguage+Create.m
//  Buddyfied
//
//  Created by Tom Gilbert on 20/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFLanguage+Create.h"
#import "BDFPlayerAttribute+Create.h"
#import "BDFEntityNames.h"

@implementation BDFLanguage (Create)

+ (BDFLanguage*) languageWithId:(NSString*)unique
                        andName:(NSString*)name
         inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    return (BDFLanguage*)[BDFPlayerAttribute attributeForEntity:LANGUAGE_ENTITY
                                                         withId:unique
                                                        andName:name
                                         inManagedObjectContext:managedObjectContext];
}

@end
