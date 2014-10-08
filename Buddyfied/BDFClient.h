//
//  BDFClient.h
//  Buddyfied
//
//  Created by Tom Gilbert on 10/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//
#import "BDFDataSource.h"

@interface BDFClient : NSObject <BDFDataSource>

@property (nonatomic, strong) NSString *buddySite;

-(instancetype) initWithBuddySite:(NSString*)buddySite;

-(void) verifyUser:(NSString*)user
      withPassword:(NSString*)password
   completionBlock:(BDFDataSourceCompletionBlock)completion;

-(void) getMemberInfo:(NSString*)user
         withPassword:(NSString*)password
          forMemberId:(NSString*)userId
      completionBlock:(BDFDataSourceCompletionBlock)completion;

-(void) sendMessage:(NSString*)user
       withPassword:(NSString*)password
         recipients:(NSString*)recipients
            subject:(NSString*)subject
               body:(NSString*)body
    completionBlock:(BDFDataSourceCompletionBlock)completion;

//-(void) getNotifications:(NSString*)user
//            withPassword:(NSString*)password
//         completionBlock:(BDFDataSourceCompletionBlock)completion;
//
//-(void) getMessages:(NSString*)user
//       withPassword:(NSString*)password
//    completionBlock:(BDFDataSourceCompletionBlock)completion;
//
//-(void) getGroups:(NSString*)user
//     withPassword:(NSString*)password
//  completionBlock:(BDFDataSourceCompletionBlock)completion;

@end
