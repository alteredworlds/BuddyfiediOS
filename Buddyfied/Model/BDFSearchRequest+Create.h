//
//  BDFSearchRequest+Create.h
//  Buddyfied
//
//  Created by Tom Gilbert on 20/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFSearchRequest.h"

extern NSString* const SearchRequestEntityName;

@interface BDFSearchRequest (Create)

+ (BDFSearchRequest*) searchRequestWithName:(NSString*)name
                     inManagedObjectContext:(NSManagedObjectContext*)context;

@end
