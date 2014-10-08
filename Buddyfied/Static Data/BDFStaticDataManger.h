//
//  BDFStaticDataManger.h
//  Buddyfied
//
//  Created by Tom Gilbert on 20/05/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDFStaticDataManger : NSObject

+ (instancetype) shared;

typedef void (^BuddyfiedReadStaticCompletionBlock)(NSString* entityName, NSError *error);

-(void) initialStaticDataLoadIfNeeded:(NSManagedObjectContext*)managedObjectContext;

-(void) loadStaticData:(NSManagedObjectContext*)managedObjectContext removeExisting:(BOOL)removeExisting;

-(void)loadStaticForEntityNamed:(NSString*)entityName
         inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
                 removeExisting:(BOOL)removeExisting
                completionBlock:(BuddyfiedReadStaticCompletionBlock)completion;

-(BOOL)isRequestInProgressForEntityNamed:(NSString*)entityName;

@end
