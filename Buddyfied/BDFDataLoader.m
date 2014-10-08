//
//  BDFDataLoader.m
//  Buddyfied
//
//  Created by Tom Gilbert on 14/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFDataLoader.h"
#import "BDFSearchRequest+Create.h"
#import "BDFAppDelegate.h"

@implementation BDFDataLoader


+ (void) loadMatchesFromDataSource:(id <BDFDataSource>)dataSource
                            asUser:(NSString*)user
                      withPassword:(NSString*)password
                  forSearchRequest:(BDFSearchRequest*)searchRequest
                    removeExisting:(BOOL)removeExisting
                   completionBlock:(BDFDataSourceCompletionBlock)completion
{
    ((BDFAppDelegate*)[UIApplication sharedApplication].delegate).showNetworkActivity = YES;
    [dataSource getMatches:user
              withPassword:password
           forSearchRequest:searchRequest
           completionBlock:^(id result, NSError *error) {
               dispatch_async(dispatch_get_main_queue(), ^ {
                   ((BDFAppDelegate*)[UIApplication sharedApplication].delegate).showNetworkActivity = NO;
                   if (completion)
                       completion(searchRequest, error);
               });
           }];
}

@end
