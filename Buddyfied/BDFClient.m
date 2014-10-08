//
//  BDFClient.m
//  Buddyfied
//
//  Created by Tom Gilbert on 10/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFClient.h"
#import "WPXMLRPCClient.h"
#import "BDFBuddyProfile+Calculated.h"
#import "BDFSearchRequest.h"
#import "BDFSettings.h"
#import "BDFBuddy+Create.h"

@interface BDFClient ()

@property (nonatomic, strong) WPXMLRPCClient* api;

@end

@implementation BDFClient

/*
// add blogs status new_xmlrpc_blog_post
static NSString* const UpdateExternalBlogPostStatus = @"bp.updateExternalBlogPostStatus";
static NSString* const DeleteExternalBlogPostStatus = @"bp.deleteExternalBlogPostStatus";

// add profile status activity_update
static NSString* const UpdateProfileStatus = @"bp.updateProfileStatus";
static NSString* const DeleteProfileStatus = @"bp.deleteProfileStatus";
static NSString* const PostComment = @"bp.postComment";

// get lists
static NSString* const GetMyFriends = @"bp.getMyFriends";
static NSString* const GetGroups = @"bp.getGroups";

// messages / notifications
static NSString* const GetNotifications = @"bp.getNotifications";
static NSString* const GetMessages = @"bp.getMessages";
 
// get recent statuses
static NSString* const GetActivity = @"bp.getActivity";
*/

// search
static NSString* const GetMatches = @"bp.getMatches";

// send message
static NSString* const SendMessage = @"bp.sendMessage";

// members
// required parameter: "user_id" : numeric_id
static NSString* const GetMemberInfo = @"bp.getMemberData";

// for services connecting: verify it
static NSString* const VerifyConnection = @"bp.verifyConnection";


-(instancetype) init
{
    self = [super init];
    if (self)
    {   // DEFAULT values for data members
        _buddySite = [BDFSettings sharedSettings].buddySite;
    }
    return self;
}

-(instancetype) initWithBuddySite:(NSString*)buddySite
{
    self = [super init];
    if (self)
    {
        _buddySite = buddySite;
    }
    return self;
}

- (WPXMLRPCClient *)api
{
    if (_api == nil)
    {
        NSString* uri = [NSString stringWithFormat:@"%@index.php?bp_xmlrpc=true", self.buddySite];
        _api = [[WPXMLRPCClient alloc] initWithXMLRPCEndpoint:[NSURL URLWithString:uri]];
    }
    return _api;
}

-(void) cancelAll
{
    [self.api cancelAllHTTPOperations];
}

-(void) verifyUser:(NSString*)user
      withPassword:(NSString*)password
   completionBlock:(BDFDataSourceCompletionBlock)completion
{
    //NSLog(@"Calling %@ at %@", VerifyConnection, self.buddySite);
    [self.api callMethod:VerifyConnection
              parameters:@[user, password]
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     if (completion)
                     {
                         completion(responseObject, nil);
                     }
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     if (completion)
                     {
                         completion(nil, error);
                     }
                 }
     ];
}

-(void) getMemberInfo:(NSString*)user
         withPassword:(NSString*)password
          forMemberId:(NSString*)userId
      completionBlock:(BDFDataSourceCompletionBlock)completion
{
    //NSLog(@"Calling %@ at %@", GetMemberInfo, self.buddySite);
    [self.api callMethod:GetMemberInfo
              parameters:@[user, password, @{ @"user_id": userId}]
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     if (completion)
                     {
                         completion(responseObject, nil);
                     }
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     if (completion)
                     {
                         completion(nil, error);
                     }
                 }
     ];
}

-(void) getMatches:(NSString*)user
      withPassword:(NSString*)password
  forSearchRequest:(BDFSearchRequest*)searchRequest
   completionBlock:(BDFDataSourceCompletionBlock)completion
{
    //NSLog(@"Calling %@ at %@", GetMatches, self.buddySite);
    //
    // request needs to be transformed into something efficiently serializable
    NSDictionary* requestAsDictionary = [searchRequest dictionaryForTransmission];
    [self.api callMethod:GetMatches
              parameters:@[user, password, requestAsDictionary]
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     [searchRequest.managedObjectContext performBlockAndWait:^{
                         [BDFBuddy parseBuddiesFromBuddyfiedResponse:responseObject
                                              inManagedObjectContext:searchRequest.managedObjectContext];
                     }];
                     if (completion)
                     {
                         completion(responseObject, nil);
                     }
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     if (completion)
                     {
                         completion(nil, error);
                     }
                 }
     ];
}

/**
 * send message.
 *
 * @param array $args ($username, $password, $data['thread_id','recipients','subject','content'])
 * @return array (confirmation, message);
 */
-(void) sendMessage:(NSString*)user
       withPassword:(NSString*)password
         recipients:(NSString*)recipients
            subject:(NSString*)subject
               body:(NSString*)body
    completionBlock:(BDFDataSourceCompletionBlock)completion
{
    //NSLog(@"Calling %@ at %@", SendMessage, self.buddySite);
    [self.api callMethod:SendMessage
              parameters:@[user, password, @{@"recipients": recipients, @"subject" : subject, @"content" : body}]
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     if (completion)
                     {
                         completion(responseObject, nil);
                     }
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     if (completion)
                     {
                         completion(nil, error);
                     }
                 }
     ];
}

/*
-(void) getNotifications:(NSString*)user
            withPassword:(NSString*)password
         completionBlock:(BDFDataSourceCompletionBlock)completion
{
    NSLog(@"Calling %@ at %@", GetNotifications, self.buddySite);
    [self.api callMethod:GetNotifications
              parameters:@[user, password]
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     if (completion)
                     {
                         completion(responseObject, nil);
                     }
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     if (completion)
                     {
                         completion(nil, error);
                     }
                 }
     ];
}

-(void) getMessages:(NSString*)user
       withPassword:(NSString*)password
    completionBlock:(BDFDataSourceCompletionBlock)completion
{
    NSLog(@"Calling %@ at %@", GetMessages, self.buddySite);
    [self.api callMethod:GetMessages
              parameters:@[user, password, @{@"action": @"read"}]
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     if (completion)
                     {
                         completion(responseObject, nil);
                     }
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     if (completion)
                     {
                         completion(nil, error);
                     }
                 }
     ];
}

-(void) getGroups:(NSString*)user
     withPassword:(NSString*)password
  completionBlock:(BDFDataSourceCompletionBlock)completion
{
    NSLog(@"Calling %@ at %@", GetGroups, self.buddySite);
    [self.api callMethod:GetGroups
              parameters:@[user, password]
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     if (completion)
                     {
                         completion(responseObject, nil);
                     }
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     if (completion)
                     {
                         completion(nil, error);
                     }
                 }
     ];
}
*/

@end
