//
//  BDFPlaying+Create.m
//  Buddyfied
//
//  Created by Tom Gilbert on 20/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFPlaying+Create.h"
#import "BDFPlayerAttribute+Create.h"
#import "BDFEntityNames.h"

@implementation BDFPlaying (Create)

+ (BDFPlaying*) playingWithId:(NSString*)unique
                      andName:(NSString*)name
       inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    return (BDFPlaying*)[BDFPlayerAttribute attributeForEntity:PLAYING_ENTITY
                                                         withId:unique
                                                        andName:name
                                         inManagedObjectContext:managedObjectContext];
}

@end
