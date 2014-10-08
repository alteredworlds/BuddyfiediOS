//
//  BDFMyProfileDataAdapter.h
//  Buddyfied
//
//  Created by Tom Gilbert on 10/07/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDFMyProfileDataAdapter : NSObject

- (NSString*) entityNameForModelProperty:(NSString*)propertyName;

- (NSArray*) entitiesForIdList:(NSArray*)idList
                    entityName:(NSString*)entityName
        inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

@end
