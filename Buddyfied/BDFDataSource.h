//
//  BDFDataSource.h
//  Buddyfied
//
//  Created by Tom Gilbert on 14/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BDFSearchRequest;

@protocol BDFDataSource <NSObject>

typedef void (^BDFDataSourceCompletionBlock)(id result, NSError *error);

-(void) cancelAll;

-(void) getMatches:(NSString*)user
      withPassword:(NSString*)password
   forSearchRequest:(BDFSearchRequest*)searchRequest
   completionBlock:(BDFDataSourceCompletionBlock)completion;

@end
