//
//  BDFAppDelegate+BasicConfiguration.m
//  Buddyfied
//
//  Created by Tom Gilbert on 17/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFAppDelegate+BasicConfiguration.h"
#import "BDFPlatform+Create.h"
#import "BDFGameplay+Create.h"
#import "BDFPlaying+Create.h"
#import "BDFCountry+Create.h"
#import "BDFLanguage+Create.h"
#import "BDFSearchRequest+Create.h"
#import "BDFEntityNames.h"
#import "BDFPlayerAttribute+Create.h"

@implementation BDFAppDelegate (BasicConfiguration)

static NSString* const MainMenuDefaultName = @"My Menu";

-(void) setupBasicConfig:(NSManagedObjectContext*)managedObjectContext
{
    // empty search request
    [BDFSearchRequest searchRequestWithName:@"Default"
                     inManagedObjectContext:managedObjectContext];
    //
    // we also need to add static that is currently not retrieved from server
    [self setupAgeRange:managedObjectContext];
    [self setupVoice:managedObjectContext];
    [self setupYears:managedObjectContext];
    [self.uiManagedDocument updateChangeCount:UIDocumentChangeDone];
    
}

-(void) setupAgeRange:(NSManagedObjectContext*)managedObjectContext
{
    [self addAttributeWithSameIdValue:@"16-19"
                         forEntityName:AGE_ENTITY
                inManagedObjectContext:managedObjectContext];
    
    [self addAttributeWithSameIdValue:@"20-25"
                         forEntityName:AGE_ENTITY
                inManagedObjectContext:managedObjectContext];
    
    [self addAttributeWithSameIdValue:@"26-35"
                         forEntityName:AGE_ENTITY
                inManagedObjectContext:managedObjectContext];
    
    [self addAttributeWithSameIdValue:@"36-44"
                         forEntityName:AGE_ENTITY
                inManagedObjectContext:managedObjectContext];
    
    [self addAttributeWithSameIdValue:@"45+"
                         forEntityName:AGE_ENTITY
                inManagedObjectContext:managedObjectContext];
}

-(void) setupYears:(NSManagedObjectContext*)managedObjectContext
{
    for (int idx=15; idx < 81; idx++)
    {
        [self addAttributeWithSameIdValue:[NSString stringWithFormat:@"%d", idx]
                            forEntityName:YEARS_ENTITY
                   inManagedObjectContext:managedObjectContext];
    }
}

-(void) setupVoice:(NSManagedObjectContext*)managedObjectContext
{
    [self addAttributeWithSameIdValue:@"Yes"
                         forEntityName:VOICE_ENTITY
                inManagedObjectContext:managedObjectContext];
    
    [self addAttributeWithSameIdValue:@"No"
                         forEntityName:VOICE_ENTITY
                inManagedObjectContext:managedObjectContext];
}

-(void) addAttributeWithSameIdValue:(NSString*)value
                       forEntityName:(NSString*)entityName
              inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    [BDFPlayerAttribute attributeForEntity:entityName
                                    withId:value
                                   andName:value
                    inManagedObjectContext:managedObjectContext];
}

@end