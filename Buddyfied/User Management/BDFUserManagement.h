//
//  BDFUserRegistration.h
//  Buddyfied
//
//  Created by Tom Gilbert on 02/07/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BDFUserManagement <NSObject>

typedef void (^BDFUserManagementCompletionBlock)(id result, NSError *error);

-(void) cancel;

-(void) registerNewUser:(NSString*)user
           withPassword:(NSString*)password
        andEmailAddress:(NSString*)email
              usingData:(NSDictionary*)profileData
        completionBlock:(BDFUserManagementCompletionBlock)completion;

-(void) updateProfileForUser:(NSString*)user
                withPassword:(NSString*)password
                   usingData:(NSDictionary*)profileData
             completionBlock:(BDFUserManagementCompletionBlock)completion;

@end
