//
//  BDFPlayerAttribute+Create.h
//  Buddyfied
//
//  Created by Tom Gilbert on 07/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFPlayerAttribute.h"

@interface BDFPlayerAttribute (Create)

+ (instancetype) attributeForEntity:(NSString*)entityName
                             withId:(NSString*)unique
                            andName:(NSString*)name
             inManagedObjectContext:(NSManagedObjectContext*)context;

+ (instancetype) attributeForEntity:(NSString*)entityName
                             withId:(NSString*)unique
                            andName:(NSString*)name
             inManagedObjectContext:(NSManagedObjectContext*)context
                     usingPredicate:(NSPredicate*)predicate;

+ (void) loadEntitiesNamed:(NSString*)entityName
            fromDictionary:(NSDictionary*)dictionary
    inManagedObjectContext:(NSManagedObjectContext*)context
            removeExisting:(BOOL)removeExisting;

@end
