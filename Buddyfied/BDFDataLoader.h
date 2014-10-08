//
//  BDFDataLoader.h
//  Buddyfied
//
//  Created by Tom Gilbert on 14/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDFDataSource.h"

@interface BDFDataLoader : NSObject

+ (void)loadMatchesFromDataSource:(id <BDFDataSource>)dataSource
                          asUser:(NSString*)user
                    withPassword:(NSString*)password
                forSearchRequest:(BDFSearchRequest*)searchRequest
                  removeExisting:(BOOL)removeExisting
                 completionBlock:(BDFDataSourceCompletionBlock)completion;

@end
