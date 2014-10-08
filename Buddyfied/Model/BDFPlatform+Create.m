//
//  BDFPlatform+Create.m
//  Buddyfied
//
//  Created by Tom Gilbert on 20/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFPlatform+Create.h"
#import "BDFPlayerAttribute+Create.h"
#import "BDFEntityNames.h"

@implementation BDFPlatform (Create)

+ (BDFPlatform*) platformWithId:(NSString*)unique
                        andName:(NSString*)name
         inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    return (BDFPlatform*)[BDFPlayerAttribute attributeForEntity:PLATFORM_ENTITY
                                           withId:unique
                                          andName:name
                           inManagedObjectContext:managedObjectContext];
}

@end
