//
//  BDFGameplay+Create.m
//  Buddyfied
//
//  Created by Tom Gilbert on 20/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFGameplay+Create.h"
#import "BDFPlayerAttribute+Create.h"
#import "BDFEntityNames.h"

@implementation BDFGameplay (Create)

+ (BDFGameplay*) gameplayWithId:(NSString*)unique
                        andName:(NSString*)name
         inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    return (BDFGameplay*)[BDFPlayerAttribute attributeForEntity:GAMEPLAY_ENTITY
                                                        withId:unique
                                                       andName:name
                                        inManagedObjectContext:managedObjectContext];
}

@end
