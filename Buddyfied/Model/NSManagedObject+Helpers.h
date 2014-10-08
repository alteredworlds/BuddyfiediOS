//
//  NSManagedObject+Helpers.h
//  Buddyfied
//
//  Created by Tom Gilbert on 03/07/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Helpers)

+ (void) changeNumberValue:(NSNumber*)value
                    forKey:(NSString*)key
          forManagedObject:(NSManagedObject*)managedObject;

+ (void) changeStringValue:(NSString*)value
                    forKey:(NSString*)key
          forManagedObject:(NSManagedObject*)managedObject;

@end
