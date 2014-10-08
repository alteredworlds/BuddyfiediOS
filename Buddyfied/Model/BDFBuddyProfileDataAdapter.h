//
//  BDFEntityDataAdapter.h
//  Buddyfied
//
//  Created by Tom Gilbert on 03/07/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDFBuddyProfileDataAdapter : NSObject

@property (nonatomic, strong) NSMutableArray* entityNames;
@property (nonatomic, strong) NSMutableArray* propertyNames;
@property (nonatomic, strong) NSMutableArray* flattenPropertyNames;

-(instancetype)init;

- (NSString*) entityNameForProperty:(NSString*)entityName;

- (NSArray*) entitiesForIdList:(NSArray*)idList
                    entityName:(NSString*)entityName
        inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

@end
