//
//  BDFLanguage+Create.h
//  Buddyfied
//
//  Created by Tom Gilbert on 20/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFLanguage.h"

@interface BDFLanguage (Create)

+ (BDFLanguage*) languageWithId:(NSString*)unique
                        andName:(NSString*)name
         inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

@end
